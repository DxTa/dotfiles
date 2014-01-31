
local settings = [[
gtk-font-name="PT Sans 10"
gtk-theme-name="Numix Redux Dark"
gtk-icon-theme-name="gnome"
gtk-fallback-icon-theme="gnome"
gtk-cursor-blink=0
gtk-cursor-theme-size=0
gtk-toolbar-style=GTK_TOOLBAR_BOTH
gtk-toolbar-icon-size=GTK_ICON_SIZE_LARGE_TOOLBAR
gtk-button-images=0
gtk-menu-images=0
gtk-xft-antialias=1
gtk-xft-hinting=1
gtk-xft-hintstyle="hintslight"
gtk-xft-rgba="rgb"
]]

local gtk2rc = io.open(os.getenv("HOME") .. "/.gtkrc-2.0", "w")
gtk2rc:write(settings)
gtk2rc:write([[
gtk-key-theme-name="Emacs"
binding "does-not-intercept-ctrl-w" {
  unbind "<ctrl>w"
  bind "<alt>BackSpace" { "delete-from-cursor" (word-ends, -1) }
}
class "GtkEntry" binding "does-not-intercept-ctrl-w"
class "GtkTextView" binding "does-not-intercept-ctrl-w"
]])
gtk2rc:close()


os.execute("test -d ~/.config/gtk-3.0 || mkdir -p ~/.config/gtk-3.0")
local gtk3rc = io.open(os.getenv("HOME") .. "/.config/gtk-3.0/settings.ini", "w")
settings, _ = settings:gsub('"', '')
gtk3rc:write("[Settings]\n")
gtk3rc:write(settings)
gtk3rc:close()

local gtk3rc = io.open(os.getenv("HOME") .. "/.config/gtk-3.0/gtk.css", "w")
gtk3rc:write([[
/* Useless: we cannot override properly by unbinding some keys */
/* @import url("/usr/share/themes/Emacs/gtk-3.0/gtk-keys.css"); */

@binding-set custom-text-entry
{
  bind "<ctrl>b" { "move-cursor" (logical-positions, -1, 0) };
  bind "<shift><ctrl>b" { "move-cursor" (logical-positions, -1, 1) };
  bind "<ctrl>f" { "move-cursor" (logical-positions, 1, 0) };
  bind "<shift><ctrl>f" { "move-cursor" (logical-positions, 1, 1) };

  bind "<alt>b" { "move-cursor" (words, -1, 0) };
  bind "<shift><alt>b" { "move-cursor" (words, -1, 1) };
  bind "<alt>f" { "move-cursor" (words, 1, 0) };
  bind "<shift><alt>f" { "move-cursor" (words, 1, 1) };

  bind "<ctrl>a" { "move-cursor" (paragraph-ends, -1, 0) };
  bind "<shift><ctrl>a" { "move-cursor" (paragraph-ends, -1, 1) };
  bind "<ctrl>e" { "move-cursor" (paragraph-ends, 1, 0) };
  bind "<shift><ctrl>e" { "move-cursor" (paragraph-ends, 1, 1) };

  /* bind "<ctrl>w" { "cut-clipboard" () }; */
  bind "<ctrl>y" { "paste-clipboard" () };

  bind "<ctrl>d" { "delete-from-cursor" (chars, 1) };
  bind "<alt>d" { "delete-from-cursor" (word-ends, 1) };
  bind "<ctrl>k" { "delete-from-cursor" (paragraph-ends, 1) };
  bind "<alt>backslash" { "delete-from-cursor" (whitespace, 1) };
  bind "<alt>BackSpace" { "delete-from-cursor" (word-ends, -1) };

  bind "<alt>space" { "delete-from-cursor" (whitespace, 1)
                      "insert-at-cursor" (" ") };
  bind "<alt>KP_Space" { "delete-from-cursor" (whitespace, 1)
                         "insert-at-cursor" (" ")  };
}

GtkEntry, GtkTextView
{
  gtk-key-bindings: custom-text-entry;
}
]])
gtk3rc:close()
