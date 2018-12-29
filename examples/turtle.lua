#!/usr/bin/env luajit
local Canvas=require"drawille"

local c = Canvas()

for _=1,36 do
    c:right(10)
    for _=1,36 do
        c:right(10)
        c:forward(5)
	end
end
print(c:frame())
