local awful = require("awful")
local config = require("config")

local apps = config.autorun

local run_once = function(cmd)
    local findme = cmd
    local firstspace = cmd:find(" ")
    if firstspace then
        findme = cmd:sub(0, firstspace - 1)
    end

    awful.spawn.easy_async_with_shell(
        string.format("ps aux | grep '%s' | grep -v 'grep'", findme, cmd),
        function(stdout)
            if stdout == "" or stdout == nil then
                awful.spawn(cmd, false)
            end
        end
    )
end

for _,v in ipairs(apps) do
    run_once(v)
end
