local awful = require("awful")

local cmd = "free"
local function memory()
    local ret = awful.widget.watch(cmd, 2, function(widget, stdout)
        local words = {}
        for w in stdout:gmatch("%d+") do
            words[#words+1] = w
        end
        local perc = math.floor(words[2]/words[1]*100)
        local text = string.format("%s%%", perc)
        widget:set_text(text)
    end)
    return ret
end

return memory
