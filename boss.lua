local planet = require("planet")
local fonts = require("fonts")
local bullets = require("bullets")

require("utils")

local boss = {
	angle = 0.0,
	speed = 0.5,
	fire_speed = 0.75,
	r_fire_timer = 0.0,
	l_fire_timer = 0.0,
	shot_timer = 0.0,
	rm_render = false,
	rm_update = false,
}

function boss:update(dt)
	self.angle = self.angle +(self.speed * dt)
	self.shot_timer = self.shot_timer + dt
end

local function red()
	love.graphics.setColor({255, 0, 0})
end
local function black()
	love.graphics.setColor({0, 0, 0})
end

function boss:render()
	local gfx = love.graphics
	local x, y = offsetByVector(planet.center, self.angle, planet.r + 10)
	local xrDrum, yrDrum = 10, 5
	love.graphics.push()
	gfx.translate(x, y)
	gfx.rotate(self.angle - math.pi / 2)
	gfx.translate(0, 5)
	gfx.setColor({255, 0, 0})
	-- TODO: draw arms
	gfx.line(-20, -5, -12, 5)
	gfx.line(20, -5, 12, 5)

	-- Draw drums
	black()
	gfx.ellipse("fill", -20, -5, xrDrum, yrDrum)
	red()
	gfx.ellipse("line", -20, -5, xrDrum, yrDrum)

	black()
	gfx.ellipse("fill", 20, -5, xrDrum, yrDrum)
	red()
	gfx.ellipse("line", 20, -5, xrDrum, yrDrum)
	-- TODO: draw arms
	-- Draw body
	-- (-12, 5) (25)
	local x,y,w,h,r, seg = -12, 5, 24, 10, 3, 3, 10
	gfx.rectangle("line", x, y,w, h)
	-- Draw neck
	gfx.line(0,20, 0, 15)
	-- Draw head
	--gfx.ellipse("line", 0, 25, 8, 5)
	gfx.polygon("line", 
		-8, 35,
		-- -5, 29,
		-16, 30,
		0, 20,
		16, 30,
		-- 5, 29,
		8, 35
		)
	gfx.line(
		16, 30,
		4, 27,
		6, 31 )
	gfx.line(
		-6, 31,
		-4, 27,
		-16, 30)
	--gfx.line(-6, 25, -2, 20)
	gfx.pop()
end


return boss