local awful = require("awful")

screen.connect_signal("request::desktop_decoration", function(s)
    if screen.instances() == 1 then
        awful.tag({ "1", "2", "3", "4", "5", "6", "7", "8", "9", }, s, awful.layout.layouts[1])
    else
        if s.index == 1 then
            awful.tag({ "1", "2", "3", "4", "5", "6", }, s, awful.layout.layouts[1])
        elseif s.index == 2 then
            awful.tag.add("7", {
                screen = s,
                layout = awful.layout.layouts[2],
                selected = true
            })
            awful.tag.add("8", {
                screen = s,
                layout = awful.layout.layouts[2]
            })
            awful.tag.add("9", {
                screen = s,
                layout = awful.layout.layouts[2]
            })
        end
    end

    -- Create top bar
    s.wibar = require("ui.bar")(s)

    -- Create center popup
    s.centerpopup = require("ui.popup.center")(s)

    -- Create right popup
    s.rightpopup = require("ui.popup.right")(s)
end)
