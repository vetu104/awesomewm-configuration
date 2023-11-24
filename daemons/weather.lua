local lgi = require("lgi")
local Secret = lgi.Secret
local awful = require("awful")
local gfs = require("gears.filesystem")
local gobject = require("gears.object")
local gtable = require("gears.table")
local gtimer = require("gears.timer")
local async = require("async")
local asyncio = { File = require("lgi-async-extra.file"), Filesystem = require("lgi-async-extra.filesystem") }
local json = require("json")
local geoclue = require("daemons.geoclue")

local instance = nil

local weatherd = {}

weatherd.retry = 0

local function generate_timestamps()
    local timeofday_now = os.date("!*t")
    timeofday_now = timeofday_now.hour * 60 * 60 + timeofday_now.min * 60 + timeofday_now.sec
    -- 54000 = 15 oclock
    local diff = timeofday_now - 54000
    -- pienempi kuin 0> ennen 15, suurempi > jälkeen

    local first = os.time() - diff + 24 * 60 * 60
    -- huomenna klo 15

    local tbl = {}
    for i=0,3 do
        table.insert(tbl, first + i * 24 * 60 * 60)
    end

    return tbl
end

local function neaten_data(data, mode)

    if mode == "weather" then
        local tbl = {
            city        = data.name,
            country     = data.sys.country,
            dt          = data.dt,
            feels_like  = data.main.feels_like,
            humidity    = data.main.humidity,
            icon        = data.weather[1].icon,
            pressure    = data.main.pressure,
            rain_1h     = data.rain and data.rain["1h"],
            rain_3h     = data.rain and data.rain["3h"],
            snow_1h     = data.snow and data.snow["1h"],
            snow_3h     = data.snow and data.snow["3h"],
            sunrise     = data.sys.sunrise,
            sunset      = data.sys.sunset,
            temp        = data.main.temp,
            visibility  = data.visibility,
            weather     = data.weather[1].description,
            wind_deg    = data.wind.deg,
            wind_gust   = data.wind.gust,
            wind_speed  = data.wind.speed,
        }

        return tbl
    end

    if mode == "forecast" then
        -- Timestamps for next 4 days at 15 oclock
        local timestamps = generate_timestamps()
        data = data.list
        -- Put entries with timestamp at 15 oclock
        -- for next 4 days to table
        local temp = {}
        for _,stamp in ipairs(timestamps) do
            for _,tbl in ipairs(data) do
                if tbl["dt"] == stamp then
                    table.insert(temp, tbl)
                end
            end
        end

        -- Organize data from each daywise table
        local ret = {}
        for i=1,4 do
            table.insert(ret, {})
            ret[i].dt         = temp[i].dt
            ret[i].feels_like = temp[i].main.feels_like
            ret[i].humidity   = temp[i].main.humidity
            ret[i].icon       = temp[i].weather[1].icon
            ret[i].pop        = temp[i].pop  -- sateen todennäköisyys
            ret[i].pressure   = temp[i].main.pressure
            ret[i].rain_1h    = temp[i].rain and temp[i].rain["1h"]
            ret[i].snow_3h    = temp[i].snow and temp[i].snow["3h"]
            ret[i].temp       = temp[i].main.temp
            ret[i].visibility = temp[i].visibility
            ret[i].weather    = temp[i].weather[1].description
            ret[i].wind_deg   = temp[i].wind.deg
            ret[i].wind_gust  = temp[i].wind.gust
            ret[i].wind_speed = temp[i].wind.speed
        end

        return ret
    end
end

function weatherd:reschedule()
    if self.retry > 3 then return end

    self.retry = self.retry + 1
    gtimer({
        timeout = 60 * 2,
        autostart = true,
        call_now = true,
        single_shot = true,
        callback = function()
            self:handle_cache("weather")
            self:handle_cache("forecast")
        end,
    })
end

function weatherd:handle_cache(mode)
    local path = string.format("%s%s.json", gfs.get_cache_dir(), mode)
    local file = asyncio.File.new_for_path(path)

    async.waterfall({
        -- Get cache file last modified and decide if to continue
        function(cb)
            file:query_info("time::modified", function(err, obj)
                -- File didn't exist
                -- Just return early, later function will create it
                if err and err.code == "NOT_FOUND" then
                    cb()
                    return
                end

                local timeout = 60 * 20 -- 20 mins
                local time = obj:get_modification_date_time():to_unix()
                local diff = os.time() - time
                err = diff < timeout and "from_cache"
                cb(err, diff)
            end)
        end,

        -- Get api key from libsecret
        function(cache_age, cb)
            local schema = Secret.Schema.new(
                "org.vetu104", Secret.SchemaFlags.NONE,
                { ["openweather"] = Secret.SchemaAttributeType.STRING }
            )
            local attrs = { ["openweather"] = "apikey" }

            Secret.password_lookup(schema, attrs, nil, function(err, token)
                local api_key = Secret.password_lookup_finish(token)
                if not api_key then
                    -- Check cache age again
                    if cache_age < 60 * 60 * 2 then
                        err = "from_cache"
                    else
                        err = "missing_credentials"
                    end
                    --self:reschedule()
                end
                cb(err, api_key)
            end)
        end,

        -- Compose api query
        function (result, cb)
            local latitude = geoclue:get_latitude()
            local longitude = geoclue:get_longitude()
            local api_key = result
            local err = (not latitude or not longitude or not api_key) and true
            local uri = string.format(
                "https://api.openweathermap.org/data/2.5/%s?lat=%s&lon=%s&units=metric&appid=%s",
                mode, latitude, longitude, api_key)
            cb(err, uri)
        end,

        -- Download json file
        -- curl or gvfs required
        function(result, cb)
            ---[[
            local cmd = string.format("curl -sf %s", result)
            awful.spawn.easy_async(cmd, function(stdout)
                cb(nil, stdout)
            end)
            --]]
            --[[
            local uri = result
            local file = asyncio.File.new_for_uri(uri)

            file:read_string(function(err, content)
                cb(err, content)
            end)
            --]]
        end,

        -- Write resulted string to file
        function(result, cb)
            file:write(result, "replace", function(err)
                cb(err, result)
            end)
        end,
    },
    -- Cleanup
    function(err, result)
        if err == "from_cache" then
            local signal = string.format("weatherd::%s", mode)
            file:read_string(function(err_inner, data)
                if err_inner then return end

                data = json.decode(data)
                data = neaten_data(data, mode)
                --self[mode] = data
                self:emit_signal(signal, data)
            end)

        elseif result then
            result = json.decode(result)
            result = neaten_data(result, mode)
            --self[mode] = result
            local signal = string.format("weatherd::%s", mode)
            self:emit_signal(signal, result)
            self.retry = 0
        end

    end)
end

function weatherd:start()

    gtimer({
        timeout = 10 * 60,
        autostart = true,
        call_now = true,
        callback = function()
            self:handle_cache("weather")
            self:handle_cache("forecast")
        end,
    })
end

local function new()
    local ret = gobject({})
    gtable.crush(ret, weatherd, true)

    -- dependencies: location
    geoclue:connect_signal("geoclue::ready", function()
        ret:start()
    end)

    return ret
end

if not instance then
    instance = new()
end

return instance
