local planet = {
	center = {x = 400, y = 300},
	r = 250,
}

-- TODO: Add movable grass
function planet:render()
	local gfx = love.graphics
	local r = 250
	gfx.setColor({0,0,0})
	gfx.circle("fill", self.center.x, self.center.y, self.r, 100)
	gfx.setColor({255,255,255})
	gfx.circle("line", 400, 300, r, 100)
end

return planet