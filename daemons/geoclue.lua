local lgi = require("lgi")
local Gio, Geoclue = lgi.Gio, lgi.Geoclue
local gtable = require("gears.table")
local gobject = require("gears.object")

local instance = nil
local geoclue = {}

geoclue.firstrun = true

function geoclue:get_lock()
    Geoclue.LocationProxy.new_for_bus(
        Gio.BusType.SYSTEM, Gio.DBusProxyFlags.NONE,
        "org.freedesktop.GeoClue2", self.locpath,
        nil, function(_, token)
            local location = Geoclue.LocationProxy.new_for_bus_finish(token)
            if not location then return end
            self.old_location = self.location
            self.location = location
            self.last = os.time()

            local latitude = location.latitude
            local longitude = location.longitude
            if self.firstrun then
                self:emit_signal("geoclue::ready", latitude, longitude)
                self.firstrun = false
            else
                self:emit_signal("geoclue::update", latitude, longitude)
            end
            self.latitude = latitude
            self.longitude = longitude
        end
    )
end

function geoclue:init_client()
    Geoclue.ClientProxy.create("awesome", Geoclue.AccuracyLevel.NEIGHBORHOOD, nil, function(_, token)
        local client = Geoclue.ClientProxy.create_finish(token)
        if not client then return end

        function client.on_location_updated(_,old_loc, new_loc)
            self.locpath = new_loc
            self.old_locpath = old_loc
            self:get_lock()
        end

        client:call_start()

        self.client = client
    end)
end

function geoclue:get_latitude()
    return self.latitude
end

function geoclue:get_longitude()
    return self.longitude
end

local function new()
    local ret = gobject({})
    gtable.crush(ret, geoclue, true)
    ret:init_client()

    return ret
end

if not instance then
    instance = new()
end


return instance
