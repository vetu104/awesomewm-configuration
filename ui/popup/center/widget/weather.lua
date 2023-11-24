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

local weather_icon_widget = wibox.widget({
    widget        = wibox.widget.imagebox,
    id            = "icon",
    image         = widget_icon_dir .. "weather-error.svg",
    forced_height = dpi(45),
    forced_width  = dpi(45),
})

local sunrise_icon_widget = wibox.widget({
    widget        = wibox.widget.imagebox,
    id            = "sunrise_icon",
    image         = widget_icon_dir .. "sunrise.svg",
    forced_height = dpi(18),
    forced_width  = dpi(18),
})

local sunset_icon_widget = wibox.widget({
    widget        = wibox.widget.imagebox,
    id            = "sunset_icon",
    image         = widget_icon_dir .. "sunset.svg",
    forced_height = dpi(18),
    forced_width  = dpi(18),
})

local weather_desc_temp = wibox.widget({
    widget = wibox.widget.textbox,
    id 	   = "description",
    text   = "Vettä Esterin perseestä, -273.15 °C",
})

local weather_location = wibox.widget({
    widget = wibox.widget.textbox,
    id 	   = "location",
    text   = "Nevada, Huitsin",
})

local weather_sunrise = wibox.widget({
	widget = wibox.widget.textbox,
	text   = "00:00",
})

local weather_sunset = wibox.widget({
	widget = wibox.widget.textbox,
	text   = "00:00",
})

weatherd:connect_signal("weatherd::weather", function(_, data)
    local widget_icon_name = icon_tbl[data.icon]

    weather_icon_widget:set_image(widget_icon_dir .. widget_icon_name)

    local description = string.format("%s, %s°C", data.weather, math.floor(data.temp))
    weather_desc_temp:set_text(description)

    local location = string.format("%s, %s", data.city, data.country)
    weather_location:set_text(location)

    local sunrise = os.date("%H:%M", data.sunrise)
    weather_sunrise:set_text(sunrise)

    local sunset = os.date("%H:%M", data.sunset)
    weather_sunset:set_text(sunset)
end)

--[[
local weather_forecast_tooltip = awful.tooltip({
	text                = 'Loading...',
	objects             = {weather_icon_widget},
	mode                = 'outside',
	align               = 'right',
	preferred_positions = {'left', 'right', 'top', 'bottom'},
	margin_leftright    = dpi(8),
	margin_topbottom    = dpi(8),
})
--]]

local weather_report =  wibox.widget({
    widget = wibox.container.background,
    bg = beautiful.bg_normal,
    shape = gshape.rounded_rect,
    {
        widget = wibox.container.margin,
        margins = beautiful.widget_background_margin,
        {
            widget = wibox.container.place,
            {
                layout  = wibox.layout.fixed.horizontal,
                spacing = dpi(10),
                weather_icon_widget,
                {
                    layout = wibox.layout.fixed.vertical,
                    weather_location,
                    weather_desc_temp,
                    {
                        layout  = wibox.layout.fixed.horizontal,
                        spacing = dpi(7),
                        {
                            layout  = wibox.layout.fixed.horizontal,
                            spacing = dpi(3),
                            sunrise_icon_widget,
                            weather_sunrise,
                        },
                        {
                            layout  = wibox.layout.fixed.horizontal,
                            spacing = dpi(3),
                            sunset_icon_widget,
                            weather_sunset,
                        },
                    },
                },
            },
        },
    },
})

return weather_report
