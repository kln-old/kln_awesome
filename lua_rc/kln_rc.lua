-- Standard awesome library
require("awful")
require("awful.autofocus")
require("awful.rules")
-- Theme handling library
require("beautiful")
-- Notification library
require("naughty")
-- drop down animation
require("scratch")
require("vicious")
require("awesompd/awesompd")

-- {{{ Variable definitions
-- Themes define colours, icons, and wallpapers
--beautiful.init("/usr/share/awesome/themes/default/theme.lua")
beautiful.init("/home/kln/.config/awesome/themes/darkblue/theme.lua")
--beautiful.init("/usr/share/awesome/themes/nice-and-clean/theme.lua")

--naughty.config.icon_dirs = {"/home/kln/.config/awesome/naughtyicons/",   "/usr/share/pixmaps/" }

-- This is used later as the default terminal and editor to run.
terminal = "urxvt" or "tilda" or "konsole"
editor = "vim" or "gvim" or os.getenv("EDITOR") or "nano"
editor_cmd = terminal .. " -e " .. editor

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod4"

-- Table of layouts to cover with awful.layout.inc, order matters.
layouts =
{
    awful.layout.suit.floating,
    awful.layout.suit.tile,
 --   awful.layout.suit.tile.left,
    awful.layout.suit.tile.bottom,
 --   awful.layout.suit.tile.top,
 --   awful.layout.suit.fair,
 --   awful.layout.suit.fair.horizontal,
 --   awful.layout.suit.spiral,
 --   awful.layout.suit.spiral.dwindle,
    awful.layout.suit.max,
 --   awful.layout.suit.max.fullscreen,
    awful.layout.suit.magnifier
}
-- }}}

-- {{{ Tags
-- Define a tag table which hold all screen tags.
tags = {}
for s = 1, screen.count() do
    -- Each screen has its own tag table.
    tags[s] = awful.tag({ 1, 2, 3, 4, 5, 6, 7, 8, 9 }, s, layouts[1])
end
-- }}}

-- {{{ Menu
-- Create a laucher widget and a main menu
myawesomemenu = {
   { "manual", terminal .. " -e man awesome" },
   { "edit config", editor_cmd .. " " .. awful.util.getdir("config") .. "/rc.lua" },
   { "restart", awesome.restart },
   { "quit", awesome.quit }
}

mymainmenu = awful.menu({ items = { { "awesome", myawesomemenu, beautiful.awesome_icon },
                                    { "open terminal", terminal }
                                  }
                        })

mylauncher = awful.widget.launcher({ image = image(beautiful.awesome_icon),
                                     menu = mymainmenu })
-- }}}

