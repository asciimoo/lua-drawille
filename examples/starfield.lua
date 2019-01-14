#!/usr/bin/env luajit
os.setlocale('de_DE.utf-8')
local Canvas=require"drawille" -- import Canvas, line
local Point3D=require"point3d"
local curses=require"curses"

--local sleep=require"socket".sleep

--stdscr = curses.initscr()
curses.initscr()
curses.cbreak()     -- Turn off input line buffering.
curses.echo(false)  -- Don't print out characters as the user types them.
curses.nl(false)    -- Turn off special-case return/newline handling.
curses.curs_set(0)  -- Hide the cursor.
curses.raw()
-- Setup Curses Colors 
curses.start_color()
curses.use_default_colors()
for i=0, curses.colors() do
    curses.init_pair(i + 1, i, -1)
end
local stdscr = curses.stdscr()
stdscr:refresh()
stdscr:nodelay(true)  -- Make getch nonblocking.
stdscr:keypad()       -- Correctly catch key presses.
stdscr:clear() -- use erase() not clear() to remove flickering
local width = curses.cols() or 80 
local height = curses.lines() or 25
width,height=(width-4)*2,(height-2)*4

local function addstars(t, num, z, size)
	num=num or 10
	z=z or 500
	size=size or 1000
	for i=1,num do
		local x=math.random(size)-size/2
		local y=math.random(size)-size/2
		local z=-z
		table.insert(t,1,Point3D(x,y,z))
		table.insert(t,1,Point3D(x,y,z+10))
	end
end

local vertices = {}
-- initialize
local size=1000
for z=200,490,10 do addstars(vertices,30,z,size) end
local function starfield()
    local angleX, angleY, angleZ = 0, 0, 0
    local c = Canvas()
    repeat
		addstars(vertices, 30, 500, size)
        -- Will hold transformed vertices.
        local t = {}

        for i=#vertices,2,-2 do
			v1,v2=vertices[i], vertices[i-1]
            t[#t+1]=v1:project(width*.6,height*.3,70,50)
			v1.z=v1.z+10
            t[#t+1]=v2:project(width*.6,height*.3,70,50)
			v2.z=v2.z+10
			if v1.z>-80 or v2.z>-80 then
				table.remove(vertices, i)
				table.remove(vertices, i-1)
				table.remove(t)
				table.remove(t)
			end
		end
        for i=#t,2,-2 do
		if t[i].x>-width/2 and t[i].x<width and t[i].y>-height/2 and t[i].y<height
			and t[i-1].x>-width/2 and t[i-1].x<width and t[i-1].y>-height/2 and t[i-1].y<height
				then
				for x,y in c.line(t[i].x, t[i].y, t[i-1].x, t[i-1].y) do
					local col=(#t-i*.9)/#t*255
					c:set(x,y,col,col,col)
				end
			end
		end
		stdscr:erase()
        c:cframe(curses, -width*.1, -height*.1, width*.4, height*.4)
        --stdscr:addstr(0, 0, f)
        stdscr:refresh()
        c:clear()
        curses.delay_output(20)

        angleX = angleX+2
        angleY = angleY+3
        angleZ = angleZ+5

		-- handle key imput
		local key = stdscr:getch()  -- Nonblocking; returns nil if no key was pressed.
		if key == tostring('q'):byte(1) then  -- The q key quits.
			curses.endwin()
			os.exit(0)
		end
	until false
end

starfield()
