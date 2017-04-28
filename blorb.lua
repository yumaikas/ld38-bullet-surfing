local planet = require("planet")
local player = require("player")
local sounds = require("sounds")

require("utils")

-- TODO: Mix the sounds a bit.

local b_sounds = {
	sounds.blorbone,
	sounds.blorbtwo,
	sounds.blorbthree,
}

for i=1, #b_sounds do
	b_sounds[i]:setVolume(.5)
end

local blorb = {
	instances = {}
}

local function baseBlorb()
	return {
		x = planet.center.x,
		y = planet.center.y,
		r = 20,
		dr = 0,
		speed = 150,
		tx = planet.center.x,
		ty = planet.center.y,
	}
end

local function makeBlorb(from)
	return {
		x = from.x,
		y = from.y,
		r = from.r,
		dr = from.dr,
		speed = from.speed,
		tx = from.x,
		ty = from.y,
	}
end

function blorb:render()
	local gfx = love.graphics

	for i=1, #self.instances do 
		local b = self.instances[i]
		gfx.setColor({255,0,255})
		gfx.circle("line", b.x, b.y, b.r)
	end
end

function blorb:update(dt)
	-- Clear table
	if player.dash_combo == 0 and #self.instances > 0 then
		for i= #self.instances, 1, -1 do
			table.remove(self.instances, i)
			b_sounds[i]:stop()
		end
	end
	-- 
	if player.dash_combo >= 10 and #self.instances == 0 then
		table.insert(self.instances, baseBlorb())
	end

	if player.dash_combo >= 150 and #self.instances == 1 then
		table.insert(self.instances, makeBlorb(self.instances[1]))
		self.instances[2].dr = 7
		self.instances[2].speed = 100

	end

	if player.dash_combo >= 400 and #self.instances == 2 then
		table.insert(self.instances, makeBlorb(self.instances[2]))
		self.instances[3].dr = 8
		self.instances[3].dr = 125
	end

	if player.dash_combo >= 40 and #self.instances == 1 and self.instances[1].dr == 0 then
		self.instances[1].dr = 6
	end

	for i=1, #self.instances do 
		local b = self.instances[i]

		b_sounds[i]:play()
		b_sounds[i]:setPitch(math.clamp(0.0001, 1/ (b.r / 20), 4))
		-- Oscillate
		if b.r > 30 or b.r < 10 then
			b.dr = -b.dr
		end
		b.r = b.r + (b.dr * dt)

		--Movement
		if player.dash_combo >= 70 and math.dist(b.tx, b.ty, b.x, b.y) < 2 then
			b.tx, b.ty = offsetByVector({
				x = planet.center.x,
				y = planet.center.y
			}, 
			love.math.random(1, 360) * math.pi / 180,  -- Random angle
			love.math.random(0, planet.r)             -- Random distance
			)
		end

		if math.dist(b.tx, b.ty, b.x, b.y) > 2 then
			b.x, b.y = offsetByVector({x = b.x, y = b.y}, math.atan2(b.ty - b.y, b.tx - b.x), dt * b.speed)
		end

		-- Collision
		local d1 = math.dist(player.x, player.y, b.x, b.y)
		local d2 = math.dist(player.x2, player.y2, b.x, b.y)
		if d1 < b.r or d2 < b.r then
			player.dash_timer = 0.0
			player.dash_recharge_timer = player.dash_recharge_time
		end
	end

end

return blorb