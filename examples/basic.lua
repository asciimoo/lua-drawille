package.path = package.path .. ";../?.lua"
Canvas = require "drawille"

math.randomseed(os.time())
local c = Canvas.new()

-- Print in your terminal color (no esc codes) 
for i=0,360*4 do
    if (i % 15) == 0 then
        c:set(i/15, math.floor(math.sin(i*(math.pi/180))*4))
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
        c:cset(i/15, math.floor(math.sin(i*(math.pi/180))*4),r,g,b)
    end
end
print(c:cframe())