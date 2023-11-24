local theme_assets = require("beautiful.theme_assets")
local xresources = require("beautiful.xresources")
local rnotification = require("ruled.notification")
local dpi = xresources.apply_dpi
local gfs = require("gears.filesystem")
local gshape = require("gears.shape")
local theme_path = gfs.get_xdg_config_home() .. "awesome/theme/"
local wallpapers_path = gfs.get_xdg_data_home() .. "wallpapers/"

local theme = {}

-- Nord colors
theme.colors = {
  "#2E3440",
  "#3B4252",
  "#434C5E",
  "#4C566A",
  "#D8DEE9",
  "#E5E9F0",
  "#ECEFF4",
  "#8FBCBB",
  "#88C0D0",
  "#81A1C1",
  "#5E81AC",
  "#BF616A",
  "#D08770",
  "#EBCB8B",
  "#A3BE8C",
  "#B48EAD",
}

-- Overrides
theme.progressbar_bg = theme.colors[1]
theme.progressbar_fg = theme.colors[8]
theme.graph_bg = theme.colors[4]
theme.graph_fg = theme.colors[12]
theme.hotkeys_bg = theme.colors[3]
theme.hotkeys_modifiers_fg = theme.colors[7]

-- Custom
theme.shape = gshape.octogon
theme.widget_background_margin = dpi(12)
theme.widget_inner_spacing = dpi(10)



theme.font          = "sans 11"
theme.bg_normal     = theme.colors[2]
theme.bg_focus      = theme.colors[3]
theme.bg_urgent     = theme.colors[11]
theme.fg_normal     = theme.colors[5]
theme.fg_focus      = theme.colors[8]
theme.fg_urgent     = theme.colors[15]
theme.bg_minimize   = theme.colors[2]
theme.fg_minimize   = theme.colors[5]
theme.useless_gap         = dpi(10)
theme.border_width        = dpi(0)


-- Generate taglist squares:
local taglist_square_size = dpi(4)
theme.taglist_squares_sel = theme_assets.taglist_squares_sel(
    taglist_square_size, theme.fg_normal
)
theme.taglist_squares_unsel = theme_assets.taglist_squares_unsel(
    taglist_square_size, theme.fg_normal
)

theme.menu_submenu_icon = theme_path .. "/submenu.png"
theme.menu_height = dpi(15)
theme.menu_width  = dpi(100)

theme.titlebar_close_button_focus  = theme_path .. "/icons/titlebar/redcircle.png"
theme.titlebar_close_button_normal = theme_path .. "/icons/titlebar/redcircle.png"
theme.titlebar_ontop_button_focus_active  = theme_path .. "/icons/titlebar/yellowcircle.png"
theme.titlebar_ontop_button_normal_active = theme_path .. "/icons/titlebar/yellowcircle.png"
theme.titlebar_ontop_button_focus_inactive  = theme_path .. "/icons/titlebar/graycircle.png"
theme.titlebar_ontop_button_normal_inactive = theme_path .. "/icons/titlebar/graycircle.png"
theme.titlebar_floating_button_focus_active  = theme_path .. "/icons/titlebar/greencircle.png"
theme.titlebar_floating_button_normal_active = theme_path .. "/icons/titlebar/greencircle.png"
theme.titlebar_floating_button_focus_inactive  = theme_path .. "/icons/titlebar/graycircle.png"
theme.titlebar_floating_button_normal_inactive = theme_path .. "/icons/titlebar/graycircle.png"

--theme.wallpaper = gfs.get_random_file_from_dir(wallpapers_path, { "jpg", "png" }, true)
theme.wallpaper = (wallpapers_path .. "0151.jpg")

theme.layout_fairh = theme_path .. "/icons/layoutbox/fairhw.png"
theme.layout_fairv = theme_path .. "/icons/layoutbox/fairvw.png"
theme.layout_floating  = theme_path .. "/icons/layoutbox/floatingw.png"
theme.layout_magnifier = theme_path .. "/icons/layoutbox/magnifierw.png"
theme.layout_max = theme_path .. "/icons/layoutbox/maxw.png"
theme.layout_fullscreen = theme_path .. "/icons/layoutbox/fullscreenw.png"
theme.layout_tilebottom = theme_path .. "/icons/layoutbox/tilebottomw.png"
theme.layout_tileleft   = theme_path .. "/icons/layoutbox/tileleftw.png"
theme.layout_tile = theme_path .. "/icons/layoutbox/tilew.png"
theme.layout_tiletop = theme_path .. "/icons/layoutbox/tiletopw.png"
theme.layout_spiral  = theme_path .. "/icons/layoutbox/spiralw.png"
theme.layout_dwindle = theme_path .. "/icons/layoutbox/dwindlew.png"
theme.layout_cornernw = theme_path .. "/icons/layoutbox/cornernww.png"
theme.layout_cornerne = theme_path .. "/icons/layoutbox/cornernew.png"
theme.layout_cornersw = theme_path .. "/icons/layoutbox/cornersww.png"
theme.layout_cornerse = theme_path .. "/icons/layoutbox/cornersew.png"

-- Generate Awesome icon:
theme.awesome_icon = theme_assets.awesome_icon(
    theme.menu_height, theme.bg_focus, theme.fg_focus
)

-- Define the icon theme for application icons. If not set then the icons
-- from /usr/share/icons and /usr/share/icons/hicolor will be used.
theme.icon_theme = nil

-- Set different colors for urgent notifications.
rnotification.connect_signal('request::rules', function()
    rnotification.append_rule {
        rule       = { urgency = 'critical' },
        properties = { bg = '#ff0000', fg = '#ffffff' }
    }
end)


return theme
