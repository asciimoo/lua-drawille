package.path = package.path .. ";../?.lua"
local Canvas = require "drawille"
local curses = require "curses"
os.setlocale('')
math.randomseed(os.time())

-- Area to draw random pixels
local width = 100 
local height = 100

-- Start up curses.
curses.initscr()    -- Initialize the curses library and the terminal screen.
curses.cbreak()     -- Turn off input line buffering.
curses.echo(false)  -- Don't print out characters as the user types them.
curses.nl(false)    -- Turn off special-case return/newline handling.
curses.curs_set(0)  -- Hide the cursor.

-- Setup Curses Colors 
curses.start_color()
curses.use_default_colors()
for i=0, curses.colors() do
    curses.init_pair(i + 1, i, -1)
end

local stdscr = curses.stdscr()
stdscr:nodelay(true)  -- Make getch nonblocking.
stdscr:keypad()       -- Correctly catch key presses.
while true do
    stdscr:erase() -- use erase() not clear() to remove flickering

    stdscr:addstr("Press Q to Quit. \n")
    local c = Canvas.new()
        for x=1, width do
            for y=1, height do
                    local r = math.random(0,255)
                    local g = math.random(0,255)
                    local b = math.random(0,255)
                    local a = math.random(0,255)
                    if math.random(0,1) == 1 then
                        c:set(x,y,r,g,b,a)
                    end
            end
        end
        
    --[[
    -- draw frame the manual way     
    for row=1, c.width do
        for col=1, c.height do
            if c.pixel_matrix[row][col] then
                local pixel = c.pixel_matrix[row][col]
                local term256color = nearest_term256_color_index(pixel.r, pixel.g, pixel.b)
                local cc = curses.color_pair(term256color)
                stdscr:attron(cc)
                --stdscr:attron(curses.A_BOLD)
                stdscr:addstr(pixel.str)
                stdscr:attroff(cc)
            end
        end
        stdscr:addstr("\n")
    end
    ]]--

    -- draw frame the convenient way
    c:cframe(curses)

    -- handle key imput
    local key = stdscr:getch()  -- Nonblocking; returns nil if no key was pressed.
    if key == tostring('q'):byte(1) then  -- The q key quits.
        curses.endwin()
        os.exit(0)
    end
    
    curses.delay_output(100)
end