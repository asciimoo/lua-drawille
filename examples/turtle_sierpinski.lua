#!/usr/bin/env luajit
local Canvas=require"drawille"
local c = Canvas()

local depth=arg[1] and tonumber(arg[1]) or 3
local size=arg[2] and tonumber(arg[2]) or 5

-- Draw hilbert curve
local str=tostring(size).."S120TFBFLFFLFF"
str=str:lindenmayer(depth,{["B"]="LFBFRFBFRFBFL", ["F"]="FF"})
print(str)
c:draw(str)
print(c:frame())
