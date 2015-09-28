bit=bit or require "bit"

local pixel_map = {{0x01, 0x08},
                   {0x02, 0x10},
                   {0x04, 0x20},
                   {0x40, 0x80}}

-- braille unicode characters starts at 0x2800
local braille_char_offset = 0x2800

local Canvas = {}
Canvas.__index = Canvas

function Canvas.new()
    local self = setmetatable({}, Canvas)
    self.clear(self)
    return self
end

function Canvas.clear(self)
    self.chars = {}
end

function Canvas.set(self, x, y)
    local row = math.floor(y / 4)
    local col = math.floor(x / 2)
    if self.chars[row] == nil then
        self.chars[row] = {}
    end
    if self.chars[row][col] == nil then
        self.chars[row][col] = 0
    end
    self.chars[row][col] = bit.bor(self.chars[row][col], pixel_map[(y % 4) + 1][(x % 2) + 1])
end

function Canvas.frame(self)
    local mincol, maxcol, minrow, maxrow = 0, 0, 0, 0
    for rk, rv in pairs(self.chars) do
        minrow = math.min(rk, minrow)
        maxrow = math.max(rk, maxrow)
        for ck, cv in pairs(rv) do
            mincol = math.min(ck, mincol)
            maxcol = math.max(ck, maxcol)
        end
    end
    local outstr=""
    for row=minrow,maxrow do
        if self.chars[row] then
            for col=mincol,maxcol do
                if self.chars[row][col] then
                    local char = braille_char_offset + self.chars[row][col]
                    outstr=outstr..string.char(128+64+32+bit.band(15, bit.rshift(char, 12)))
                    outstr=outstr..string.char(bit.bor(128, bit.band(63, bit.rshift(char, 6))))
                    outstr=outstr..string.char(bit.bor(128, bit.band(char, 63)))
                else
                    outstr=outstr.." "
                end
            end
        end
        outstr=outstr.."\n"
    end
    return outstr
end

return Canvas
