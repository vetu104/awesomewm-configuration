local awful = require("awful")

local function diskspace(disk)
    local cmd = string.format("df --output=avail %s", disk)
    local ret =  awful.widget.watch(cmd, 2, function(widget, stdout)
        local label = disk
        local df = math.floor(tonumber(stdout:match("(%d+)")) / 1024^2)
        local text = stdout.format("%s: %sG", label, tostring(df))
        widget:set_text(text)
    end)
    return ret
end

return diskspace
