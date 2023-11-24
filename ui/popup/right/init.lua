local awful = require("awful")
local beautiful = require("beautiful")
local wibox = require("wibox")
local gshape = require("gears.shape")
local dpi = beautiful.xresources.apply_dpi

local diskmon = require("ui.popup.right.widget.diskmon")
local cpumon = require("ui.popup.right.widget.cpumon")
local memorymon = require("ui.popup.right.widget.memorymon")
local tempmon = require("ui.popup.right.widget.tempmon")


local margin = dpi(4)

local function rightpopup(s)
    local panel = awful.popup({
        ontop = true,
        screen = s,
        type = "dock",
        visible = false,
        bg = beautiful.bg_focus,
        shape = gshape.rounded_rect,
        placement = function(self)
            awful.placement.top_right(self, {
                parent = s,
                margins = {
                    top = s.wibox:geometry()["height"] + margin,
                    right = margin,
                },
            })
        end,
        widget = {
            widget = wibox.container.margin,
            margins = beautiful.widget_background_margin,
            {
                layout = wibox.layout.fixed.vertical,
                spacing = beautiful.widget_inner_spacing,
                diskmon,
                cpumon,
                memorymon,
                tempmon,
            },
        },
    })

    function panel:open()
        local focused = awful.screen.focused()
        focused.rightpopup.visible = true
    end

    function panel:close()
        local focused = awful.screen.focused()
        focused.rightpopup.visible = false
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

return rightpopup