-- {{{ Wibox
-- Create a textclock widget
mytextclock = awful.widget.textclock({ align = "right" })

-- Mem widget
memwidget = awful.widget.progressbar({ layout = awful.widget.layout.horizontal.rightleft})
memwidget:set_width(50)
memwidget:set_height(15)
memwidget:set_border_color("#ffffffff")
memwidget:set_background_color("#000000ff")
memwidget:set_color(beautiful.fg_focus)
--memwidget:set_gradient_colors({beautiful.fg_focus, beautiful.fg_center_widget, theme.fg_end_widget})
memwidget:set_gradient_colors({beautiful.fg_focus, beautiful.fg_focus, "#ffffffff"})
vicious.register(memwidget, vicious.widgets.mem, "$1", 13)

-- cpu widget
cpuwidget = awful.widget.graph({layout = awful.widget.layout.horizontal.rightleft})
cpuwidget:set_width(50)
cpuwidget:set_height(15)
cpuwidget:set_border_color("#ffffffff")
cpuwidget:set_background_color("#000000ff")
cpuwidget:set_color(beautiful.fg_focus)
--cpuwidget:set_gradient_colors({beautiful.fg_focus, "#ffffffff", theme.fg_end_widget})
--cpuwidget:set_gradient_colors({beautiful.fg_widget, theme.fg_center_widget, theme.fg_end_widget})
vicious.register(cpuwidget, vicious.widgets.cpu, "$1")

-- net widget
netwidget = widget({type = "textbox", name="netwidget"})
vicious.register(netwidget, vicious.widgets.net, '<span color="'.. "#55d400" .. '">${eth0 down_kb}</span> <span color="' .. beautiful.fg_focus .. '">${eth0 up_kb}</span> kb/s', 1)

-- fs widget
fswidget = widget({type = "textbox", name="fswidget"})
vicious.register(fswidget, vicious.widgets.fs, '${/ used_gb}Gb<span color="' .. beautiful.fg_widget .. '"> /</span> ${/ size_gb}Gb ', 120)

-- volume widget
volwidget = widget({type = "textbox"})
vicious.register(volwidget, vicious.widgets.volume, " $1% ", 1, "Master")
volwidget:buttons(awful.util.table.join(
		awful.button({ }, 1, function() awful.util.spawn("amixer -q set Master toggle", false) end),
		awful.button({ }, 3, function() awful.util.spawn("xterm -e alsamixer", true) end), 
		awful.button({ }, 4, function() awful.util.spawn("amixer -q set Master 3dB+", false) end), 
		awful.button({ }, 5, function() awful.util.spawn("amixer -q set Master 3dB-", false) end) 
))

-- battery widget
--batwidget = widget({type = "textbox", name="batwidget"})
--vicious.register(batwidget, vicious.widgets.bat, "$1$2%", 61, "BAT0")
batwidget = widget({type = "textbox", name="batwidget"})
vicious.register(
        batwidget,
        vicious.widgets.bat,
        function(widget, args)
                if (args[2] == 10 or args[2] == 5 or args[2] == 3) and (args[1] == "-")then
                        naughty.notify{
                                preset = naughty.config.presets["battery"],
        text = "I am going to die in " .. args[3] .. "seconds",
        title = "Self destruct sequence initiated"
                        }
                                os.execute('spd-say "Self destruct sequence initiated"')
                end
                if (args[2] == 99) and (args[1] == "+") then
                        naughty.notify{
                                preset = naughty.config.presets["battery"],
                                text = "Fully charged",
                                title = "The force is strong with this one"
                        }
                        os.execute('spd-say "The force is strong with this one"')
                end
                return (args[1]..string.format('%02d', args[2]).."%") 
        end,
        61,
        "BAT0")


-- mpd widget
mpdwidget = widget({type = "textbox", name="mpdwidget"})
vicious.register(mpdwidget,vicious.widgets.mpd,
	function (widget, args)
		if   args[1] == 'Stopped' then return ''
		else return '<span color="green">MPD:</span> '..args[1]
		end
	end)

-- music widget
  musicwidget = awesompd:create() -- Create awesompd widget
  musicwidget.font = "Liberation Mono" -- Set widget font 
  musicwidget.scrolling = true -- If true, the text in the widget will be scrolled
  musicwidget.output_size = 30 -- Set the size of widget in symbols
  musicwidget.update_interval = 10 -- Set the update interval in seconds
  -- Set the folder where icons are located (change username to your login name)
  musicwidget.path_to_icons = "/home/kln/.config/awesome/awesompd/icons" 
  -- Set the default music format for Jamendo streams. You can change
  -- this option on the fly in awesompd itself.
  -- possible formats: awesompd.FORMAT_MP3, awesompd.FORMAT_OGG
  musicwidget.jamendo_format = awesompd.FORMAT_MP3
  -- If true, song notifications for Jamendo tracks and local tracks will also contain
  -- album cover image.
  musicwidget.show_album_cover = true
  -- Specify how big in pixels should an album cover be. Maximum value
  -- is 100.
  musicwidget.album_cover_size = 50
  -- This option is necessary if you want the album covers to be shown
  -- for your local tracks.
  musicwidget.mpd_config = "/etc/mpd.conf"
  -- Specify the browser you use so awesompd can open links from
  -- Jamendo in it.
  musicwidget.browser = "firefox"
  -- Specify decorators on the left and the right side of the
  -- widget. Or just leave empty strings if you decorate the widget
  -- from outside.
 -- musicwidget.ldecorator = '<span color="green"> |</span><span color="' .. beautiful.fg_focus .. '">Mpd: </span>'
  musicwidget.ldecorator = '<span color="green">|</span>'
  musicwidget.rdecorator = '<span color="' .. beautiful.fg_focus .. '">|</span>'
  -- Set all the servers to work with (here can be any servers you use)
  musicwidget.servers = {
     { server = "localhost",
          port = 6600 }}
--     { server = "192.168.0.72",
--          port = 6600 } }
  -- Set the buttons of the widget
  musicwidget:register_buttons({ { "", awesompd.MOUSE_LEFT, musicwidget:command_toggle() },
      			         { "Control", awesompd.MOUSE_SCROLL_UP, musicwidget:command_prev_track() },
 			         { "Control", awesompd.MOUSE_SCROLL_DOWN, musicwidget:command_next_track() },
 			         { "", awesompd.MOUSE_SCROLL_UP, musicwidget:command_volume_up() },
 			         { "", awesompd.MOUSE_SCROLL_DOWN, musicwidget:command_volume_down() },
 			         { "", awesompd.MOUSE_RIGHT, musicwidget:command_show_menu() },
      			         { "", "XF86AudioLowerVolume", musicwidget:command_volume_down() },
		                 { "", "XF86AudioRaiseVolume", musicwidget:command_volume_up() },
 			         { "", "XF86AudioPrev", musicwidget:command_prev_track() },
 			         { "", "XF86AudioNext", musicwidget:command_next_track() },
 			         { "", "XF86AudioPlay", musicwidget:command_toggle() },
               { modkey, "Pause", musicwidget:command_playpause() } })
  musicwidget:run() -- After all configuration is done, run the widget

mycpuicon 				= widget({type = "imagebox", name="mycpuicon"})
mycpuicon.image 	= image("/home/kln/.config/awesome/icons/myicons/cpu.png")
myneticon					= widget({type = "imagebox", name="myneticon"})
myneticon.image 	= image("/home/kln/.config/awesome/icons/myicons/net.png")
myneticonup				= widget({type = "imagebox", name="myneticonup"})
myneticonup.image	= image("/home/kln/.config/awesome/icons/myicons/netup.png")
myvolicon					= widget({type = "imagebox", name="myvolicon"})
myvolicon.image		= image("/home/kln/.config/awesome/icons/myicons/vol.png")
myspacer					= widget({type = "textbox", name="myspacer"})
myspacer.text			= " "
myseparator				= widget({type = "textbox", name="myseparator"})
myseparator.text 	= "|"
mydiskicon 				= widget({type = "imagebox", name="mydiskicon"})
mydiskicon.image	= image("/home/kln/.config/awesome/icons/myicons/disk.png")
mytimeicon				= widget({type = "imagebox", name="mytimeicon"})
mytimeicon.image	= image("/home/kln/.config/awesome/icons/myicons/date.png")
mymemicon					= widget({type = "imagebox", name="mymemicon"})
mymemicon.image		= image("/home/kln/.config/awesome/icons/myicons/mem.png")
mybaticon					= widget({type = "imagebox", name="mybaticon"})
mybaticon.image		= image("/home/kln/.config/awesome/icons/myicons/bat.png")
mymusicicon					= widget({type = "imagebox", name="mymusicicon"})
mymusicicon.image		= image("/home/kln/.config/awesome/icons/myicons/music.png")

-- Create a systray
mysystray = widget({ type = "systray" })

-- Create a wibox for each screen and add it
mywibox = {}
mypromptbox = {}
mylayoutbox = {}
mytaglist = {}
mytaglist.buttons = awful.util.table.join(
                    awful.button({ }, 1, awful.tag.viewonly),
                    awful.button({ modkey }, 1, awful.client.movetotag),
                    awful.button({ }, 3, awful.tag.viewtoggle),
                    awful.button({ modkey }, 3, awful.client.toggletag),
                    awful.button({ }, 4, awful.tag.viewnext),
                    awful.button({ }, 5, awful.tag.viewprev)
                    )
mytasklist = {}
mytasklist.buttons = awful.util.table.join(
                     awful.button({ }, 1, function (c)
                                              if c == client.focus then
                                                  c.minimized = true
                                              else
                                                  if not c:isvisible() then
                                                      awful.tag.viewonly(c:tags()[1])
                                                  end
                                                  -- This will also un-minimize
                                                  -- the client, if needed
                                                  client.focus = c
                                                  c:raise()
                                              end
                                          end),
                     awful.button({ }, 3, function ()
                                              if instance then
                                                  instance:hide()
                                                  instance = nil
                                              else
                                                  instance = awful.menu.clients({ width=250 })
                                              end
                                          end),
                     awful.button({ }, 4, function ()
                                              awful.client.focus.byidx(1)
                                              if client.focus then client.focus:raise() end
                                          end),
                     awful.button({ }, 5, function ()
                                              awful.client.focus.byidx(-1)
                                              if client.focus then client.focus:raise() end
                                          end))

for s = 1, screen.count() do
    -- Create a promptbox for each screen
    mypromptbox[s] = awful.widget.prompt({ layout = awful.widget.layout.horizontal.leftright })
    -- Create an imagebox widget which will contains an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    mylayoutbox[s] = awful.widget.layoutbox(s)
    mylayoutbox[s]:buttons(awful.util.table.join(
                           awful.button({ }, 1, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end),
                           awful.button({ }, 4, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(layouts, -1) end)))
    -- Create a taglist widget
    mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.label.all, mytaglist.buttons)

    -- Create a tasklist widget
    mytasklist[s] = awful.widget.tasklist(function(c)
                                              return awful.widget.tasklist.label.currenttags(c, s)
                                          end, mytasklist.buttons)

    -- Create the wibox
    mywibox[s] = awful.wibox({ position = "top", screen = s })
    -- Add widgets to the wibox - order matters
    mywibox[s].widgets = {
        {
            mylauncher,
            mytaglist[s],
            mypromptbox[s],
            layout = awful.widget.layout.horizontal.leftright
        },
        mylayoutbox[s],
        mytextclock,
				myseparator, 
        s == 1 and mysystray or nil,
				myspacer, 
				batwidget, 
				mybaticon, 
				myspacer, 
				fswidget, 
				mydiskicon, 
				myspacer, 
				myneticonup, 
				netwidget, 
				myneticon, 
				myspacer, 
				cpuwidget, 
				mycpuicon, 
				myspacer, 
				memwidget, 
				mymemicon, 
				volwidget, 
				myvolicon,
				musicwidget.widget, 
				mymusicicon,
       mytasklist[s],
        layout = awful.widget.layout.horizontal.rightleft
    }
end
-- }}}

