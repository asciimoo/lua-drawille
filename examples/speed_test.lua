#!/usr/bin/env luajit

Canvas=require"drawille"

c = Canvas.new()

local frames = 1000 * 10

local sizes = {{0, 0},{10, 10},{20, 20},{20, 40},{40, 20},{40, 40},{100, 100}}

for k,v in ipairs(sizes) do
	local x,y=v[1],v[2]
    c:set(0, 0)

    for i=1,y do
        c:set(x, i)
	end

	local now,r=os.clock(),0
	for i=1,1e5 do
		c:frame()
	end
	r=os.clock()-now
    print(string.format('%dx%d\t%f', x, y, r))
    c:clear()
end
