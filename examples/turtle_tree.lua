#!/usr/bin/env luajit
local Canvas=require"drawille"
math.randomseed(os.time()^5+os.clock())
local c = Canvas()

local depth=arg[1] and tonumber(arg[1]) or 4

local str=arg[2] or "2S25TXFXFFXXAXFR++A-LA-LF+LFA-RAXA"
-- Draw Lindenmayer Tree 
str=str:lindenmayer(depth)
print(str)
c:draw(str)
print(c:frame())
