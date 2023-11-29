local lgi = require("lgi")
local Geoclue = lgi.Geoclue
local gobject = require("gears.object")
local gtable = require("gears.table")

local geoclue = {}
local instance = nil

-- Creates a "GClueSimple" object and subscribes to notify signal on it
-- Passes these signals forward via emit_signal
function geoclue:start()
    Geoclue.Simple.new(
        "awesome",
        Geoclue.AccuracyLevel.NEIGHBORHOOD,
        nil,
        function(_, token)
            local gcs = Geoclue.Simple.new_finish(token)

            function gcs.on_notify()
                self:emit_signal("location::update")
            end

            self.gcs = gcs
            self:emit_signal("location::update")
        end
    )
end

function geoclue:get_latitude()
    return self.gcs:get_location().latitude
end

function geoclue:get_longitude()
    return self.gcs:get_location().longitude
end

local function new()
    local ret = gobject({})
    gtable.crush(ret, geoclue, true)

    return ret
end

if not instance then
    instance = new()
end


return instance
