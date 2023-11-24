local awful = require("awful")
local ruled = require("ruled")
local gshape = require("gears.shape")
local gtimer = require("gears.timer")

ruled.client.connect_signal("request::rules", function()

    -- All clients will match this rule
    ruled.client.append_rule({
        id         = "global",
        rule       = {},
        properties = {
            focus     = awful.client.focus.filter,
            raise     = true,
            screen    = awful.screen.preferred,
            placement = awful.placement.no_overlap+awful.placement.no_offscreen,
        },
    })

    -- Rounded corners
    ruled.client.append_rule({
        id          = "rounded",
        rule_any    = { type = { "normal", "dialog", }},
        properties  = {
            shape             = gshape.rounded_rect,
            titlebars_enabled = true,
        },
    })

    -- Titlebarless clients
    ruled.client.append_rule({
        id          = "titlebars_off",
        rule_any    = {
            class       = {
                            "Steam",
                            "firefox",
                            "battle.net.exe",
                            "io.github.celluloid_player.Celluloid",
                            "origin.exe",
                            "Xfce4-power-manager-settings",
                            "eadesktop.exe",
            },
            name        = { "DayZ Launcher", },
        },
        properties  = { titlebars_enabled = false, },
    })

    -- Floating clients
    ruled.client.append_rule({
        id          = "floating",
        rule_any    = {
            instance    = { "copyq", "pinentry", },
            class       = { "Arandr", "Blueman-manager",
                            "Galculator", "Gedit",
                            "Gpick", "Kruler",
                            "Sxiv", "Thunar",
                            "Tor Browser", "Wpa_gui",
                            "Xarchiver", "bf3.exe",
                            "ncmpcpp", "origin.exe",
                            "tsmapplication.exe", "veromix",
                            "xtightvncviewer", },
            name        = {
                            "Event Tester",  -- xev.
                            "^Friends*", -- steam friends
                            "DayZ Launcher",
                            "^DayZ$",
            },
            role        = {
                            "AlarmWindow",    -- Thunderbird's calendar.
                            "ConfigManager",  -- Thunderbird's about:config.
                            "pop-up",         -- e.g. Google Chrome's (detached) Developer Tools.
                            "Organizer",      -- Firefox history, bookmark etc.. windows
            },
        },
        properties  = {
            floating  = true,
            placement = awful.placement.centered + awful.placement.no_overlap + awful.placement.no_offscreen,
        },
    })

    -- Assign tag to some clients
    if screen.instances() == 1 then
        ruled.client.append_rules({
            -----------------------------------------------
            -----------------------------------------------
            {
                id          = "tag5",
                rule_any    = {
                    class       = {
                                    "steam",
                                    "battle.net.exe",
                                    "origin.exe",
                                    "eadesktop.exe",
                                    "ealauncherhelper.exe",
                    },
                },
                properties  = {
                                tag     = "5",
                },
            },
            -----------------------------------------------
            -----------------------------------------------
            {
                id          = "tag8",
                rule_any    = {
                    class       = { "discord", },
                },
                properties  = {
                                tag     = "8",
                },
            },
            -----------------------------------------------
            -----------------------------------------------
            {
                id = "tag9",
                rule_any    = {
                    class       = {
                                    "tsmapplication.exe",
                                    --"Spotify",
                                    "obs",
                    },
                },
                properties  = {
                                tag     = "9",
                },
            },
            -----------------------------------------------
            -----------------------------------------------
        })

        -- Special ruleset for games
        ruled.client.append_rule({
            id          = "game",
            rule_any    = {
                class = {
                            "wowclassic.exe",
                            "etl",
                            "csgo_linux64",
                            "Civ6Sub",
                            "bf3.exe",
                },
                name = {
                            "^DayZ$",
                            "World of Warcraft",
                            "Sid Meier's Civilization VI (DX11)",
                },
            },
            properties  = {
                            tag = "2",
                            titlebars_enabled = false,
                            shape = nil,
                            --shape = gshape.rectangle,
            },
            -- When a client starts up in fullscreen, resize it to cover the fullscreen a short moment later
            -- Fixes wrong geometry when titlebars are enabled
            -- (c) https://github.com/elenapan/
            callback = function(c)
                gtimer.delayed_call(function()
                    if c.valid then
                        c:geometry(c.screen.geometry)
                    end
                end)
            end,
        })
    else
        ruled.client.append_rules({
            -----------------------------------------------
            -----------------------------------------------
            {
                id          = "tag5",
                rule_any    = {
                    class       = {
                                    "steam",
                                    "battle.net.exe",
                                    "origin.exe",
                                    "eadesktop.exe",
                                    "ealauncherhelper.exe",
                    },
                },
                properties  = {
                                tag     = "5",
                                screen  = 1,
                },
            },
            -----------------------------------------------
            -----------------------------------------------
            {
                id          = "tag8",
                rule_any    = {
                    class       = { "discord", },
                },
                properties  = {
                                tag     = "8",
                                screen  = 2,
                },
            },
            -----------------------------------------------
            -----------------------------------------------
            {
                id = "tag9",
                rule_any    = {
                    class       = {
                                    "tsmapplication.exe",
                                    --"Spotify",
                                    "obs",
                    },
                },
                properties  = {
                                tag     = "9",
                                screen  = 2,
                },
            },
            -----------------------------------------------
            -----------------------------------------------
        })

        -- Special ruleset for games
        ruled.client.append_rule({
            id          = "game",
            rule_any    = {
                class = {
                            "wowclassic.exe",
                            "etl",
                            "csgo_linux64",
                            "Civ6Sub",
                            "bf3.exe",
                },
                name = {
                            "^DayZ$",
                            "World of Warcraft",
                            "Sid Meier's Civilization VI (DX11)",
                },
            },
            properties  = {
                            tag = "2",
                            screen = 1,
                            titlebars_enabled = false,
                            shape = gshape.rectangle,
            },
            -- When a client starts up in fullscreen, resize it to cover the fullscreen a short moment later
            -- Fixes wrong geometry when titlebars are enabled
            -- (c) https://github.com/elenapan/
            callback = function(c)
                gtimer.delayed_call(function()
                    if c.valid then
                        c:geometry(c.screen.geometry)
                    end
                end)
            end,
        })
    end
end)
