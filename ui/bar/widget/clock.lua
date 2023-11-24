local awful = require("awful")
local wibox = require("wibox")

local focused = awful.screen.focused()

local clock = wibox.widget({
    format = "%d/%m %H:%M",
    widget = wibox.widget.textclock,
    --[[
    buttons = {
        awful.button({}, 1, function() focused.rightpopup:toggle() focused.centerpopup:toggle() end)
    },
    --]]
})

return clock
