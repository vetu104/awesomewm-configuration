local awful = require("awful")
local hotkeys_popup = require("awful.hotkeys_popup")

local config = require("config")

-- Global general keybindings
awful.keyboard.append_global_keybindings({
    awful.key({ config.modkey                },  "s",                hotkeys_popup.show_help,
        { description = "show help",            group = "awesome"   }),
    awful.key({ config.modkey, "Control"     },  "r",                awesome.restart,
        { description = "reload awesome",       group = "awesome"   }),
    awful.key({ config.modkey, "Shift"       },  "e",                awesome.quit,
        { description = "quit awesome",         group = "awesome"   }),
    awful.key({ config.modkey                },  "Return",           function() awful.spawn(config.terminal) end,
        { description = "open a terminal",      group = "launcher"  }),
    awful.key({ config.modkey                },  "d",                function() awful.spawn("rofi -show drun") end,
        { description = "open rofi",            group = "launcher"  }),
    awful.key({ config.modkey                },  "e",                function() awful.spawn(config.terminal.." --class ncmpcpp -e ncmpcpp") end,
        { description = "open ncmpcpp",         group = "launcher"  }),
    awful.key({                             },  "Print",            function() awful.spawn.with_shell("scrot -M 0 ~/Pictures/Screenshots/%Y-%m-%dT%H%M%S-screenshot.png") end,
        { description = "take a screenshot",    group = "media"     }),
    awful.key({ config.modkey                },  "Print",            function() awful.spawn.with_shell("scrot -s -f ~/Pictures/Screenshots/%Y-%m-%dT%H%M%S-screenshot.png") end,
        { description = "take a screenshot",    group = "media"     }),
})

-- Media keybindings
awful.keyboard.append_global_keybindings({
    awful.key({},   "XF86AudioRaiseVolume",     function() awful.spawn("mpc volume +5", false) end,
        { description = "raise music volume",   group="media" }),
    awful.key({},   "XF86AudioLowerVolume",     function() awful.spawn("mpc volume -5", false) end,
        { description = "lower music volume",   group = "media" }),
    awful.key({},   "XF86AudioMute",            function() awful.spawn("pactl set-sink-mute 0 toggle") end,
        { description = "toggle mute",          group = "media" }),
    awful.key({},   "XF86AudioPlay",            function() awful.spawn("mpc toggle", false) end,
        { description = "pause media",          group = "media" }),
    awful.key({},   "XF86AudioNext",            function() awful.spawn("mpc next", false) end,
        { description = "next media item",      group = "media" } ),
    awful.key({},   "XF86AudioPrev",            function() awful.spawn("mpc prev", false) end,
        { description = "previous media item",  group = "media" }),
})

-- Focus related keybindings
awful.keyboard.append_global_keybindings({
    awful.key({ config.modkey            },  "j",    function() awful.client.focus.byidx(1) end,
        { description = "focus next by index",      group = "client"    }),
    awful.key({ config.modkey            },  "k",    function() awful.client.focus.byidx(-1) end,
        { description = "focus previous by index",  group = "client"    }),
    awful.key({ config.modkey, "Control" },  "j",    function() awful.screen.focus_relative(1) end,
        { description = "focus next screen",        group = "screen"    }),
    awful.key({ config.modkey, "Control" },  "k",    function() awful.screen.focus_relative(-1) end,
        { description = "focus previous screen",    group = "screen"    }),
    awful.key({ config.modkey            },  "u",    awful.client.urgent.jumpto,
        { description = "jump to urgent client",    group = "client"    }),
    awful.key({ config.modkey            },  "Tab",  function() awful.client.focus.history.previous(); if client.focus then client.focus:raise(); end; end,
        { description = "go back",                  group = "client"    }),
})

-- Client manipulation keybindings
awful.keyboard.append_global_keybindings({
    awful.key({ config.modkey, "Shift"   },  "j",    function() awful.client.swap.byidx(1) end,
        { description = "swap with next client by index",       group = "client" }),
    awful.key({ config.modkey, "Shift"   },  "k",    function () awful.client.swap.byidx(-1) end,
        { description = "swap with previous client by index",   group = "client" }),
    awful.key({ config.modkey, "Control" },  "n",    function() local c = awful.client.restore(); if c then c:activate({ raise = true, context = "key.unminimize" }); end; end,
        { description = "restore minimized",                    group = "client" }),
})

