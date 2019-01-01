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

--[[
  Conways Game of Life
  Argument: 23/3 (default Conway world, with 2+3 survival, 3 birth)
  first argument in form of <survival>/<birth> makes the new world
  Examples
  3/3 13/3 23/3 (Conway) 34/3 (4G3) 35/3 236/3 135/35 12345/3 
  1357/1357 (copyworld) 24/35 0123/01234 (blinking spotworld)
  01234678/0123478 Anti-Conway
  02468/02468 Anti-Copy
  01234678/0123678 Anti 4G3
]]

local cs, cb=arg[1] and arg[1]:match("(%d+)/(%d+)") or "23","3"
local birth,survive={},{}
for c in cb:gmatch("%d") do
	birth[tonumber(c)]=true
end
for c in cs:gmatch("%d") do
	survive[tonumber(c)]=true
end

repeat
--    stdscr:erase() -- use erase() not clear() to remove flickering
	stdscr:mvaddstr(0,0,"")
    c[c1]:cframe(curses)
	for y=1, height do
		for x=1, width do
			local pixel=c[c1]:get(x,y)
			local n=c[c1]:neighbors(x,y,width,height)
			if birth[n] then
				c[c2]:set(x,y)
			elseif survive[n] and pixel then
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
