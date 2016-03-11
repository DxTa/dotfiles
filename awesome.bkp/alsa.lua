
local awful = require("awful")
local naughty = require("naughty")
local alsa = {}

local function notify_status ()
end

alsa.raise = function ()
   awful.util.spawn("amixer set Master 2+")
   notify_status()
end

alsa.lower = function ()
   awful.util.spawn("amixer set Master 2-")
   notify_status()
end

alsa.toggle = function ()
   awful.util.spawn("amixer set Master toggle")
   notify_status()
end

return alsa