-- {{{ Mouse bindings
root.buttons(awful.util.table.join(
    awful.button({ }, 3, function () mymainmenu:toggle() end),
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}

-- {{{ Key bindings
globalkeys = awful.util.table.join(
    awful.key({ modkey,           }, "Left",   awful.tag.viewprev       ),
    awful.key({ modkey,           }, "Right",  awful.tag.viewnext       ),
    awful.key({ modkey,           }, "Escape", awful.tag.history.restore),

    awful.key({ modkey,           }, "j",
        function ()
            awful.client.focus.byidx( 1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,           }, "k",
        function ()
            awful.client.focus.byidx(-1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,           }, "w", function () mymainmenu:show({keygrabber=true}) end),

    -- Layout manipulation
    awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end),
    awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end),
    awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end),
    awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end),
    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto),
    awful.key({ modkey,           }, "Tab",
        function ()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end),

    -- Standard program
    awful.key({ modkey,           }, "Return", function () awful.util.spawn(terminal .. " -e tmux") end),
    awful.key({ modkey, "Control" }, "r", awesome.restart),
    awful.key({ modkey, "Shift"   }, "q", awesome.quit),

    awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)    end),
    awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)    end),
    awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1)      end),
    awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1)      end),
    awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1)         end),
    awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1)         end),
    awful.key({ modkey,           }, "space", function () awful.layout.inc(layouts,  1) end),
    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(layouts, -1) end),

    awful.key({ modkey, "Control" }, "n", awful.client.restore),

    -- Prompt
    awful.key({ modkey },            "r",     function () mypromptbox[mouse.screen]:run() end),

    awful.key({ modkey }, "x",
              function ()
                  awful.prompt.run({ prompt = "Run Lua code: " },
                  mypromptbox[mouse.screen].widget,
                  awful.util.eval, nil,
                  awful.util.getdir("cache") .. "/history_eval")
              end), 
		awful.key( { }, "F12", function () scratch.drop("urxvt", "bottom") end), 
    awful.key({ modkey, "Shift"   }, "v", function () awful.util.spawn("xterm -e alsamixer") end), 
		awful.key({ },   "Print",  function() awful.util.spawn("scrot -e 'mv $f ~/pictures/screenshots/ 2>/dev/null'") end), 
		awful.key( { }, "F11", function () awful.util.spawn("xscreensaver-command --lock") end), 	
		awful.key( { }, "XF86Display", function () awful.util.spawn("arandr") end), 	
		awful.key( { }, "XF86Sleep", function () awful.util.spawn("sudo pm-suspend") end), 	
		awful.key( { }, "XF86WebCam", function () awful.util.spawn("skype") end), 	
		awful.key( { }, "XF86AudioRaiseVolume", function () awful.util.spawn("amixer -q set Master 3dB+", false) end), 	
		awful.key( { }, "XF86AudioLowerVolume", function () awful.util.spawn("amixer -q set Master 3dB-", false) end) 	
)

