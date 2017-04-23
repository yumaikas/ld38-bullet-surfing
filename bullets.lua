local player = require("player")
local planet = require("planet")
require("utils")

local bullets = {
	shots = {},
	turrets = {}
}

function bullets:addWithTarget(x,y,tx, ty)
	local angle = math.atan2(ty-y, tx - x)
	local shooty = {
		speed = 150,
		ox = x,
		oy = y,
		x = x,
		y = y,
		dx = math.cos(angle),
		dy = math.sin(angle),
		remove = false,
	}
	table.insert(self.shots, shooty)
end

function bullets:render()
	local gfx = love.graphics

	for i=1, #self.shots do
		local b = self.shots[i]
		gfx.setColor({255,10,10})
		gfx.circle("line", b.x, b.y, 5)
	end
end

function bullets:update(dt)
	for i=1, #self.shots do
		local b = self.shots[i]
		b.x = b.x + (b.dx * b.speed * dt)
		b.y = b.y + (b.dy * b.speed * dt)
		if math.dist(b.ox,b.oy, b.x, b.y) > 500 then
			b.remove = true
		end
	end

	for i=#self.shots, 1, -1 do
		if self.shots[i].remove then
			table.remove(self.shots, i)
		end	
	end

end


return bullets