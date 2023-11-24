local wibox = require("wibox")
local gears = require("gears")
local beautiful = require("beautiful")
local gshape = require("gears.shape")
local dpi = beautiful.xresources.apply_dpi
local config_dir = gears.filesystem.get_configuration_dir()
local widget_icon_dir = config_dir .. "theme/icons/weather/"
local weatherd = require("daemons.weather")

local icon_tbl = {
    ["01d"] = "sun_icon.svg",
    ["01n"] = "moon_icon.svg",
    ["02d"] = "dfew_clouds.svg",
    ["02n"] = "nfew_clouds.svg",
    ["03d"] = "dscattered_clouds.svg",
    ["03n"] = "nscattered_clouds.svg",
    ["04d"] = "dbroken_clouds.svg",
    ["04n"] = "nbroken_clouds.svg",
    ["09d"] = "dshower_rain.svg",
    ["09n"] = "nshower_rain.svg",
    ["10d"] = "d_rain.svg",
    ["10n"] = "n_rain.svg",
    ["11d"] = "dthunderstorm.svg",
    ["11n"] = "nthunderstorm.svg",
    ["13d"] = "snow.svg",
    ["13n"] = "snow.svg",
    ["50d"] = "dmist.svg",
    ["50n"] = "nmist.svg",
    ["..."] = "weather-error.svg",
}

--local function create_icon
local icons = {}
for i=1,4 do
    local id = string.format("icon%s", i)
    icons[i] = wibox.widget({
        widget        = wibox.widget.imagebox,
        id            = id,
        image         = widget_icon_dir .. "weather-error.svg",
        halign        = "center",
        forced_height = dpi(45),
        forced_width  = dpi(45),
    })
end

local temperatures = {}
for i=1,4 do
    local id = string.format("icon%s", i)
    temperatures[i] = wibox.widget({
        widget = wibox.widget.textbox,
        id 	   = id,
        text   = "-273.15 °C (-273.15 °C)",
        halign = "center",
    })
end

local dates = {}
for i=1,4 do
    local id = string.format("date%s", i)
    dates[i] = wibox.widget({
        widget = wibox.widget.textbox,
        id 	   = id,
        text   = "Pitkäperjantai",
    })
end


weatherd:connect_signal("weatherd::forecast", function(_, data)

    for i=1,4 do
        local widget_icon_name = icon_tbl[data[i].icon]
        icons[i]:set_image(widget_icon_dir .. widget_icon_name)

        local temperature = string.format("%s (%s)", math.floor(data[i].temp), math.floor(data[i].feels_like))
        temperatures[i]:set_text(temperature)

        local day = os.date("%A", data[i].dt)
        dates[i]:set_text(day)
    end

end)

local forecast =  wibox.widget({
    widget = wibox.container.background,
    bg = beautiful.bg_normal,
    shape = gshape.rounded_rect,
    {
        widget = wibox.container.margin,
        margins = beautiful.widget_background_margin,
        {
            layout = wibox.layout.fixed.horizontal,
            spacing = dpi(50),
            {
               layout = wibox.layout.fixed.vertical,
               spacing = beautiful.widget_inner_spacing,
               dates[1],
               icons[1],
               temperatures[1],
            },
            {
               layout = wibox.layout.fixed.vertical,
               spacing = beautiful.widget_inner_spacing,
               dates[2],
               icons[2],
               temperatures[2],
            },
            {
               layout = wibox.layout.fixed.vertical,
               spacing = beautiful.widget_inner_spacing,
               dates[3],
               icons[3],
               temperatures[3],
            },
            {
               layout = wibox.layout.fixed.vertical,
               spacing = beautiful.widget_inner_spacing,
               dates[4],
               icons[4],
               temperatures[4],
            },

        },
    },
})

return forecast
