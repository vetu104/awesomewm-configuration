local awful = require("awful")
local beautiful = require("beautiful")
local wibox = require("wibox")
local gshape = require("gears.shape")
local config = require("config")
local dpi = beautiful.xresources.apply_dpi
local monitor = require("helpers.monitor")

local function newgraph(cpu)
    local total_prev
    local idle_prev

    local graph = wibox.widget({
        widget = wibox.widget.graph,
        min_value = 0,
        max_value = 100,
        step_width = dpi(4),
        forced_height = dpi(50),
        forced_width = dpi(230),
        nan_indication = false,
    })

    local text = wibox.widget({
        widget = wibox.widget.textbox,
        text = "0 %",
    })

    local layout = wibox.widget({
        widget = wibox.layout.stack,
        graph,
        text,
    })

    monitor("/proc/stat", function(data)

        local user,nice,system,idle,iowait,irq,softirq,steal,guest,guest_nice = string.match(data, "cpu" .. cpu .. "%s+(%d+)%s+(%d+)%s+(%d+)%s+(%d+)%s+(%d+)%s+(%d+)%s+(%d+)%s+(%d+)%s+(%d+)%s+(%d+)")
        local total = user + nice + system + idle + irq + softirq + steal + guest + guest_nice
        total_prev = total_prev or total
        idle_prev = idle_prev or idle
        local diff_idle = idle - idle_prev
        local diff_total = total - total_prev
        local diff_usage = math.floor(((diff_total - diff_idle) / diff_total) * 100)
        total_prev = total
        idle_prev = idle
        graph:add_value(diff_usage)
        text:set_text(string.format("%s %%", diff_usage))

    end, 2)

    return layout
end

local function topcpu()
    local widget = wibox.widget.textbox()
    widget.text = "kek"

    local cmd = "env LINES=8 top --batch --width --sort-override %CPU"

    awful.spawn.with_line_callback(cmd, { stdout = function(line)
        local pid,user,cpu,command
        if string.find(line, "^%s+%d") then
            --                                             pid     user    pr   ni    virt  res   shr   S    %cpu   %mem      time+   comm
            pid,user,cpu,command = string.match(line, "%s+(%S+)%s+(%S+)%s+%S+%s+%S+%s+%S+%s+%S+%s+%S+%s+%S%s+(%S+)%s+%S+%s+[%d:%.]+%s+(.+)")

            cpu = string.gsub(cpu, ",", ".")
            cpu = cpu / config.cpucount
            cpu = string.format("%.1f", cpu)

            local out = string.format("Top cpu: %s (pid: %s) (user: %s) %s %%", command, pid, user, cpu)
            widget:set_text(out)
        end
    end })

    return widget
end


local gridlayout = wibox.layout.grid()
gridlayout.forced_num_cols = 2
gridlayout.spacing = beautiful.widget_inner_spacing
for i=1,config.cpucount do
    gridlayout:add(newgraph(i-1))
end

local widget = wibox.widget({
    widget = wibox.container.background,
    bg = beautiful.bg_normal,
    shape = gshape.rounded_rect,
    {
        widget = wibox.container.margin,
        margins = beautiful.widget_background_margin,
        {
            layout = wibox.layout.fixed.vertical,
            spacing = beautiful.widget_inner_spacing,
            gridlayout,
            topcpu(),
        },
    },
})

return widget
