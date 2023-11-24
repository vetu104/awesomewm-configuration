local wibox = require("wibox")
local beautiful = require("beautiful")
local gshape = require("gears.shape")
local dpi = beautiful.xresources.apply_dpi

local calendar = wibox.widget({
    id            = "calendar",
    font          = beautiful.font,
    date          = os.date("*t"),
    spacing       = dpi(10),
    widget        = wibox.widget.calendar.month,
})

local widget = wibox.widget({
    widget = wibox.container.background,
    bg     = beautiful.bg_normal,
    shape = gshape.rounded_rect,
    {
        widget = wibox.container.margin,
        margins = beautiful.widget_background_margin,
        calendar,
    },
})

function widget:set_date(date)
    calendar:set_date(date)
end

return widget
