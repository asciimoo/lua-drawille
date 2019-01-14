#!/usr/bin/env luajit
package.path = package.path .. ";../?.lua"
local curses = require "curses"
os.setlocale('')

-- Start up curses.
curses.initscr()    -- Initialize the curses library and the terminal screen.
curses.cbreak()     -- Turn off input line buffering.
curses.echo(false)  -- Don't print out characters as the user types them.
curses.nl(false)    -- Turn off special-case return/newline handling.
curses.curs_set(0)  -- Hide the cursor.


-- Setup Curses Colors curses.has_colors()
if curses.has_colors() then 
    curses.start_color()
    curses.use_default_colors()
    for i=0, curses.colors() do
        curses.init_pair(i + 1, i, -1)
    end

    -- Partial color support
    if curses.colors() < 256 then
        curses.endwin()
        print("It Looks like your curses version or your Terminal has no full 256 color support.")
        local diag = string.format( "Your Terminal settings support %i colors.", curses.colors())
        print(diag)
        os.execute("echo Your Terminal Setting = $TERM")
        print("It should be xterm-256color in order to work.")
        print("try 'export TERM=xterm-256color' ")
        os.exit(0)
    end

else -- NO color support
    curses.start_color()
    curses.use_default_colors()
    curses.endwin()
    print("Your curses version or your Terminal has no color support.")
    local diag = string.format( "Your Terminal settings support %i colors.", curses.colors())
    print(diag)
    os.execute("echo Your Terminal Setting = $TERM .")
    print("Your Terminal setting sould be xterm-256color in order to work.")
    print("try 'export TERM=xterm-256color' ")
    os.exit(0)
end


local stdscr = curses.stdscr()
stdscr:nodelay(true)  -- Make getch nonblocking.
stdscr:keypad()       -- Correctly catch arrow key presses.
while true do
    
    stdscr:erase() -- use erase() not clear() to remove flickering

    stdscr:addstr("Congratulations, You have 256 colors. \n")
    stdscr:addstr("Press Q to Quit. \n")
	for i=1,32 do
		stdscr:addstr(i%10)
	end
	stdscr:addstr("\n")
    local cstr = ""
    for i=1,curses.colors() do
        local cc = curses.color_pair(i)
        stdscr:attron(cc)
        stdscr:addstr("●") --"█")
        stdscr:attroff(cc)
        if i % 32 == 0 then
        stdscr:addstr("\n")
        end
    end 
    stdscr:refresh()

    -- handle key imput
    local key = stdscr:getch()  -- Nonblocking; returns nil if no key was pressed.
    if key == tostring('q'):byte(1) then  -- The q key quits.
        curses.endwin()
        os.exit(0)
    end
end
