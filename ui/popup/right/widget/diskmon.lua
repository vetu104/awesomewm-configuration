local beautiful = require("beautiful")
local awful = require("awful")
local wibox = require("wibox")
local gtimer = require("gears.timer")
local gshape = require("gears.shape")
local dpi = beautiful.xresources.apply_dpi
local config = require("config")

local watchers = {}

local function barwatcher(part)
    local diskbar = wibox.widget({
        layout = wibox.layout.stack,
        set_status = function(self, tbl)
            self.used.text = tbl[1]
            self.total.text = tbl[2]
            self.perc.text = tbl[3] .. "%"
            self.pb.value = tonumber(tbl[3])
        end,
        {
            id = "pb",
            widget = wibox.widget.progressbar,
            min_value = 0,
            max_value = 100,
            value = 50,
            forced_width = dpi(200),
            forced_height = dpi(15),
        },
        {
            id = "used",
            widget = wibox.widget.textbox,
            halign = "left",
            text = "0B",
        },
        {
            id = "total",
            widget = wibox.widget.textbox,
            halign = "right",
            text = "0B",
        },
        {
            id = "perc",
            widget = wibox.widget.textbox,
            halign = "center",
            text = "0%",
        },

    })

    gtimer({
        timeout = 10,
        call_now = true,
        --autostart = true,
        callback = function()
            local cmd = string.format("lsblk --noheadings --output FSUSED,FSSIZE,FSUSE%% %s", part)
            awful.spawn.easy_async(cmd, function(stdout)
                local words = {}
                for w in stdout:gmatch("[%d%a,]+") do
                    words[#words+1] = w
                end
                diskbar:set_status(words)
            end)
        end,
    })

    return diskbar
end

for i,v in ipairs(config.disks) do
    local text = wibox.widget.textbox(v)
    local bar = barwatcher(v)
    watchers[i] = wibox.layout.fixed.vertical()
    watchers[i].children = {
        text,
        bar,
    }
end

local fixedlayout = wibox.layout.fixed.vertical()
for i,v in ipairs(watchers) do
    fixedlayout:insert(i,v)
end

local widget = wibox.widget({
    widget = wibox.container.background,
    bg = beautiful.bg_normal,
    shape = gshape.rounded_rect,
    {
        widget = wibox.container.margin,
        margins = beautiful.widget_background_margin,
        fixedlayout,
    },
})

return widget
