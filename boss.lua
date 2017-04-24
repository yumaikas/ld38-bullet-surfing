local planet = require("planet")
local fonts = require("fonts")
local bullets = require("bullets")
local player = require("player")

require("utils")

local boss = {
	angle = 0.0,
	speed = 0.5,
	HP = 20,
	fire_speed = 0.75,
	shot_timer = 0.0,
	rm_render = false,
	rm_update = false,
}

function boss:update(dt)
	if math.fmod(math.floor(player.dash_combo / 50), 2) == 0 then
		self.angle = self.angle + (self.speed * dt * (0.1 * love.math.random(2, 18)))
	else
		self.angle = self.angle - (self.speed * dt * (0.1 * love.math.random(2, 18)))
	end
	self.shot_timer = self.shot_timer + dt
	local x, y = offsetByVector(planet.center, self.angle, planet.r + 15)
	if self.shot_timer * 2 > (love.math.random(1,5) - 0.75) and math.dist(x, y, player.x, player.y) > 90 then
		self.shot_timer = 0
		local tx, ty = offsetByVector({x = player.x, y = player.y}, love.math.random(1,180) / math.pi, love.math.random(0, 40))
		bullets:addWithTarget(x, y, tx, ty)
	end
end

local function red()
	love.graphics.setColor({255, 0, 0})
end
local function blue()
	love.graphics.setColor({0, 0, 255})
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
	if math.dist(player.x, player.y, x, y) < 60 then
		blue()
	end
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
	gfx.pop()
end


return boss