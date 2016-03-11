
local awful = require("awful")
local naughty = require("naughty")

local mpd = {}

local function notify_status ()
end

mpd.next = function ()
   awful.util.spawn("ncmpcpp next")
   notify_status()
end

mpd.prev = function ()
   awful.util.spawn("ncmpcpp prev")
   notify_status()
end

mpd.toggle = function ()
   awful.util.spawn("ncmpcpp toggle")
   notify_status()
end

return mpd