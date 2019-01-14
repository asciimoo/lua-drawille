#!/usr/bin/env luajit
local Canvas=require"drawille"
math.randomseed(os.time()^5+os.clock())
local c = Canvas()
c.esccodes = true

local depth=arg[1] and tonumber(arg[1]) or 5

local str=arg[2] or "2S25TXFXFFXXAXF+LA-+RA-F+LA-RFAXA"
-- Draw Lindenmayer Tree 
str=str:lindenmayer(depth)
print(str)
c:draw(str, 124, 252, 0)
print(c:frame())
