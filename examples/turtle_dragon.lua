#!/usr/bin/env luajit
local Canvas=require"drawille"
math.randomseed(os.time()^5+os.clock())
local c = Canvas()
c.esccodes = true

local depth=arg[1] and tonumber(arg[1]) or 7

local str=arg[2] or "120T2SXFXFRFFLXFLFLF"
-- Draw Lindenmayer Tree 
str=str:lindenmayer(depth)
print(str)
c:draw(str, 200, 40, 0)
print(c:frame())
