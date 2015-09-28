lua-drawille
============


Lua implementation of [drawille](http://github.com/asciimoo/drawille)


### Usage

```lua
Canvas = require "drawille"

local c = Canvas.new()

for i=0,360*4 do
    if (i % 15) == 0 then
        c:set(i/15, math.floor(math.sin(i*(math.pi/180))*4))
    end
end

print c:frame()
```


### Bugs

Bugs or suggestions? Visit the [issue tracker](https://github.com/asciimoo/lua-drawille/issues).

(Tested only with `urxvt` terminal and `fixed` font.)


### LICENSE

```
drawille is free software: you can redistribute it and/or modify
it under the terms of the GNU Affero General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

drawille is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License
along with drawille. If not, see < http://www.gnu.org/licenses/ >.

(C) 2014- by Adam Tauber, <asciimoo@gmail.com>
```
