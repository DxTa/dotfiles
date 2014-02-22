
local awful = require("awful")
local widgets = require("widgets")

local bindings = {}

function focus_window (i)
   awful.client.focus.byidx(i)
   if client.focus then client.focus:raise() end
end

bindings.global = {}
bindings.global.buttons = awful.util.table.join(
   awful.button({}, 3, toggle_menu))

bindings.global.keys = awful.util.table.join(
   -- Tags
   awful.key({ modkey }, "Left", awful.tag.viewprev),
   awful.key({ modkey }, "Right", awful.tag.viewnext),
   awful.key({ modkey }, "Escape", awful.tag.history.restore),

   -- Windows
   awful.key({ modkey }, "j", function () focus_window(1) end),
   awful.key({ modkey }, "k", function () focus_window(-1) end),
   awful.key({ modkey }, "u", awful.client.urgent.jumpto),
   awful.key({ modkey }, "Tab", awful.client.focus.history.previous),

   -- Layouts
   awful.key({ modkey }, "space",
             function () awful.layout.inc(layouts, 1) end),
   awful.key({ modkey, "Shift" }, "space",
             function () awful.layout.inc(layouts, -1) end),
   awful.key({ modkey, "Shift" }, "j",
             function () awful.client.swap.byidx(1) end),
   awful.key({ modkey, "Shift" }, "k",
             function () awful.client.swap.byidx(-1) end),
   awful.key({ modkey }, "l",
             function () awful.tag.incmwfact(0.05) end),
   awful.key({ modkey }, "h",
             function () awful.tag.incmwfact(-0.05) end),

   -- Screens
   awful.key({ modkey, "Control" }, "j",
             function () awful.screen.focus_relative( 1) end),
   awful.key({ modkey, "Control" }, "k",
             function () awful.screen.focus_relative(-1) end),

   -- Promptbox
   awful.key({ modkey }, "r", widgets.promptboxes.run),

   -- Awesome
   awful.key({ modkey, "Control" }, "r", awesome.restart),
   awful.key({ modkey, "Shift"   }, "q", awesome.quit)
)

function current_screen_tag (i)
   return awful.tag.gettags(mouse.screen)[i]
end

function switch_to_tag (i)
   local tag = current_screen_tag(i)
   if tag then awful.tag.viewonly(tag) end
end

function show_tag (i)
   local tag = current_screen_tag(i)
   if tag then awful.tag.viewtoggle(tag) end
end

function move_to_tag (i)
   local tag = current_screen_tag(i)
   if client.focus and tag then
      awful.client.movetotag(tag)
   end
end

for i = 1, 9 do
   k = "#" .. i + 9

   bindings.global.keys = awful.util.table.join(
      bindings.global.keys,
      awful.key({ modkey }, k, function () switch_to_tag(i) end),
      awful.key({ modkey, "Control" }, k, function () show_tag(i) end),
      awful.key({ modkey, "Shift" }, k, function () move_to_tag(i) end)
   )
end


bindings.client = {}

bindings.client.buttons = awful.util.table.join(
   awful.button({}, 1, function (c) client.focus = c; c:raise() end),
   awful.button({ modkey }, 1, awful.mouse.client.move),
   awful.button({ modkey }, 3, awful.mouse.client.resize))

bindings.client.keys = awful.util.table.join(
   awful.key({ modkey }, "f",
             function (c) c.fullscreen = not c.fullscreen end),
   awful.key({ modkey }, "t",
             function (c) c.ontop = not c.ontop end),
   awful.key({ modkey, "Control" }, "space",
             awful.client.floating.toggle),

   awful.key({ modkey, "Control" }, "Return",
             function (c) c.swap(awful.client.getmaster()) end),
   awful.key({ modkey }, "o", awful.client.movetoscreen),

   awful.key({ modkey, "Control" }, "x", function (c) c:kill() end))


return bindings
