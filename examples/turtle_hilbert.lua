#!/usr/bin/env luajit
local Canvas=require"drawille"
local c = Canvas()

local depth=arg[1] and tonumber(arg[1]) or 4
local size=arg[2] and tonumber(arg[2]) or 3

-- Draw hilbert curve
local str=tostring(size).."S90TA"
str=str:lindenmayer(depth,{["A"]="LBFRAFARFBL",["B"]="RAFLBFBLFAR"})
print(str)
c:draw(str)
print(c:frame())
