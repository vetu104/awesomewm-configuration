local beautiful = require("beautiful")
local wibox = require("wibox")
local gshape = require("gears.shape")
local config = require("config")
local dpi = beautiful.xresources.apply_dpi
local monitor = require("helpers.monitor")

local function newgraph(sensor)
    local graph = wibox.widget({
        widget = wibox.widget.graph,
        min_value = 0,
        max_value = 100,
        step_width = dpi(4),
        forced_height = dpi(50),
        forced_width = dpi(230),
        nan_indication = false,
    })

    local title = wibox.widget({
        widget = wibox.widget.textbox,
        text = sensor[1],
    })

    local text = wibox.widget({
        widget = wibox.widget.textbox,
        text = "0 c",
    })

    local layout = wibox.widget({
        widget = wibox.layout.fixed.vertical,
        title,
        {
            widget = wibox.layout.stack,
            graph,
            text,
        },
    })

    monitor(sensor[2], function(data)
        data = math.floor(data / 1000)

        graph:add_value(data)
        text:set_text(string.format("%s °C", data))
    end, 2)

    return layout
end


local gridlayout = wibox.layout.grid()
gridlayout.forced_num_cols = 2
gridlayout.spacing = dpi(4)
gridlayout:add(newgraph(config.cpusensor))
if config.gpusensor then
    gridlayout:add(newgraph(config.gpusensor))
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
        },
    },
})

return widget
