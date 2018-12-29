#!/usr/bin/env luajit
package.path = package.path .. ";../?.lua"
Canvas = require "drawille"

math.randomseed(os.time())
local c = Canvas.new()

-- Print in your terminal color
for i=0,360*4 do
    if (i % 15) == 0 then
        c:set(math.floor(i/15+.5), math.floor(math.sin(i*(math.pi/180))*8+.5))
    end
end
--c:set_text(15,0,"Dies ist ein Test",255,255,255,255)
print(c:frame())

-- Print in with default color (white)
c:clear() -- clear the canvas
c.esccodes = true -- turn no escape codes if you want to print with color
for i=0,360*4 do
    if (i % 15) == 0 then
        c:set(math.floor(i/15+.5), math.floor(math.cos(i*(math.pi/180))*8+.5))
    end
end
print(c:frame())

-- Print random colors
c:clear()
for i=0,360*4 do
    if (i % 15) == 0 then
        local r = math.random(0,255)
        local g = math.random(0,255)
        local b = math.random(0,255)
        c:set(math.floor(i/15+.5), math.floor(math.sin(i*(math.pi/180))*8+.5),r,g,b)
    end
end
c:set_text(15,0,"Dies ist ein Test",255,255,255,255)
print(c:frame())
