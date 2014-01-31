
local awful = require("awful")
local wibox = require("wibox")
local vicious = require("vicious")
local naughty = require("naughty")
local mpd = require("mpd")

local tmp = nil

local function image(path)
   return awful.util.getdir("config").."/icons/"..path
end

local widgets = {}
widgets.wiboxes = {}

-- Systray
widgets.systray = wibox.widget.systray()

-- Taglist
widgets.taglists = {}
widgets.taglists.buttons = awful.util.table.join(
   awful.button({}, 1, awful.tag.viewonly),
   awful.button({ modkey }, 1, awful.client.movetotag),
   awful.button({}, 3, awful.tag.viewtoggle),
   awful.button({ modkey }, 3, awful.client.toggletag))

for s = 1, screen.count() do
   widgets.taglists[s] = awful.widget.taglist(
      s, awful.widget.taglist.filter.all, widgets.taglists.buttons)
end

-- Layoutboxes
widgets.layoutboxes = {}
widgets.layoutboxes.buttons = awful.util.table.join(
   awful.button({}, 1,
                function () awful.layout.inc(layouts, 1) end),
   awful.button({}, 3,
                function () awful.layout.inc(layouts, -1) end),
   awful.button({}, 4,
                function () awful.layout.inc(layouts, 1) end),
   awful.button({}, 5,
                function () awful.layout.inc(layouts, -1) end))

for s = 1, screen.count() do
   widgets.layoutboxes[s] = awful.widget.layoutbox(s)
   widgets.layoutboxes[s]:buttons(widgets.layoutboxes.buttons)
end

-- Promptboxes
local function prompt (input)
   if input:sub(1, 1) == "=" then
      input = input:sub(2).." = "..awful.util.eval("return ("..input:sub(2)..")")
      naughty.notify({ text = input })
      return
   elseif input:sub(1, 1) == "?" then
      -- Among the installed dictionaries, this one is the least verbose
      input = io.popen("sdcv -n -u 'WordNet' "..input:sub(2))
      repeat
         tmp = input:read()
      until tmp == ""
      naughty.notify({ text = input:read('*all'), timeout = 10 })
      input:close()
      return
   elseif input:sub(1, 1) == ":" then
      input = terminal .. " -e '" .. input:sub(2) .. "'"
   end

   awful.util.spawn(input)
end

local function prompt_completion (input, cur, ncomp, shell)
   local term = false
   if input:sub(1, 1) == ":" then
      term = true
      input = input:sub(2)
      cur = cur - 1
   end
   input, cur = awful.completion.shell(input, cur, ncomp, shell)
   if term == true then
      input = ':' .. input
      cur = cur + 1
   end
   return input, cur
end

widgets.promptboxes = {}
widgets.promptboxes.run = function()
   awful.prompt.run(
      { prompt = "Run: " },
      widgets.promptboxes[mouse.screen].widget,
      prompt, prompt_completion)
end

for s = 1, screen.count() do
   widgets.promptboxes[s] = awful.widget.prompt()
end

-- Clock
local function display_calendar()
   local today = os.date("%d")
   local process = io.popen("cal --color=always --julian", "r")
   local text = process:read("*all"):gsub(today.." ",
                                          "<span color='red'>"..today.."</span>")
   process:close()
   naughty.notify({ text = text })
end

widgets.textclock = awful.widget.textclock()
widgets.textclock:buttons(
   awful.util.table.join(
      awful.button({}, 1, display_calendar)))

-- MPD
-- local mpdicon = wibox.widget.imagebox()
-- mpdicon:set_image(image("phones.png"))
-- mpdicon:buttons(
--    awful.util.table.join(
--       awful.button({}, 1, mpd.toggle)))

local mpdtext = wibox.widget.textbox()
mpdtext:buttons(
   awful.util.table.join(
      awful.button({}, 1, mpd.toggle)))

local function mpdstatus(widget, args)
   local state = args["{state}"]
   local status = args["{Title}"]..' - '..args["{Artist}"]

   if state == "N/A" or state == "Stop" then
      return ""
   elseif state == "Pause" then
      return " "..status
   end

   return " "..status
end

vicious.register(mpdtext, vicious.widgets.mpd, mpdstatus)

widgets.mpd = wibox.layout.fixed.horizontal()
-- widgets.mpd:add(mpdicon)
widgets.mpd:add(mpdtext)

-- Separator
widgets.right_separator = wibox.widget.textbox()
widgets.right_separator:set_text(" «")

-- CPU
local cpuicon = wibox.widget.imagebox()
cpuicon:set_image(image("cpu.png"))

local cputext = wibox.widget.textbox()

widgets.cpu = wibox.layout.fixed.horizontal()
widgets.cpu:add(cpuicon)
widgets.cpu:add(cputext)

-- Volume
local function volumestatus()
end

local volumeicon = wibox.widget.imagebox()
volumeicon:set_image(volumestatus())

-- Battery
local function batterystatus()
end

local batteryicon = wibox.widget.imagebox()
batteryicon:set_image(batterystatus())

local batterytext = wibox.widget.textbox()

widgets.battery = wibox.layout.fixed.horizontal()
widgets.battery:add(batteryicon)
widgets.battery:add(batterytext)

return widgets
