local awful = require("awful")
local wibox = require("wibox")
local gshape = require("gears.shape")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi
local weather = require("ui.popup.center.widget.weather")
local forecast = require("ui.popup.center.widget.forecast")
local calendar = require("ui.popup.center.widget.calendar")

local margin = dpi(4)

local centerpopup = function(s)

    local panel = awful.popup({
        ontop           = true,
        screen          = s,
        shape           = gshape.rounded_rect,
        bg              = beautiful.bg_focus,
        type            = "dock",
        visible         = false,
        placement       = function(popup)
            awful.placement.top(popup, {
                parent = s,
                margins = { top = s.wibox:geometry()["height"] + margin, },
            })
        end,
        widget = {
            widget  = wibox.container.margin,
            margins = beautiful.widget_background_margin,
            {
                layout = wibox.layout.fixed.vertical,
                spacing = beautiful.widget_inner_spacing,
                {
                    layout  = wibox.layout.fixed.horizontal,
                    spacing = beautiful.widget_inner_spacing,
                    calendar,
                    weather,
                },
                forecast,
            },
        },
    })

    function panel:open()
        local focused = awful.screen.focused()
        focused.centerpopup.visible = true
        calendar:set_date(os.date("*t"))
    end

    function panel:close()
        local focused = awful.screen.focused()
        focused.centerpopup.visible = false
    end

    function panel:toggle()
        self.opened = not self.opened
        if self.opened then
            self:open()
        else
            self:close()
        end
    end
    return panel
end

return centerpopup
