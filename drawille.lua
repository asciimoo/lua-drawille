local bit=bit or bit32 --require "bit"
local band,bor,rshift,bnot,bxor=bit.band,bit.bor,bit.rshift,bit.bnot,bit.bxor

-- represents braille character that has 8 subpixel, values are used as offsets for the calculations. 
local pixel_map = {{0x01, 0x08},
                   {0x02, 0x10},
                   {0x04, 0x20},
                   {0x40, 0x80}}

-- contains RGBA values, braille char retresentaion value and a UTF8 String that may be more than one char. 
local Pixel = {}
setmetatable(Pixel, {
	__call=function(cls, ...)
		return cls.new(...)
	end,
})
Pixel.new = function(str, braille_rep, r, g, b, a)
	return {
		str = str or space,
	    braille_rep = braille_rep or 0,      
    	r=r or 255, 
	    g=g or 255, 
	    b=b or 255, 
    	a=a or 255}
end
-- braille unicode characters starts at 0x2800
Pixel.braille={}
local braille_char_offset = 0x2800
for i=0,255 do
    local char = braille_char_offset + i
    local outstr = {}
	-- utf-16 to utf-8
    outstr[#outstr+1]=string.char(128+64+32+band(15, rshift(char, 12)))
    outstr[#outstr+1]=string.char(bor(128, band(63, rshift(char, 6))))
    outstr[#outstr+1]=string.char(bor(128, band(char, 63)))
    Pixel.braille[i]=table.concat(outstr)
end
local nl,space="\n",Pixel.braille[0]


-- Creat new canvas with default values. 
local Canvas = {}
Canvas.__index = Canvas
Canvas._VERSION="drawille for Lua 5.1 / drawille 2.0.0"
setmetatable(Canvas, {
	__call=function(cls, ...)
		return cls.new(...)
	end,
})
function Canvas.new()
    local self = setmetatable({}, Canvas)
    self.clear(self)
    -- This applies to waht Canvas.frame() will return.
    self.alpha_threshold = 10 -- Pixels with a alpha value below are printed as a space.
    self.esccodes = false -- Turn ecsape codes off (false) to use only your Terminal Standard Color.
	self:reset() -- reset turtle attributes
    return self
end
-- get pixel
function Canvas.get(self, x, y)
    local row = math.floor(y / 4)
    local col = math.floor(x / 2)
    if self.pixel_matrix[row] == nil then
		return false
    end
    if self.pixel_matrix[row][col] == nil then
		return false
    end
    local pixel = self.pixel_matrix[row][col]
	return band(pixel.braille_rep, pixel_map[band(y,3) + 1][band(x,1) + 1])~=0
end

-- Clears the canvas and all pixels.
function Canvas.clear(self)
    self.pixel_matrix = {}
    self.minrow = 0; self.mincol = 0;
    self.maxrow = 0; self.maxcol = 0;
    self.width = 0
    self.height = 0
end

-- Set a pixel on the canvas, if no RGB or A values are givven it defaults to white. 
function Canvas.set(self, x, y, r, g, b, a)
    local row = math.floor(y / 4)
    local col = math.floor(x / 2)
    if self.pixel_matrix[row] == nil then
        self.pixel_matrix[row] = {}
    end
    if self.pixel_matrix[row][col] == nil then
        self.pixel_matrix[row][col] = Pixel.new(nil, nil,r,g,b,a)
    end
    local pixel = self.pixel_matrix[row][col]
    pixel.braille_rep = bor(pixel.braille_rep, pixel_map[band(y,3) + 1][band(x,1) + 1])
    pixel.str = Pixel.braille[pixel.braille_rep]
	pixel.r = r or pixel.r
	pixel.g = g or pixel.g
	pixel.b = b or pixel.b
	pixel.a = a or pixel.a
    self.pixel_matrix[row][col] = pixel
    -- Set min,max size of canvas
    if (row < self.minrow) then self.minrow = row end;
    if (row > self.maxrow) then self.maxrow = row end;
    if (col < self.mincol) then self.mincol = col end;
    if (col > self.maxcol) then self.maxcol = col end;
    self.width = -self.minrow+self.maxrow
    self.height = -self.mincol+self.maxcol
end
-- unset a pixel on the canvas
function Canvas.unset(self, x, y)
    local row = math.floor(y / 4)
    local col = math.floor(x / 2)
    if self.pixel_matrix[row] == nil then
		return
    end
    if self.pixel_matrix[row][col] == nil then
		return
    end
    local pixel = self.pixel_matrix[row][col]
    pixel.braille_rep = band(pixel.braille_rep, bnot(pixel_map[band(y,3) + 1][band(x,1) + 1]))
    pixel.str = Pixel.braille[pixel.braille_rep] 
    self.pixel_matrix[row][col] = pixel
    -- Set min,max size of canvas
    if (row < self.minrow) then self.minrow = row end;
    if (row > self.maxrow) then self.maxrow = row end;
    if (col < self.mincol) then self.mincol = col end;
    if (col > self.maxcol) then self.maxcol = col end;
    self.width = -self.minrow+self.maxrow
    self.height = -self.mincol+self.maxcol
end
-- toggle a pixel on the canvas
function Canvas.toggle(self, x, y, r, g, b, a)
    local row = math.floor(y / 4)
    local col = math.floor(x / 2)
    if self.pixel_matrix[row] == nil then
        self.pixel_matrix[row] = {}
    end
    if self.pixel_matrix[row][col] == nil then
        self.pixel_matrix[row][col] = Pixel.new(nil, nil,r,g,b,a)
    end
    local pixel = self.pixel_matrix[row][col]
    pixel.braille_rep = bxor(pixel.braille_rep, pixel_map[band(y,3) + 1][band(x,1) + 1])
    pixel.str = Pixel.braille[pixel.braille_rep] 
    self.pixel_matrix[row][col] = pixel
    -- Set min,max size of canvas
    if (row < self.minrow) then self.minrow = row end;
    if (row > self.maxrow) then self.maxrow = row end;
    if (col < self.mincol) then self.mincol = col end;
    if (col > self.maxcol) then self.maxcol = col end;
    self.width = -self.minrow+self.maxrow
    self.height = -self.mincol+self.maxcol
end

function Canvas.set_text(self, x, y, text, r, g, b, a)
	--[[Set text to the given coords.
	@Parameter x: x coordinate of the text start position
	@Parameter y: y coordinate of the text start position
	@Parameter text: to write text
	]]
    local col = math.floor(x/2)
    local row = math.floor(y/4)
	for c in text:gmatch("([%z\1-\127\194-\244][\128-\191]*)") do
		if self.pixel_matrix[row] == nil then
			self.pixel_matrix[row] = {}
		end
		if self.pixel_matrix[row][col] == nil then
			self.pixel_matrix[row][col] = Pixel.new(nil, nil,r,g,b,a)
		end
    	local pixel = self.pixel_matrix[row][col]
		pixel.str=c
		pixel.r=r or pixel.r
		pixel.g=g or pixel.g
		pixel.b=b or pixel.b
		pixel.a=a or pixel.a
		col=col+1
	end
end

-- Returns a string of the Frame.
function Canvas.frame(self, mincol, minrow, maxcol, maxrow)
	mincol=mincol or self.mincol
	maxcol=maxcol or self.maxcol
	minrow=minrow or self.minrow
	maxrow=maxrow or self.maxrow
    local out={}
        for row=minrow, maxrow do
            for col=mincol, maxcol do
                -- check the pixels alpha threshold and add space if value is less.
                if self.pixel_matrix[row] 
						and self.pixel_matrix[row][col] 
						and self.pixel_matrix[row][col].a > self.alpha_threshold then
                    local pixel = self.pixel_matrix[row][col]
                    if self.esccodes then
                        out[#out+1]=set_string_RGBColor(pixel.str,pixel.r,pixel.g,pixel.b)
                    else
                        out[#out+1]=pixel.str
                    end
                else
                    out[#out+1]=space
                end
            end
			out[#out+1]=nl
        end
    return table.concat(out)
end

-- convenience method for use with curses
-- Prints the frame in curses Standard Screen.
function Canvas.cframe(self, curses, mincol, minrow, maxcol, maxrow)
	mincol=math.floor(mincol or self.mincol)
	minrow=math.floor(minrow or self.minrow)
	maxcol=math.floor(maxcol or self.maxcol)
	maxrow=math.floor(maxrow or self.maxrow)
	local stdscr=curses.stdscr()
    if curses  then
        for row=minrow, maxrow do
            for col=mincol, maxcol do
                -- check the pixels alpha threshold and print space if value is less.
                if self.pixel_matrix[row] 
						and self.pixel_matrix[row][col] 
						and self.pixel_matrix[row][col].a > self.alpha_threshold then
                    local pixel = self.pixel_matrix[row][col]
                    local term256color = nearest_term256_color_index(pixel.r, pixel.g, pixel.b)
                    local cp = curses.color_pair(term256color)
                    stdscr:attron(cp)
					--stdscr:attron(curses.A_BOLD)
                    stdscr:addstr(pixel.str)
                    stdscr:attroff(cp)
                else
					--curses.stdscr():attron(curses.A_BOLD)
                    stdscr:addstr(space)
					--curses.stdscr():attroff(curses.A_BOLD)
                end
            end
            curses.stdscr():addstr(nl)
        end       
    else
        error("no stdscr or curses given")
    end
end

function Canvas.line(x1, y1, x2, y2)
    --[[Returns the Bresnham line coords between (x1, y1), (x2, y2)
    @Parameter: x1 coordinate of the startpoint
    @Parameter: y1 coordinate of the startpoint
    @Parameter: x2 coordinate of the endpoint
    @Parameter: y2 coordinate of the endpoint
	@Returns: a coroutine yielding x,y
    ]]
	return coroutine.wrap(function()
		local x1 = math.floor(x1+.5)
		local y1 = math.floor(y1+.5)
		local x2 = math.floor(x2+.5)
		local y2 = math.floor(y2+.5)

		local dx = math.abs(x2-x1)
		local dy = -math.abs(y2-y1)
		local sx=x1<x2 and 1 or -1
		local sy=y1<y2 and 1 or -1
		local err, e2=dx+dy, 0
		
		repeat
			coroutine.yield (x1, y1)
			if x1==x2 and y1==y2 then break end
			e2=2*err
			if e2>dy then err=err+dy; x1=x1+sx end
			if e2<dx then err=err+dx; y1=y1+sy end
		until false
	end)	
end

function Canvas.ellipse(xm, ym, a, b)
    --[[Returns the Bresnham line coords between (x1, y1), (x2, y2)
    @Parameter: xm coordinate of the middlepoint
    @Parameter: ym coordinate of the middlepoint
    @Parameter: a radius x
    @Parameter: b radius y
	@Returns: a coroutine yielding x,y
    ]]
	return coroutine.wrap(function()
		a,b=math.floor(a+.5),math.floor(b+.5)
		local dx, dy = 0, b
		local a2, b2 = a^2, b^2
		local err, e2 = b2-(2*b-1)*a2, 0
		repeat
			coroutine.yield(xm+dx, ym+dy)
			coroutine.yield(xm-dx, ym+dy)
			coroutine.yield(xm-dx, ym-dy)
			coroutine.yield(xm+dx, ym-dy)
			e2=2*err
			if e2 <  (2*dx+1)*b2 then
				dx=dx+1; err=err+(2*dx+1)*b2
			end
			if e2 > -(2*dy-1)*a2 then
				dy=dy-1; err=err-(2*dy-1)*a2
			end
		until dy<0
	end)	
end
function Canvas.polygon(center_x, center_y, sides, radius)
	return coroutine.wrap(function()
		center_x=center_x or 0
		center_y=center_y or 0
		sides=sides or 4
		radius=radius or 4
		local degree = 360/sides

		for n=1,sides do
			local a=(n-1)*degree
			local b=n*degree
			local x1 = center_x + math.cos(math.rad(a)) * radius
			local y1 = center_y + math.sin(math.rad(a)) * radius
			local x2 = center_x + math.cos(math.rad(b)) * radius
			local y2 = center_y + math.sin(math.rad(b)) * radius

			for x, y in Canvas.line(x1, y1, x2, y2) do 
				coroutine.yield(x, y)
			end
		end
	end)
end
--[[
	Turtle routines
    def __init__(self, pos_x=0, pos_y=0):
    def up(self):
    def down(self):
    def forward(self, step):
    def move(self, x, y):
    def right(self, angle):
    def left(self, angle):
    def back(self, step):
def animate(canvas, fn, delay=1./24, *args, **kwargs):
    def animation(stdscr):

]]
function Canvas:reset(x,y,dir,down)
	self.x		=x or 0
	self.y		=y or 0
	self.dir	=dir or 0
	self.down	=down or true
	self.stack	={}
end
function Canvas:up()
	self.down = false
end
function Canvas:down()
	self.down = true
end
function Canvas:forward(step, r, g, b)
	local x = self.x + math.cos(math.rad(self.dir)) * step
	local y = self.y + math.sin(math.rad(self.dir)) * step
	--prev_brush_state = self.brush_on
	--self.brush_on = True
	self:move(x, y, r, g, b)
	--self.brush_on = prev_brush_state
end
function Canvas:back(step)
	self:forward(-step)
end
function Canvas:move(x,y,r,g,b)
	if self.down then
		for lx, ly in Canvas.line(self.x, self.y, x, y) do
			self:set(lx, ly,r,g,b)
		end
	end
	self.x = x
	self.y = y
end
function Canvas:right(angle)
	self.dir=self.dir+angle
end
function Canvas:left(angle)
	self.dir=self.dir-angle
end
function Canvas:push()
	table.insert(self.stack, self.dir)
	table.insert(self.stack, self.x)
	table.insert(self.stack, self.y)
	return self.dir, self.x, self.y
end
function Canvas:pop()
	self.y=table.remove(self.stack) or self.y
	self.x=table.remove(self.stack) or self.x
	self.dir=table.remove(self.stack) or self.dir
	return self.dir, self.x, self.y
end
function Canvas:draw(str, r,g,b)
	--[[
	  Draw a lindenmayer string with the canvas draw "language"
	  @Parameter: str the lindenmayer string
	   The drawing language interprets following commands:
	   F - draw forward
	   L - turn left
	   R - turn right
	   M - move without drawing
	   N - reset position to all 0,0
	   S - define stepsize (defaults 1)
	   T - define turnsize (defaults 1 deg)
	   X - eXchange rule with new one
	   Z - Zufall (random) select symbol
	   + Push pos+rotation
	   - Pull pos+rotation
	   <num> repeats following command num times
	  @Return: self
	]]
	local rep,step,turn=0,1,1
	for c in str:gmatch(".") do
		if c=="F" then 	-- forward
			self.down=true
			self:forward((rep>1 and rep or 1)*step, r, g, b)
			rep=0
		elseif c=="+" then -- push rot
			self:push()
		elseif c=="-" then -- pull rot
			self:pop()
		elseif c=="L" then -- turn left
			self:left((rep>1 and rep or 1)*turn)
			rep=0
		elseif c=="R" then -- turn right
			self:right((rep>1 and rep or 1)*turn)
			rep=0
		elseif c=="M" then -- move without drawing
			self.down=false
			self:forward((rep>1 and rep or 1)*step)
			rep=0
		elseif c=="N" then -- reset postion to 0
			self:reset()
			rep,step=0,1
		elseif c=="S" then -- default stepsize
			step=rep>1 and rep or 1
			rep=0
		elseif c=="T" then -- default turnsize
			turn=rep>1 and rep or 1
			rep=0
		elseif c:match("%d") then -- allow repeated commands
			rep=rep*10+tonumber(c)
		end
	end
	return self
end

function string:lindenmayer(n,subst)
	--[[ Lindenmayer string substituation		
		@Parameter: n	number depth of iteration of the lindenmayer substitution
		@Parameter: var	string of to replace symbols
		@Parameter: subst table of substituations for symbols
		@Return: returns lindenmayer string
		
		Example for the Hilbert curve implemented by Lindenmayer system
		local str="3S90TA" -- stepsize=3 turnsize=90 startsymbol="A"
		str=str:lindenmayer(3,"AB",{["A"]="LBFRAFARFBL",["B"]="RAFLBFBLFAR"})
		print(c:frame(str))
	]]
	subst=subst or {} --["A"]="LBFRAFARFBL",["B"]="RAFLBFBLFAR"}
	for i=1,n do
		self=self:gsub("X(.-)X(.-)X", function(k,v)
			subst[k]=v
			return ""                                                            
		end)
		self=self:gsub("Z(.-)Z", function(c)
			local r=math.random(#c)
			return c and c:sub(r,r) or c
		end)
		for k,v in pairs(subst) do
			if #k>1 then
				self=self:gsub(k,v)
			end
		end
		self=self:gsub("(.)", function(c) 
			return subst[c] or c
		end)
	end
	return self
end

-- some functions to convert RGB values to a xterm-256colors index
-- ACKNOWLEDGMENT http://stackoverflow.com/questions/38045839/lua-xterm-256-colors-gradient-scripting
local abs, min, max, floor = math.abs, math.min, math.max, math.floor
local levels = {[0] = 0x00, 0x5f, 0x87, 0xaf, 0xd7, 0xff}

local function index_0_5(value) -- value = color component 0..255
   return floor(max((value - 35) / 40, value / 58))
end

local function nearest_16_231(r, g, b)   -- r, g, b = 0..255
   -- returns color_index_from_16_to_231, appr_r, appr_g, appr_b
   r, g, b = index_0_5(r), index_0_5(g), index_0_5(b)
   return 16 + 36 * r + 6 * g + b, levels[r], levels[g], levels[b]
end

local function nearest_232_255(r, g, b)  -- r, g, b = 0..255
   local gray = (3 * r + 10 * g + b) / 14
   -- this is a rational approximation for well-known formula
   -- gray = 0.2126 * r + 0.7152 * g + 0.0722 * b
   local index = min(23, max(0, floor((gray - 3) / 10)))
   gray = 8 + index * 10
   return 232 + index, gray, gray, gray
end

local function color_distance(r1, g1, b1, r2, g2, b2)
   return abs(r1 - r2) + abs(g1 - g2) + abs(b1 - b2)
end

function nearest_term256_color_index(r, g, b)   -- r, g, b = 0..255
   local idx1, r1, g1, b1 = nearest_16_231(r, g, b)
   local idx2, r2, g2, b2 = nearest_232_255(r, g, b)
   local dist1 = color_distance(r, g, b, r1, g1, b1)
   local dist2 = color_distance(r, g, b, r2, g2, b2)
   return dist1 < dist2 and idx1 or idx2
end

local unpack, tonumber = table.unpack or unpack, tonumber

local function convert_color_to_table(rrggbb)
   if type(rrggbb) == "string" then
      local r, g, b = rrggbb:match"(%x%x)(%x%x)(%x%x)"
      return {tonumber(r, 16), tonumber(g, 16), tonumber(b, 16)}
   else
      return rrggbb
   end
end

-- Takes special formated string with xterm256 color index, prints string with the color EscCode.
local function print_with_colors(str)
   print(
      str:gsub("@x(%d%d%d)",
         function(color_idx)
            return "\27[38;5;"..color_idx.."m"
         end)
      .."\27[0m"
   )
end

-- Takes special formated string with xterm256 color index, returns string with the color EscCode.
local function string_with_colors(str)
return str:gsub("@x(%d%d%d)",
         function(color_idx)
            return "\27[38;5;"..color_idx.."m"
         end)
      .."\27[0m" 
end

-- Takes string and RGB values, returns string with nearest xterm256 color EscCode.
function set_string_RGBColor(str,r,g,b)
    local colorstr = ("@x%03d"):format(nearest_term256_color_index(r,g,b))
    return string_with_colors(colorstr..str)
end

return Canvas