clientkeys = awful.util.table.join(
    awful.key({ modkey,           }, "f",      function (c) c.max = not c.max  end),
    awful.key({ modkey, "shift"   }, "f",      function (c) c.fullscreen = not c.fullscreen  end),
    awful.key({ modkey, "Shift"   }, "c",      function (c) c:kill()                         end),
    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ),
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end),
    awful.key({ modkey,           }, "o",      awful.client.movetoscreen(c)                     ),
    awful.key({ modkey, "Shift"   }, "r",      function (c) c:redraw()                       end),
    awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end),
    awful.key({ modkey,           }, "n",
        function (c)
            -- The client currently has the input focus, so it cannot be
            -- minimized, since minimized clients can't have the focus.
            c.minimized = true
        end),
    awful.key({ modkey,           }, "m",
        function (c)
            c.maximized_horizontal = not c.maximized_horizontal
            c.maximized_vertical   = not c.maximized_vertical
        end), 
		awful.key({ modkey, "Shift" }, "Left", function () awful.client.moveresize( 0, 0, -40, 0) end), 
		awful.key({ modkey, "Shift" }, "Right", function () awful.client.moveresize( 0, 0, 40, 0) end), 
		awful.key({ modkey, "Shift" }, "Up", function () awful.client.moveresize( 0, 0, 0, -40) end), 
		awful.key({ modkey, "Shift" }, "Down", function () awful.client.moveresize( 0, 0, 0, 40) end), 
		awful.key({ modkey, "Control" }, "Next", function () awful.client.moveresize( 20, 20, -40, -40) end), 
		awful.key({ modkey, "Control" }, "Prior", function () awful.client.moveresize( -20, -20, 40, 40) end), 
		awful.key({ modkey, "Control" }, "Down", function () awful.client.moveresize( 0, 20, 0, 0) end), 
		awful.key({ modkey, "Control" }, "Up", function () awful.client.moveresize( 0, -20, 0, 0) end), 
		awful.key({ modkey, "Control" }, "Left", function () awful.client.moveresize( -20, 0, 0, 0) end), 
		awful.key({ modkey, "Control" }, "Right", function () awful.client.moveresize( 20, 0, 0, 0) end)
)

