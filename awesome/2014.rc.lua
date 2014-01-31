
local awful = require("awful")
local beautiful = require("beautiful")
local naughty = require("naughty")
local gears = require("gears")
local wibox = require("wibox")

require("awful.autofocus")
awful.rules = require("awful.rules")

require("errors")
require("gtk")
require("signals")

-- Global configurations
modkey = "Mod4"
terminal = "xfce4-terminal"
editor = "emacsclient -n -c"
browser = "chromium"
filemanager = "nautilus"
hostname = awful.util.pread('uname -n'):gsub('\n', '')

-- Layouts and tags
layouts = {
   awful.layout.suit.tile,
   awful.layout.suit.max,
   awful.layout.suit.floating
}

local tags = { names = { "web", "code", "term", "comm", "misc" } }
for s = 1, screen.count() do
   tags[s] = awful.tag(tags.names, s, layouts[1])
end

-- Theme
beautiful.init(awful.util.getdir("config") .. "/theme.lua")

-- Wallpaper
if beautiful.wallpaper then
   for s = 1, screen.count() do
      gears.wallpaper.maximized(beautiful.wallpaper, s)
   end
end

-- Naughty
local notification = require("notification")

naughty.config.defaults.icon_size = 36
naughty.config.defaults.border_width = 1
naughty.config.notify_callback = notification.log

-- Menu
local menu = awful.menu(
   { items = {
        { "Terminal"     , terminal      } ,
        { "Browser"      , browser       } ,
        { "Editor"       , editor        } ,
        { "File Manager" , filemanager   } ,
        { "Logout"       , awesome.quit  } ,
        { "Suspend"      , "systemctl suspend"   } ,
        { "Hibernate"    , "systemctl hibernate" } ,
        { "Reboot"       , "systemctl reboot"    } ,
        { "Shut Down"    , "systemctl poweroff"  } } } )

-- Bindings
local bindings = require("bindings")
local alsa = require("alsa")
local mpd = require("mpd")

root.keys(
   awful.util.table.join(
      -- Defaults
      bindings.global.keys,

      -- Menu
      awful.key({ modkey }, "w", function () menu:toggle() end),

      -- Media
      awful.key({}, "XF86AudioRaiseVolume", alsa.raise),
      awful.key({}, "XF86AudioLowerVolume", alsa.lower),
      awful.key({}, "XF86AudioMute", alsa.toggle),
      awful.key({}, "XF86AudioPrev", mpd.prev),
      awful.key({}, "XF86AudioNext", mpd.next),
      awful.key({}, "XF86AudioPlay", mpd.toggle),

      -- Apps
      awful.key({ modkey, "Shift" }, "e", function ()
                   run_or_raise(editor, { class = "Emacs" })
      end),
      awful.key({ modkey, "Shift" }, "f",
                function () awful.util.spawn(filemanager) end),
      awful.key({ modkey, "Shift" }, "c", function ()
                   run_or_raise(browser, { class = "Chromium" })
      end),
      awful.key({ modkey, "Shift" }, "t", function ()
                   run_or_raise(terminal, { class = "Xfce4-terminal" })
      end),
      awful.key({ modkey }, "Return",
                function () awful.util.spawn(terminal) end)
))

root.buttons(
   awful.util.table.join(
      bindings.global.buttons,
      awful.button({}, 3, function () menu:toggle() end)
))

-- Rules
awful.rules.rules = {
   -- Default
   { rule = { },
     properties = { border_width = beautiful.border_width,
                    border_color = beautiful.border_normal,
                    focus = awful.client.focus.filter,
                    keys = bindings.client.keys,
                    buttons = bindings.client.buttons,
                    size_hints_honor = false },
     callback = function(c) c.icon = nil end },

   -- Applications
   { rule = { class = "Synapse" },
     properties = { border_width = 0, floating = true } },
   { rule = { class = "MPlayer" },
     properties = { floating = true } },
   { rule = { class = "pinentry" },
     properties = { floating = true } },
   { rule = { class = "gimp" },
     properties = { floating = true } },

   -- Flash
   { rule = { class = "Plugin-container" },
     properties = { floating = true } },
   { rule = { class = "Exe" },
     properties = { floating = true } }
}

-- Panel
local widgets = require("widgets")

for s = 1, screen.count() do
   -- Left
   local left = wibox.layout.fixed.horizontal()
   left:add(widgets.taglists[s])
   left:add(widgets.layoutboxes[s])
   left:add(widgets.promptboxes[s])

   -- Right
   local right = wibox.layout.fixed.horizontal()
   if s == screen.count() then -- screen["LVDS"].index
      right:add(widgets.systray)
   end
   right:add(widgets.right_separator)
   right:add(widgets.mpd)
   -- right:add(widgets.battery)
   right:add(widgets.right_separator)
   right:add(widgets.textclock)

   -- Put everything together
   local panel = wibox.layout.align.horizontal()
   panel:set_left(left)
   panel:set_right(right)

   widgets.wiboxes[s] = awful.wibox(
      { position = "top", height = beautiful.menu_height, screen = s })
   widgets.wiboxes[s]:set_widget(panel)
end

-- Helpers
local function run_or_raise(cmd, condition)
   local matcher = function (c)
      return awful.rules.match(c, condition)
   end
   awful.client.run_or_raise(cmd, matcher)
end
