local awful = require("awful")

local function sysload()
    local cmd = "cat /proc/loadavg"
    local ret = awful.widget.watch(cmd, 2, function(widget, stdout)
        local text = stdout:match("([^%s]+ [^%s]+ [^%s]+)")
        widget:set_text(text)
    end)
    return ret
end

return sysload