-- Compute the maximum number of digit we need, limited to 9
keynumber = 0
for s = 1, screen.count() do
   keynumber = math.min(9, math.max(#tags[s], keynumber));
end

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, keynumber do
    globalkeys = awful.util.table.join(globalkeys,
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                        local screen = mouse.screen
                        if tags[screen][i] then
                            awful.tag.viewonly(tags[screen][i])
                        end
                  end),
        awful.key({ modkey, "Control" }, "#" .. i + 9,
                  function ()
                      local screen = mouse.screen
                      if tags[screen][i] then
                          awful.tag.viewtoggle(tags[screen][i])
                      end
                  end),
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus and tags[client.focus.screen][i] then
                          awful.client.movetotag(tags[client.focus.screen][i])
                      end
                  end),
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus and tags[client.focus.screen][i] then
                          awful.client.toggletag(tags[client.focus.screen][i])
                      end
                  end))
end

clientbuttons = awful.util.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize))

musicwidget:append_global_keys()
-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = true,
                     keys = clientkeys,
                     buttons = clientbuttons } },
    { rule = { class = "MPlayer" },
      properties = { floating = true } },
    { rule = { class = "pinentry" },
      properties = { floating = true } },
    { rule = { class = "gimp" },
      properties = { floating = true } },
    { rule = { class = "XTerm" },
      properties = { floating = true } },
    { rule = { class = "Chromium" },
      properties = { floating = true } },
    { rule = { class = "Skype" },
      properties = { floating = true } },
    { rule = { class = "arandr" },
      properties = { floating = true } },

    -- Set Firefox to always map on tags number 2 of screen 1.
    { rule = { class = "Firefox" },
       properties = { tag = tags[1][1] } },
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.add_signal("manage", function (c, startup)
    -- Add a titlebar
    -- awful.titlebar.add(c, { modkey = modkey })

    -- Enable sloppy focus
    c:add_signal("mouse::enter", function(c)
        if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
            and awful.client.focus.filter(c) then
            client.focus = c
        end
    end)

    if not startup then
        -- Set the windows at the slave,
        -- i.e. put it at the end of others instead of setting it master.
        -- awful.client.setslave(c)

        -- Put windows in a smart way, only if they does not set an initial position.
        if not c.size_hints.user_position and not c.size_hints.program_position then
            awful.placement.no_overlap(c)
            awful.placement.no_offscreen(c)
        end
    end
end)

