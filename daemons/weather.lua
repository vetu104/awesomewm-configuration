local lgi = require("lgi")
local Secret = lgi.Secret
local awful = require("awful")
local gfs = require("gears.filesystem")
local gobject = require("gears.object")
local gtable = require("gears.table")
local gtimer = require("gears.timer")
local async = require("async")
local asyncio = {
    File = require("lgi-async-extra.file"),
    Filesystem = require("lgi-async-extra.filesystem"),
}
local geoclue = require("daemons.geoclue")
local json = require("json")
local secret = require("helpers.secret")

local instance = nil
local weatherd = {}

local schema = Secret.Schema.new(
    "org.vetu104", Secret.SchemaFlags.NONE,
    { ["openweather"] = Secret.SchemaAttributeType.STRING }
)

local attrs = { ["openweather"] = "apikey" }

-- Generates timestamps at 15 oclock of next 4 days
-- Counting from tomorrow if 15 oclock today already passed
local function generate_timestamps()
    local hourminsec = os.date("!*t")
    local sec = hourminsec.hour * 60 * 60 + hourminsec.min * 60 + hourminsec.sec
    local diff = sec - 54000

    local firststamp = os.time() - diff + 24 * 60 * 60

    local tbl = {}
    for i=0,3 do
        table.insert(tbl, firststamp + i * 24 * 60 * 60)
    end

    return tbl
end

-- Makes nice tables from the openweather.org json data
-- Forecast mode also selects only the data entries with the timestamps we need
local function neaten_data(data, mode)
    data = json.decode(data)

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
        local timestamps = generate_timestamps()
        data = data.list
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

-- Series of asynchronous functions executed in order. Either reads
-- the weather data from disk or downloads new data depending on the cache age
function weatherd:main_cycle(mode)
    local path = string.format("%s%s.json", gfs.get_cache_dir(), mode)
    local file = asyncio.File.new_for_path(path)

    async.waterfall({
        -- Get cache file last modified and decide if to continue
        -- Our "error" condition here is up to date file
        -- Missing or outdated file is when we continue
        function(cb)
            file:query_info("time::modified", function(err, obj)
                if err and err.code == "NOT_FOUND" then
                    err = nil
                    cb(err)
                else
                    local timeout = 60 * 20 -- 20 mins
                    local time = obj:get_modification_date_time():to_unix()
                    local diff = os.time() - time
                    err = diff < timeout and "cache_up_to_date"
                    cb(err)
                end
            end)
        end,

        -- Compose the api query and download the file via curl
        function(cb)
            local endpoint = "https://api.openweathermap.org/data/2.5/"
            local latitude = geoclue:get_latitude()
            local longitude = geoclue:get_longitude()
            local api_key = self.key

            local uri = string.format(
                "%s%s?lat=%s&lon=%s&units=metric&appid=%s",
                endpoint, mode, latitude, longitude, api_key
            )

            local cmd = string.format("curl -Ssf %s", uri)

            awful.spawn.easy_async(cmd, function(stdout, stderr)
                if #stderr == 0 then stderr = nil end
                cb(stderr, stdout)
            end)
        end,

        -- Write resulted string to the cache file
        -- Also pass the result for cleanup function so we can parse it
        -- immediately
        function(result, cb)
            file:write(result,  function(err)
                cb(err, result)
            end)
        end,
    },
    -- Cleanup
    function(err, result)
        local signal = string.format("weatherd::%s", mode)

        if err == "cache_up_to_date" then
            file:read_string(function(err_inner, data)
                if err_inner then
                    print(err_inner)
                else
                    data = neaten_data(data, mode)

                    self:emit_signal(signal, data)
                end
            end)

        elseif err then
            print("awesome:weatherd", err)

        elseif result then
            result = neaten_data(result, mode)

            self:emit_signal(signal, result)
        end
    end)
end

-- First make sure we have the geolocation and api key information
-- then start the main function
function weatherd:start()
    async.all({
        function(cb)
            geoclue:connect_signal("location::update", function()
                local err = nil
                if not (geoclue:get_latitude() or geoclue:get_longitude()) then
                    err = "missing_location"
                end
                cb(err)
            end)
        end,
        function(cb)
            local finder = secret(schema, attrs)
            finder:connect_signal("secret::key", function(_, key)
                local err = nil
                self.key = key
                if not self.key then
                    err = "missing_key"
                end
                cb(err)
            end)
        end,
    },
    function(err)
        if err then
            print(err)
        else
            gtimer({
                timeout = 10 * 60,
                autostart = true,
                call_now = true,
                callback = function()
                    self:main_cycle("weather")
                    self:main_cycle("forecast")
                end,
            })
        end
    end)
end

local function new()
    local ret = gobject({})
    gtable.crush(ret, weatherd, true)

    return ret
end

if not instance then
    instance = new()
end

return instance
