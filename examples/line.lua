#!/usr/bin/env luajit
package.path = package.path .. ";../?.lua"
local Canvas = require "drawille"
local curses = require "curses"
os.setlocale('de_DE.utf-8')
math.randomseed(os.time())

-- Start up curses.
curses.initscr()    -- Initialize the curses library and the terminal screen.
curses.cbreak()     -- Turn off input line buffering.
curses.echo(false)  -- Don't print out characters as the user types them.
curses.nl(false)    -- Turn off special-case return/newline handling.
curses.curs_set(0)  -- Hide the cursor.
curses.raw()
-- Area to draw 
local width = curses.cols() or 80 
local height = curses.lines() or 25
width,height=(width-2)*2,(height-2)*4

-- Setup Curses Colors 
curses.start_color()
curses.use_default_colors()
for i=0, curses.colors() do
    curses.init_pair(i + 1, i, -1)
end


local stdscr = curses.stdscr()
stdscr:nodelay(true)  -- Make getch nonblocking.
stdscr:keypad()       -- Correctly catch key presses.
stdscr:erase() -- use erase() not clear() to remove flickering
local line={}
local c = Canvas()
repeat
	stdscr:mvaddstr(0,0,"")
    --stdscr:mvaddstr(1,1,"Press Q to Quit.\n")
	for i=1,10 do
		while #line>25 do
			for x,y in c.line(unpack(line[1])) do
				c:unset(x,y)
			end
			table.remove(line, 1)
		end
		local x1,y1,x2,y2=
			math.random(1,width), math.random(1,height), 
			math.random(1,width), math.random(1,height)
		table.insert(line, {x1,y1,x2,y2})
		local r = math.random(0,255)
		local g = math.random(0,255)
		local b = math.random(0,255)
		local a = math.random(0,255)
		for x,y in c.line(x1,y1, x2,y2) do
			c:set(x,y,r,g,b,a)
		end
	end
	c:set_text(10,10, "Press Q to Quit",255,255,255,255)
    -- draw frame the convenient way
    c:cframe(curses)

    -- handle key imput
    local key = stdscr:getch()  -- Nonblocking; returns nil if no key was pressed.
    if key == tostring('q'):byte(1) then  -- The q key quits.
        curses.endwin()
        os.exit(0)
    end
    
    curses.delay_output(100)
until false