client.add_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.add_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}

--os.execute("nm-applet &")
--os.execute("batti &")
--os.execute("volumeicon &")



naughty.config.presets.online = {
--    bg = "#1f880e80", 
    bg = "#2BCF6A", 
    fg = "#ffffff", 
}
naughty.config.presets.chat = naughty.config.presets.online
naughty.config.presets.away = {
--    bg = "#eb4b1380", 
	bg = "#6E93C4",
    fg = "#ffffff", 
}
naughty.config.presets.xa = {
--    bg = "#65000080", 
    bg = "#FC821E", 
    fg = "#ffffff", 
}
naughty.config.presets.dnd = {
--    bg = "#65340080", 
	bg = "#D44A4A",
    fg = "#ffffff", 
}
naughty.config.presets.invisible = {
    bg = "#ffffff80", 
    fg = "#000000", 
}
naughty.config.presets.offline = {
    bg = "#64636380", 
    fg = "#ffffff", 
}
naughty.config.presets.requested = naughty.config.presets.offline
naughty.config.presets.error = {
    bg = "#ff000080", 
    fg = "#ffffff", 
}

naughty.config.presets.message = {
    bg = "#aa87de", 
    fg = "#ffffff", 
}

muc_nick = "nitheesh"

function mcabber_event_hook(kind, direction, jid, msg, myicon)
    if kind == "MSG" then
        if direction == "IN" or direction == "MUC" then
            local filehandle = io.open(msg)
            local txt = filehandle:read("*all")
            filehandle:close()
            awful.util.spawn("rm "..msg)
            if direction == "MUC" and txt:match("^<" .. muc_nick .. ">") then
                return
            end
						
            naughty.notify{
				preset = naughty.config.presets["message"],
                icon = myicon,
                text = awful.util.escape(txt),
                title = jid
            }
        end
    elseif kind == "STATUS" then
        local mapping = {
            [ "O" ] = "online",
            [ "F" ] = "chat",
            [ "A" ] = "away",
            [ "N" ] = "xa",
            [ "D" ] = "dnd",
            [ "I" ] = "invisible",
            [ "_" ] = "offline",
            [ "?" ] = "error",
            [ "X" ] = "requested"
        }
        local status = mapping[direction]
        if not status then
            status = "error"
        end
        local iconstatus = status
        if jid:match("icq") then
            iconstatus = "icq/" .. status
        end
        naughty.notify{
            preset = naughty.config.presets[status],
            text = jid,
            icon = iconstatus
        }
    end
end
