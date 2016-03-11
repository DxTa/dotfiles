
local awful = require("awful")
local bindings = require("bindings")
local beautiful = require("beautiful")

local rules = {
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
   { rule = { class = "Gimp" },
     properties = { floating = true } },

   -- Java Apps
   { rule = { class = "java-lang-Thread" },
     properties = { floating = true } },
   { rule = { class = "clojure-main" },
     properties = { floating = true } },
   { rule = { class = "jmt-framework-gui-components-JMTFrame" },
     properties = { floating = true } },

   -- VirtualBox
   { rule = { class = "VBoxSDL" },
     properties = { floating = true, width = 1024, height = 768 } },

   -- Wine Apps
   { rule = { class = "Wine" },
     properties = { border_width = 0, floating = true } },

   -- Flash player
   { rule = { class = "Plugin-container" },
     properties = { floating = true } },
   { rule = { class = "Exe" },
     properties = { floating = true } }
}

return rules
