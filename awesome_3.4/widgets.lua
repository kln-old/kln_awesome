local awful = awful
local widget = widget 
local beautiful = beautiful
local image = image
local awesompd = awesompd
module("widgets")

--beautiful.init("/home/kln/.config/awesome/themes/darkblue/theme.lua")

-- Create a textclock widget
textclock         = awful.widget.textclock({ align = "right" })
mytimeicon		    = widget({type = "imagebox", name="mytimeicon"})
mytimeicon.image	= image("/home/kln/.config/awesome/icons/myicons/date.png")

-- widget spacer 
myspacer			= widget({type = "textbox", name="myspacer"})
myspacer.text		= " "
-- widget separator
myseparator			= widget({type = "textbox", name="myseparator"})
myseparator.text 	= "|"


-- Mem widget
memwidget = awful.widget.progressbar({ layout = awful.widget.layout.horizontal.rightleft})
memwidget:set_width(50)
memwidget:set_height(15)
memwidget:set_border_color("#ffffffff")
memwidget:set_background_color("#000000ff")
memwidget:set_color(beautiful.fg_focus)
--memwidget:set_gradient_colors({beautiful.fg_focus, beautiful.fg_center_widget, theme.fg_end_widget})
memwidget:set_gradient_colors({beautiful.fg_focus, beautiful.fg_focus, "#ffffffff"})
mymemicon					= widget({type = "imagebox", name="mymemicon"})
mymemicon.image		= image("/home/kln/.config/awesome/icons/myicons/mem.png")

-- cpu widget
cpuwidget = awful.widget.graph({layout = awful.widget.layout.horizontal.rightleft})
cpuwidget:set_width(50)
cpuwidget:set_height(15)
cpuwidget:set_border_color("#ffffffff")
cpuwidget:set_background_color("#000000ff")
cpuwidget:set_color(beautiful.fg_focus)
--cpuwidget:set_gradient_colors({beautiful.fg_focus, "#ffffffff", theme.fg_end_widget})
--cpuwidget:set_gradient_colors({beautiful.fg_widget, theme.fg_center_widget, theme.fg_end_widget})
mycpuicon 				= widget({type = "imagebox", name="mycpuicon"})
mycpuicon.image 	= image("/home/kln/.config/awesome/icons/myicons/cpu.png")

-- net widget
netwidget = widget({type = "textbox", name="netwidget"})
myneticon = widget({type = "imagebox", name="myneticon"})
myneticon.image = image("/home/kln/.config/awesome/icons/myicons/net.png")
myneticonup	= widget({type = "imagebox", name="myneticonup"})
myneticonup.image = image("/home/kln/.config/awesome/icons/myicons/netup.png")

-- fs widget
fswidget = widget({type = "textbox", name="fswidget"})
mydiskicon 				= widget({type = "imagebox", name="mydiskicon"})
mydiskicon.image	= image("/home/kln/.config/awesome/icons/myicons/disk.png")

-- volume widget
volwidget = widget({type = "textbox"})
volwidget:buttons(awful.util.table.join(
		awful.button({ }, 1, function() awful.util.spawn("amixer -q set Master toggle", false) end),
		awful.button({ }, 3, function() awful.util.spawn("xterm -e alsamixer", true) end), 
		awful.button({ }, 4, function() awful.util.spawn("amixer -q set Master 3dB+", false) end), 
		awful.button({ }, 5, function() awful.util.spawn("amixer -q set Master 3dB-", false) end) 
))
myvolicon					= widget({type = "imagebox", name="myvolicon"})
myvolicon.image		= image("/home/kln/.config/awesome/icons/myicons/vol.png")

-- mpd widget
mpdwidget = widget({type = "textbox", name="mpdwidget"})
mymusicicon					= widget({type = "imagebox", name="mymusicicon"})
mymusicicon.image		= image("/home/kln/.config/awesome/icons/myicons/music.png")

-- battery widget
--batwidget = widget({type = "textbox", name="batwidget"})
--vicious.register(batwidget, vicious.widgets.bat, "$1$2%", 61, "BAT0")
batwidget = widget({type = "textbox", name="batwidget"})
mybaticon                   = widget({type = "imagebox", name="mybaticon"})
mybaticon.image     = image("/home/kln/.config/awesome/icons/myicons/bat.png")