-- Layout manipulation keybindings
awful.keyboard.append_global_keybindings({
    awful.key({ config.modkey            },  "l",        function() awful.tag.incmwfact(0.05) end,
        { description = "increase master width factor",             group = "layout" }),
    awful.key({ config.modkey            },  "h",        function() awful.tag.incmwfact(-0.05) end,
        { description = "decrease master width factor",             group = "layout" }),
    awful.key({ config.modkey, "Shift"   },  "h",        function() awful.tag.incnmaster(1, nil, true) end,
        { description = "increase the number of master clients",    group = "layout" }),
    awful.key({ config.modkey, "Shift"   },  "l",        function() awful.tag.incnmaster(-1, nil, true) end,
        { description = "decrease the number of master clients",    group = "layout" }),
    awful.key({ config.modkey, "Control" },  "l",        function() awful.tag.incncol(1, nil, true) end,
        { description = "increase the number of columns",           group = "layout" }),
    awful.key({ config.modkey, "Control" },  "h",        function() awful.tag.incncol(-1, nil, true) end,
        { description = "decrease the number of columns",           group = "layout" }),
    awful.key({ config.modkey            },  "space",    function() awful.layout.inc(1) end,
        { description = "select next",                              group = "layout" }),
    awful.key({ config.modkey, "Shift"   },  "space",    function() awful.layout.inc(-1) end,
        { description = "select previous",                          group = "layout" }),
})

-- Tag manipulation
awful.keyboard.append_global_keybindings({
    awful.key({
        modifiers   = { config.modkey },
        keygroup    = "numrow",
        description = "only view tag",
        group       = "tag",
        on_press    = function(index)
            local tag = root.tags()[index]
            if tag then
                local screen = tag.screen
                tag:view_only()
                if awful.screen.focused() ~= screen then
                    awful.screen.focus(screen)
                end
            end
        end
    }),
    awful.key({
        modifiers   = { config.modkey, "Control" },
        keygroup    = "numrow",
        description = "toggle tag",
        group       = "tag",
        on_press    = function(index)
            local tag = root.tags()[index]
            if tag then
                awful.tag.viewtoggle(tag)
            end
        end
    }),
    awful.key({
        modifiers = { config.modkey, "Shift" },
        keygroup    = "numrow",
        description = "move focused client to tag",
        group       = "tag",
        on_press    = function(index)
            if client.focus then
                local tag = root.tags()[index]
                if tag then
                    client.focus:move_to_tag(tag)
                    local screen = tag.screen
                    if awful.screen.focused() ~= screen then
                        awful.screen.focus(screen)
                    end
                end
            end
        end
    })
})


-- Client keybindings
client.connect_signal("request::default_keybindings", function()
    awful.keyboard.append_client_keybindings({
        awful.key({ config.modkey            },  "f",        function(c) c.fullscreen = not c.fullscreen; c:raise(); end,
            { description = "toggle fullscreen",            group = "client" }),
        awful.key({ config.modkey, "Shift"   },  "q",        function(c) c:kill() end,
            { description = "close",                        group = "client" }),
        awful.key({ config.modkey, "Control" },  "space",    awful.client.floating.toggle,
            { description = "toggle floating",              group = "client" }),
        awful.key({ config.modkey, "Control" },  "Return",   function(c) c:swap(awful.client.getmaster()) end,
            { description = "move to master",               group = "client" }),
        awful.key({ config.modkey            },  "o",        function(c) c:move_to_screen() end,
            { description = "move to screen",               group = "client" }),
        awful.key({ config.modkey            },  "t",        function(c) c.ontop = not c.ontop end,
            { description = "toggle keep on top",           group = "client" }),
        awful.key({ config.modkey            },  "n",        function(c) c.minimized = true end,
            { description = "minimize",                     group = "client" }),
        awful.key({ config.modkey            },  "m",        function(c) c.maximized = not c.maximized; c:raise(); end,
            { description = "(un)maximize",                 group = "client" }),
        awful.key({ config.modkey, "Control" },  "m",        function(c) c.maximized_vertical = not c.maximized_vertical; c:raise(); end,
            { description = "(un)maximize vertically",      group = "client" }),
        awful.key({ config.modkey, "Shift"   },  "m",        function(c) c.maximized_horizontal = not c.maximized_horizontal; c:raise(); end,
            { description = "(un)maximize horizontally",    group = "client" }),
        })
end)

-- Default client mouse buttons
client.connect_signal("request::default_mousebindings", function()
    awful.mouse.append_client_mousebindings({
    awful.button({              }, 1, function(c) c:activate({ context = "mouse_click" }) end),
    awful.button({ config.modkey }, 1, function(c) c:activate({ context = "mouse_click", action = "mouse_move" }) end),
    awful.button({ config.modkey }, 3, function(c) c:activate({ context = "mouse_click", action = "mouse_resize"}) end)
})
end)
