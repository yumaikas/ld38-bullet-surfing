local planet = require("planet")
local fonts = require("fonts")
local bullets = require("bullets")
local player = require("player")

require("utils")

-- This is the crystals. For the sake of time, it is not being renamed, but that will happen post-compo
local bosses = {
	{
		angle = 0.0,
		speed = 0.5,
		shot_timer = 0.0,
		r = 10,
	}
}

function bosses:add(speed, r)
	table.insert(bosses, {
		angle = 0.0,
		speed = speed,
		shot_timer = 0.0,
		r = r,
	})
end

function bosses:update(dt)
	-- Clean up the bosses
	if player.dash_combo == 0 and #self > 1 then
		for i=#self, 2, -1 do
			table.remove(self, i)
		end
	end

	if player.dash_combo >= 100 and #self == 1 then
		self:add(-0.5, 20)
	end
	if player.dash_combo >= 200 and #self == 2 then
		self:add(1, 30)
	end

	for i = 1, #self do
		b = self[i]
		if math.fmod(math.floor(player.dash_combo / 50), 2) == 0 then
			b.angle = b.angle + (b.speed * dt * (0.1 * love.math.random(2, 18)))
		else
			b.angle = b.angle - (b.speed * dt * (0.1 * love.math.random(2, 18)))
		end
		b.shot_timer = b.shot_timer + dt
		local x, y = offsetByVector(planet.center, b.angle, planet.r + b.r)
		if b.shot_timer * 2 > (love.math.random(1,5) - 0.75) and math.dist(x, y, player.x, player.y) > 90 then
			b.shot_timer = 0
			local tx, ty = offsetByVector({x = player.x, y = player.y}, love.math.random(1,180) / math.pi, love.math.random(0, 40))
			bullets:addWithTarget(x, y, tx, ty)
		end
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
function bosses:render()
	local gfx = love.graphics
	for i=1, #self do
		local b = self[i]
		local x, y = offsetByVector(planet.center, b.angle, planet.r + 10)
		local xrDrum, yrDrum = 10, 5
		love.graphics.push()
		gfx.translate(x, y)
		gfx.rotate(b.angle - math.pi / 2)
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
end

return bosses