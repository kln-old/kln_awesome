-- Creates a thin wibox at a position relative to another wibox.
-- Note: It is vital that we use capi.wibox instead of awful.wibox. The
-- awful library will do additional stuff that we certainly do not want
-- to be done here.
local capi = { wibox = wibox }

module("borderbox")

function borderbox(relbox, s, args)
    local wiboxarg = {}
    local where = args.position or 'above'
    local color = args.color or '#FFFFFF'
    local size = args.size or 1
    local box = nil
    wiboxarg.position = nil
    wiboxarg.bg = color

    if where == 'above'
    then
        wiboxarg.width = relbox.width
        wiboxarg.height = size
        box = capi.wibox(wiboxarg)
        box.x = relbox.x
        box.y = relbox.y - size
    elseif where == 'below'
    then
        wiboxarg.width = relbox.width
        wiboxarg.height = size
        box = capi.wibox(wiboxarg)
        box.x = relbox.x
        box.y = relbox.y + relbox.height
    elseif where == 'left'
    then
        wiboxarg.width = size
        wiboxarg.height = relbox.height
        box = capi.wibox(wiboxarg)
        box.x = relbox.x - size
        box.y = relbox.y
    elseif where == 'right'
    then
        wiboxarg.width = size
        wiboxarg.height = relbox.height
        box = capi.wibox(wiboxarg)
        box.x = relbox.x + relbox.width
        box.y = relbox.y
    end

    box.screen = s
    return box
end

