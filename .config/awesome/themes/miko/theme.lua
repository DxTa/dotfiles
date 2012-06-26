
theme = {}
theme.wallpaper_cmd = { "feh --bg-fill /home/dxta/.config/awesome/themes/miko/background.jpg" }
theme.icon_theme = nil

confdir = awful.util.getdir("config") .. "/themes/miko"

theme.font          = "terminus 9"

-- {{{ Colors
theme.fg_normal = "#D5D5D5"
theme.fg_focus  = "#a86500"
theme.fg_urgent = "#990000"
theme.bg_normal = "#151515f0"
-- theme.bg_focus  = ""
theme.bg_urgent = "#151515aa"
-- }}}
-- theme.bg_normal     = "#050c12"
theme.bg_focus      = theme.bg_normal
-- theme.bg_focus      = "#050c12"
-- theme.bg_urgent     = theme.bg_normal
theme.bg_minimize   = theme.bg_normal
theme.bg_systray    = theme.bg_normal

-- theme.fg_normal     = "#e9eae4"
-- theme.fg_focus      = "#81e1dd"
-- theme.fg_urgent     = theme.fg_focus
theme.fg_minimize   = theme.fm_focus

theme.border_width  = 1
-- theme.border_normal = "#000000"
-- theme.border_focus  = "#9069d0"
-- theme.border_marked = theme.border_focus
theme.border_normal = "#151515"
theme.border_focus  = "#303030"
theme.border_marked = "#CC9393"

theme.bar_height  = 19
theme.menu_height = 20
theme.menu_width  = 100

-- Icon Settings
theme.widget_awesome = confdir .. "/icons/arch_10x10.png"
theme.widget_mpd = confdir .. "/icons/note.png"
theme.widget_clock = confdir .. "/icons/clock.png"
theme.widget_bat = confdir .. "/icons/bat_full_02.png"
theme.widget_sep = confdir .. "/icons/seperator.png"
theme.widget_temp = confdir .. "/icons/empty.png"
theme.widget_cpu = confdir .. "/icons/cpu.png"
theme.widget_mem = confdir .. "/icons/mem.png"

theme.layout_tile = confdir .. "/layouts/tile.png"
theme.layout_tileleft = confdir .. "/layouts/tileleft.png"
theme.layout_fairv = confdir .. "/layouts/fairv.png"
theme.layout_max = confdir .. "/layouts/max.png"
theme.layout_floating = confdir .. "/layouts/floating.png"
theme.layout_magnifier = confdir .. "/layouts/magnifier.png"

return theme
