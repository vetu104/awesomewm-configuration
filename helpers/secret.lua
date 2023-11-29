local lgi = require("lgi")
local Secret = lgi.Secret
local gtimer = require("gears.timer")

local function findkey(schema, attrs)
    local timer = gtimer({
        timeout = 5,
        autostart = true,
        callback = function(tmr)
            Secret.password_lookup(schema, attrs, nil, function(_, token)
                local key = Secret.password_lookup_finish(token)
                if key then
                    tmr:emit_signal("secret::key", key)
                    tmr:stop()
                end
            end)
        end,
    })

    return timer
end

return findkey
