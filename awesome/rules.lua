
local awful = require("awful")
local bindings = require("bindings")
local beautiful = require("beautiful")

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

   -- Flash player
   { rule = { class = "Plugin-container" },
     properties = { floating = true } },
   { rule = { class = "Exe" },
     properties = { floating = true } }
}
