
local Point3D={}
Point3D.__index=Point3D
setmetatable(Point3D, {
	__call=function(cls, ...)
		return cls.new(...)
	end,
})
function Point3D.new(x,y,z)
    local self = setmetatable({}, Point3D)
	self.x, self.y, self.z = x or 0, y or 0, z or 0
	return self
end
function Point3D:rotateX(angle)
	-- Rotates the point around the X axis by the given angle in degrees. 
	local rad = math.rad(angle)
	local cosa = math.cos(rad)
	local sina = math.sin(rad)
	local y = self.y * cosa - self.z * sina
	local z = self.y * sina + self.z * cosa
	return Point3D(self.x, y, z)
end
function Point3D:rotateY(angle)
	-- Rotates the point around the X axis by the given angle in degrees. 
	local rad = math.rad(angle)
	local cosa = math.cos(rad)
	local sina = math.sin(rad)
	local z = self.z * cosa - self.x * sina
	local x = self.z * sina + self.x * cosa
	return Point3D(x, self.y, z)
end
function Point3D:rotateZ(angle)
	-- Rotates the point around the X axis by the given angle in degrees. 
	local rad = math.rad(angle)
	local cosa = math.cos(rad)
	local sina = math.sin(rad)
	local x = self.x * cosa - self.y * sina
	local y = self.x * sina + self.y * cosa
	return Point3D(x, y, self.z)
end
function Point3D:project(win_width, win_height, fov, viewer_distance)
	-- Transforms this 3D point to 2D using a perspective projection. 
	local factor = fov / (viewer_distance + self.z)
	local x = self.x * factor + win_width / 2
	local y = -self.y * factor + win_height / 2
	return Point3D(x, y, 1)
end
function Point3D.culling(p1, p2, p3)
	local d1x, d1y, d2x, d2y
	d1x=p3.x-p1.x
	d1y=p3.y-p1.y
	d2x=p3.x-p2.x
	d2y=p3.y-p2.y
	local z=(d1x*d2y)-(d1y*d2x)
	return z<0
end

return Point3D
