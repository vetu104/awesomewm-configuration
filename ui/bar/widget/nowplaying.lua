local wibox = require("wibox")
local bling = require("bling")
local playerctl = bling.signal.playerctl.lib()

local nowplaying = wibox.widget({
    markup = "paused",
    halign = "center",
    valign = "center",
    widget = wibox.widget.textbox,
})

playerctl:connect_signal("metadata", function(_, title, artist)
    nowplaying:set_markup_silently(title .. " - " .. artist)
end)

playerctl:connect_signal("playback_status", function(playing)
    if not playing then
        nowplaying:set_markup_silently("paused")
    end
end)

return nowplaying
