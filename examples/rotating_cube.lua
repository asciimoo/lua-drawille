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

local vertices = {
    Point3D(20,20,-20),
    Point3D(20,-20,-20),
    Point3D(-20,-20,-20),
    Point3D(-20,20,-20),
    Point3D(20,20,20),
    Point3D(20,-20,20),
    Point3D(-20,-20,20),
    Point3D(-20,20,20),
}

-- Define the vertices that compose each of the 6 faces. These numbers are
-- indices to the vertices list defined above.
local faces = {{1,2,3,4},{1,5,6,2},{2,6,7,3},{3,7,8,4},{1,4,8,5},{5,8,7,6}}


local function show_cube(projection)
	projection=projection or false
    local angleX, angleY, angleZ = 0, 0, 0
    local c = Canvas()
    repeat
        -- Will hold transformed vertices.
        local t = {}

        for _,v in ipairs(vertices) do
            -- Rotate the point around X axis, then around Y axis, and finally around Z axis.
            local p = v:rotateX(angleX):rotateY(angleY):rotateZ(angleZ)
            if projection then
                -- Transform the point from 3D to 2D
                p = p:project(50, 50, 50, 60)
			end
            -- Put the point in the list of transformed vertices
            t[#t+1]=p
		end
        for _,f in ipairs(faces) do
			if not Point3D.culling(t[f[1]], t[f[2]], t[f[3]]) then
				for i=1,#f do
					for x,y in c.line(t[f[i]].x, t[f[i]].y, t[f[i%#f+1]].x, t[f[i%#f+1]].y) do
						c:set(x,y)
					end
				end
			end
		end
		stdscr:erase()
        c:cframe(curses, -30, -10, 60, 30)
        --stdscr:addstr(0, 0, f)
        stdscr:refresh()
        c:clear()
        curses.delay_output(50)

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

local projection = false
for _,a in ipairs(arg) do if a=="-p" then projection=true end end
show_cube(projection)
