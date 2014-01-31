
local awful = require("awful")

-- Inherits from the default theme
local theme = dofile("/usr/share/awesome/themes/default/theme.lua")

function icon(path)
  return awful.util.getdir("config") .. "/icons/" .. path
end

theme.font = "terminus 8"
theme.wallpaper = os.getenv("HOME").."/Pictures/wall.jpg"

-- theme.bg_normal     = "#222222"
-- theme.bg_focus      = "#535d6c"
-- theme.bg_urgent     = "#ff0000"
-- theme.bg_minimize   = "#444444"
-- theme.bg_systray    = theme.bg_normal

-- theme.fg_normal     = "#aaaaaa"
-- theme.fg_focus      = "#ffffff"
-- theme.fg_urgent     = "#ffffff"
-- theme.fg_minimize   = "#ffffff"

-- theme.border_width  = 1
-- theme.border_normal = "#000000"
-- theme.border_focus  = "#535d6c"
-- theme.border_marked = "#91231c"

-- There are other variable sets
-- overriding the default one when
-- defined, the sets are:
-- [taglist|tasklist]_[bg|fg]_[focus|urgent]
-- titlebar_[bg|fg]_[normal|focus]
-- tooltip_[font|opacity|fg_color|bg_color|border_width|border_color]
-- mouse_finder_[color|timeout|animate_timeout|radius|factor]

-- Variables set for theming the menu:
-- menu_[bg|fg]_[normal|focus]
-- menu_[border_color|border_width]

theme.menu_height = 18

-- Layout icons
theme.layout_floating = icon("float.png")
theme.layout_max = icon("max.png")
theme.layout_tile = icon("tile.png")

return theme
