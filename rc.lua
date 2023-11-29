local awful = require("awful")
local beautiful = require("beautiful")
local gears = require("gears")
local naughty = require("naughty")
local ruled = require("ruled")
local wibox = require("wibox")
local config = require("config")
local dpi = beautiful.xresources.apply_dpi
require("awful.autofocus")
require("awful.hotkeys_popup.keys")
-- Start daemons
require("daemons.geoclue"):start()
require("daemons.weather"):start()


-- {{{ Error handling
naughty.connect_signal("request::display_error", function(message, startup)
    naughty.notification {
        urgency = "critical",
        title   = "Oops, an error happened"..(startup and " during startup!" or "!"),
        message = message,
    }
end)
-- }}}

-- {{{ Init theme
beautiful.init(gears.filesystem.get_xdg_config_home() .. "awesome/theme/init.lua")
-- }}}

-- {{{ Wallpaper
screen.connect_signal("request::wallpaper", function(s)
    awful.wallpaper({
        screen = s,
        widget = {
            horizontal_fit_policy = "fit",
            vertical_fit_policy = "fit",
            image     = beautiful.wallpaper,
            widget    = wibox.widget.imagebox,
        }
    })
end)
-- }}}

-- {{{ Create status bar (bar.lua)
require("ui")
-- }}}

--- {{{ Set keybindings and mousebuttons (keys.lua)
require("keys")
--- }}}

--- {{{ Set client rules (rules.lua)
require("rules")
--- }}}


-- {{{ Titlebars
-- Add a titlebar if titlebars_enabled is set to true in the rules.
client.connect_signal("request::titlebars", function(c)
    -- buttons for the titlebar
    local buttons = {
        awful.button({ }, 1, function()
            c:activate({ context = "titlebar", action = "mouse_move" })
        end),
        awful.button({ }, 3, function()
            c:activate({ context = "titlebar", action = "mouse_resize" })
        end),
    }
    local tb = awful.titlebar(c, {
    size = dpi(28)
    })
    tb.widget = {
        { -- Left
            wibox.container.margin(awful.titlebar.widget.closebutton(c), dpi(6), dpi(6), dpi(6), dpi(6)),
            wibox.container.margin(awful.titlebar.widget.ontopbutton(c), dpi(6), dpi(6), dpi(6), dpi(6)),
            wibox.container.margin(awful.titlebar.widget.floatingbutton(c), dpi(6), dpi(6), dpi(6), dpi(6)),
            --awful.titlebar.widget.iconwidget(c),
            layout  = wibox.layout.fixed.horizontal
        },
        { -- Middle
            { -- Title
                align  = "center",
                widget = awful.titlebar.widget.titlewidget(c)
            },
            buttons = buttons,
            layout  = wibox.layout.flex.horizontal
        },
        { -- Right
            buttons = buttons,
            layout = wibox.layout.fixed.horizontal
        },
        layout = wibox.layout.align.horizontal
    }
end)
-- }}}

-- {{{ Notifications
ruled.notification.connect_signal('request::rules', function()
    -- All notifications will match this rule.
    ruled.notification.append_rule({
        rule       = { },
        properties = {
            screen           = awful.screen.preferred,
            implicit_timeout = 5,
        }
    })
end)

naughty.connect_signal("request::display", function(n)
    naughty.layout.box({ notification = n })
end)
-- }}}

-- Enable sloppy focus, so that focus follows mouse.
client.connect_signal("mouse::enter", function(c)
    c:activate({ context = "mouse_enter", raise = false })
end)

-- Detect clients that spawn without a class
-- (c) https://github.com/elenapan
client.connect_signal("request::manage", function(c)
    if not c.class then
        c.minimized = true
        c:connect_signal("property::class", function()
            c.minimized = false
            ruled.client.apply(c)
        end)
    end
end)

require("autorun")
