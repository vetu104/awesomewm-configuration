local awful = require("awful")
local beautiful = require("beautiful")
local wibox = require("wibox")
local gshape = require("gears.shape")
local dpi = beautiful.xresources.apply_dpi

local taglist = require("ui.bar.widget.taglist")
local clock = require("ui.bar.widget.clock")
local diskspace1 = require("ui.bar.widget.diskspace")("/home")
local diskspace2 = require("ui.bar.widget.diskspace")("/mnt/disk1")
local sysload = require("ui.bar.widget.sysload")()
local memory = require("ui.bar.widget.memory")()
local layoutbox = require("ui.bar.widget.layoutbox")

local focused = awful.screen.focused()
local margin = dpi(10)

local function left_widgets(s)
    local widget = wibox.widget({
        widget = wibox.container.margin,
        left = margin,
        {
            widget = wibox.container.background,
            bg = beautiful.bg_focus,
            shape = gshape.rounded_rect,
            {
                widget = wibox.container.margin,
                left = margin,
                right = margin,
                taglist(s),
            },
        },
    })

    return widget
end

local center_widgets = wibox.widget({
    widget = wibox.container.background,
    bg = beautiful.bg_focus,
    shape = gshape.rounded_rect,
    {
        widget = wibox.container.margin,
        left = margin,
        right = margin,
        clock,
    },
})

center_widgets.buttons = {
    awful.button({}, 1, function() focused.centerpopup:toggle() end)
}

local function right_widgets(s)
    local left = wibox.widget({
        layout = wibox.layout.fixed.horizontal,
        spacing = margin,
        {
            widget = wibox.container.background,
            bg = beautiful.bg_focus,
            shape = gshape.rounded_rect,
            spacing = margin,
            {
                widget = wibox.container.margin,
                left = margin,
                right = margin,
                {
                    layout = wibox.layout.fixed.horizontal,
                    spacing = margin,
                    diskspace1,
                    diskspace2,
                    sysload,
                    memory,
                },
            },
        },
    })

    left.buttons = {
        awful.button({}, 1, function() focused.rightpopup:toggle() end)
    }

    local center = wibox.widget.systray()

    local right = layoutbox(s)

    local widget = wibox.widget({
        layout = wibox.layout.fixed.horizontal,
        spacing = margin,
        left,
        center,
        right,
    })

    return widget
end

local function bar(s)
    s.wibox = awful.wibar({
        position = "top",
        screen   = s,
        --bg       = beautiful.bg_normal,
        widget   = {
            layout = wibox.layout.align.horizontal,
            expand = "none",
            left_widgets(s),
            center_widgets,
            right_widgets(s),
        },
    })
end

return bar
