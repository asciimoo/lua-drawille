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
width,height = (width-2)*1.7, (height-1)*4
-- Setup Curses Colors 
if curses.has_colors() then
	curses.start_color()
	curses.use_default_colors()
	for i=0, curses.colors() do
		curses.init_pair(i + 1, i, -1)
	end
else
	curses.endwin()
	error("Your terminal has no colors")
end

local stdscr = curses.stdscr()
stdscr:nodelay(true)  -- Make getch nonblocking.
stdscr:keypad()       -- Correctly catch key presses.
stdscr:erase() -- use erase() not clear() to remove flickering
local line={}
local c = Canvas.new()
repeat
    stdscr:mvaddstr(1,1,"")
	for i=1,10 do
		while #line>50 do
			for x,y in c.ellipse(unpack(line[1])) do
				c:unset(x,y)
			end
			table.remove(line, 1)
		end
		local xm,ym,xr,yr=
			math.random(21,width-41), math.random(21,height-41), 
			math.random(5,20), math.random(5,20)
		table.insert(line, {xm,ym,xr,yr})
		local r = math.random(0,255)
		local g = math.random(0,255)
		local b = math.random(0,255)
		local a = math.random(0,255)
		for x,y in c.ellipse(xm,ym, xr,yr) do
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
