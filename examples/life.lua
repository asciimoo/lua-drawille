#!/usr/bin/env luajit
package.path = package.path .. ";../?.lua"
local Canvas = require "drawille"
local curses = require "curses"
os.setlocale('') -- de_DE.utf-8
math.randomseed(os.time()^5+os.clock())

-- Start up curses.
curses.initscr()    -- Initialize the curses library and the terminal screen.
curses.cbreak()     -- Turn off input line buffering.
curses.echo(false)  -- Don't print out characters as the user types them.
curses.nl(false)    -- Turn off special-case return/newline handling.
curses.curs_set(0)  -- Hide the cursor.
-- Area to draw 
local width = curses.cols() or 80 
local height = curses.lines() or 25
width,height=(width-2)*2,(height-1)*4


-- Setup Curses Colors 
curses.start_color()
curses.use_default_colors()
for i=0, curses.colors() do
    curses.init_pair(i + 1, i, -1)
end

function Canvas:neighbors(x,y,width,height)
	local n=0
	local xh,xl=x%width+1,(x-2)%width+1
	local yh,yl=y%height+1,(y-2)%height+1
	if self:get(xl,yl) then n=n+1 end
	if self:get(x ,yl) then n=n+1 end
	if self:get(xh,yl) then n=n+1 end
	if self:get(xl,y ) then n=n+1 end
	if self:get(xh,y ) then n=n+1 end
	if self:get(xl,yh) then n=n+1 end
	if self:get(x ,yh) then n=n+1 end
	if self:get(xh,yh) then n=n+1 end
	return n
end

local stdscr = curses.stdscr()
stdscr:nodelay(true)  -- Make getch nonblocking.
stdscr:keypad()       -- Correctly catch key presses.
local c = { Canvas(),Canvas() }
local c1,c2 = 1,2
c[c1]:set(2,1) c[c1]:set(3,2) c[c1]:set(1,3) c[c1]:set(2,3) c[c1]:set(3,3)
for x=1,width do for y=1,height do
	if math.random(4)==1 then c[c1]:set(x,y) end
end end
repeat
--    stdscr:erase() -- use erase() not clear() to remove flickering
	stdscr:mvaddstr(0,0,"")
    c[c1]:cframe(curses)
	for y=1, height do
		for x=1, width do
			local pixel=c[c1]:get(x,y)
			local n=c[c1]:neighbors(x,y,width,height)
			if n==3 then
				c[c2]:set(x,y)
			elseif n==2 and pixel then
				c[c2]:set(x,y)
			end
		end
	end
	c1,c2=c2,c1
	c[c2]:clear()
    local key = stdscr:getch()  -- Nonblocking; returns nil if no key was pressed.
    if key == tostring('q'):byte(1) then  -- The q key quits.
        curses.endwin()
        os.exit(0)
    end
    curses.delay_output(100)
until false
