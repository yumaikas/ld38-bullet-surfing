local planet = require("planet")
local player = {
	-- Renderable
	x = planet.center.x,
	y = planet.center.y,
	oldx = 0.0,
	oldy = 0.0,
	scale = {
		x = 1.0,
		y = 1.0
	},

	moving = false,

	rotation = 0,
	w = 0,
	h = 0,

	-- Flags for collections
	rm_render = false,
	rm_update = false,
	rm_collidable = false,

	-- Updatable
	update = player_update,

	-- Custom player information
	speed = 200,
	dash_time = .2,
	dash_recharge_time = 1.2,
	dash_timer = .21,
	dash_speed_boost = 2.5,

	offset = {
		x = 10,
		y = 10,
	},
	spell_offset = { x = 20, y = 20 },
	can_shoot = false,
	-- HP, to be used by player_health
	HP = 4,
	hit_timer = 2.1,
	hit_delay = 2,
}


function player:heal(damage)
	self.HP = self.HP + damage
	self.HP = math.clamp(0, self.HP, 4)
	sounds["pickup.wav"]:play()
end

function player:harm(damage)
	self.HP = self.HP - damage
	self.HP = math.clamp(0, self.HP, 4)
	self.hit_timer = 0
	sounds["hurt2.wav"]:play()
end

function player:scaled(name)
	return self[name] * self.scale
end

function player:is_vulnerable()
	return self.hit_timer > self.hit_delay
end

function player:getSpeed()
	if self.dash_timer > self.dash_time then
		return self.speed
	else
		return self.speed * self.dash_speed_boost
	end
end

function player:isdashing()
	return self.dash_timer < self.dash_time
end

function player:isRechargingDash()
	return not self:isdashing() and (self.dash_timer < self.dash_recharge_time)
end

function player:update(dt)
	key = love.keyboard
	self.oldx, self.oldy = self.x, self.y
	self.moving = false
	if key.isDown("space") and (self.dash_timer > self.dash_recharge_time) then
		self.dash_timer = 0.0
	end

	if self:isdashing() or self:isRechargingDash() then
		self.dash_timer = self.dash_timer + dt
	end

	if key.isDown("w") then
		self.y = self.y - self:getSpeed() * dt
	end
	if key.isDown("s") then
		self.y = self.y + self:getSpeed() * dt
	end
	if key.isDown("d") then
		self.x = self.x + self:getSpeed() * dt
		self.scale.x = math.copysign(self.scale.x, 1)
		self.moving = true
	end
	if key.isDown("a") then
		self.x = self.x - self:getSpeed() * dt
		self.scale.x = math.copysign(self.scale.x, -1)
		self.moving = true
	end


	-- TODO: Implement falloff death
	-- TODO: Implement 
end

function player:render()
	local gfx = love.graphics
	gfx.push()
	gfx.translate(self.x, self.y)
	if self:isdashing() then
		gfx.push()
		local dx, dy = self.x - self.oldx, self.y - self.oldy
		gfx.rotate(math.atan2(dy, dx))
		gfx.translate(12, 0)
		gfx.setColor({255,0,255})
		gfx.line(
			-20, -20,
			20, -20,
			40, -5,
			40, 5,
			20, 20,
			-20, 20
		)
		gfx.pop()
	end

	gfx.scale(self.scale.x, self.scale.y)
	gfx.translate(-7.5, 0)

	local x_off = 0.0
	if self.moving then
		x_off = 3
	end

	gfx.setColor({255,255,0})



	-- Rectanglular body
	gfx.polygon("line",
		0,0,
		15,0,
		15,7,
		0,7)

	gfx.line(
		0,0,
		-3 - x_off,7)

	-- Legs
	gfx.line(
		15, 7,
		15 - x_off, 13)
	gfx.line(
		13, 7,
		13 - x_off, 13)
	gfx.line(
		0, 7,
		0 - x_off, 13)
	gfx.line(
		3, 7,
		3 - x_off, 13)

	--Neck/Head
	gfx.line(
		15, 0,
		15 + x_off, -6,
		22 + x_off, -6,
		22 + x_off, -8,
		15 + x_off, -8)

	-- Ear(s)
	gfx.line(
		15 + x_off, -8,
		15 + 2 * x_off, - 12)

	gfx.pop()
end

return player

