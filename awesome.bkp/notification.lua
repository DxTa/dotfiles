
local awful = require("awful")

local notification = {}

notification.log = function(n)
   local log = io.open(awful.util.getdir("cache").."/notifications", "a")
   log:write(n.text .. "\n")
   log:close()

   n.screen = mouse.screen

   return n
end

return notification