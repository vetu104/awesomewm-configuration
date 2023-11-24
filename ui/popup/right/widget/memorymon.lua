local beautiful = require("beautiful")
local awful = require("awful")
local wibox = require("wibox")
local gshape = require("gears.shape")
local dpi = beautiful.xresources.apply_dpi
local monitor = require("helpers.monitor")

local function tomib(kib)
    return math.floor(kib / 1024)
end

local function barwatcher()
    local membar = wibox.widget({
        layout = wibox.layout.fixed.vertical,
        spacing = dpi(4),
        set_status = function(self, memtotal, memused, memperc, memunit, swaptotal, swapused, swapperc, swapunit)
            self.mem.memused.text = memused .. " " .. memunit
            self.mem.memtotal.text = memtotal .. " " .. memunit
            self.mem.memperc.text = math.floor(memperc * 100) .. "%"
            self.mem.mempb.value = memperc
            self.swap.swapused.text = swapused .. " " .. swapunit
            self.swap.swaptotal.text = swaptotal .. " " .. swapunit
            self.swap.swapperc.text = math.floor(swapperc * 100) .. "%"
            self.swap.swappb.value = swapperc
        end,
        {
            widget = wibox.widget.textbox,
            text = "Memory",
        },
        {
            layout = wibox.layout.stack,
            id = "mem",
            {
                id = "mempb",
                widget = wibox.widget.progressbar,
                min_value = 0,
                max_value = 1,
                value = 50,
                forced_width = dpi(200),
                forced_height = dpi(15),
            },
            {
                id = "memused",
                widget = wibox.widget.textbox,
                halign = "left",
                text = "0B",
            },
            {
                id = "memtotal",
                widget = wibox.widget.textbox,
                halign = "right",
                text = "0B",
            },
            {
                id = "memperc",
                widget = wibox.widget.textbox,
                halign = "center",
                text = "0%",
            },
        },
        {
            widget = wibox.widget.textbox,
            text = "Swap",
        },
        {
            layout = wibox.layout.stack,
            id = "swap",
            {
                id = "swappb",
                widget = wibox.widget.progressbar,
                min_value = 0,
                max_value = 1,
                value = 50,
                forced_width = dpi(200),
                forced_height = dpi(15),
            },
            {
                id = "swapused",
                widget = wibox.widget.textbox,
                halign = "left",
                text = "0B",
            },
            {
                id = "swaptotal",
                widget = wibox.widget.textbox,
                halign = "right",
                text = "0B",
            },
            {
                id = "swapperc",
                widget = wibox.widget.textbox,
                halign = "center",
                text = "0%",
            },
        },
    })

    monitor("/proc/meminfo", function(data)

        local memunit = "kiB"
        local swapunit = "kiB"
        local memtotal,memfree,swaptotal,swapfree = string.match(data, "MemTotal:%s+(%d+).+MemAvailable:%s+(%d+).+SwapTotal:%s+(%d+).+SwapFree:%s+(%d+)")
        local memused = memtotal - memfree
        local memperc = memused / memtotal
        local swapused = swaptotal - swapfree
        local swapperc = swapused / swaptotal

        if tomib(memused) > 0 then
            memunit = "MiB"
            memtotal = tomib(memtotal)
            memused = tomib(memused)
        end

        if tomib(swapused) > 0 then
            swapunit = "MiB"
            swaptotal = tomib(swaptotal)
            swapused = tomib(swapused)
        end

        membar:set_status(memtotal, memused, memperc, memunit, swaptotal, swapused, swapperc, swapunit)

    end, 2)
    return membar
end

local function topmem()
    local widget = wibox.widget.textbox()
    widget.text = "kek"
    local pid, user, mem, command

    local cmd = "env LINES=8 top --batch --width --sort-override %MEM"

    awful.spawn.with_line_callback(cmd, { stdout = function(line)
        if string.find(line, "^%s+%d") then
            --                                             pid     user    pr   ni    virt  res   shr   S    %cpu   %mem      time+   comm
            pid,user,mem,command = string.match(line, "%s+(%S+)%s+(%S+)%s+%S+%s+%S+%s+%S+%s+%S+%s+%S+%s+%S%s+%S+%s+(%S+)%s+[%d:%.]+%s+(.+)")
        end

        local out = string.format("Top mem: %s (pid: %s) (user: %s) %s %%", command, pid, user, mem)
        widget:set_text(out)
    end })

    return widget
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
            barwatcher(),
            topmem(),
        },
    },
})

return widget
