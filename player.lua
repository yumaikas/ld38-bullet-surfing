local planet = require("planet")
local fonts = require("fonts")
local sounds = require("sounds")
require("utils")
local player = {
	-- Renderable
	x = planet.center.x,
	y = planet.center.y,
	x2 = 0.0,
	y2 = 0.0,
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
	dash_combo = 0,
	dash_max_combo = 1,

	spell_offset = { x = 20, y = 20 },
	can_shoot = false,
	-- HP, to be used by player_health
	HP = 10,
	MaxHP = 10,
	hit_timer = 2.1,
	hit_delay = 2,
	hp_bar = {
		x = 50,
		y = 25,
		w = 700
	},
}

function player:comboup()
	self.dash_combo = self.dash_combo + 1
	sounds.pickup:setPitch(0.1 * love.math.random(8,12))
	sounds.pickup:stop()
	sounds.pickup:play()
end

function player:heal(damage)
	self.HP = self.HP + damage
	self.HP = math.clamp(0, self.HP, 10)
	--sounds["pickup.wav"]:play()
end

function player:harm(damage)
	self.HP = self.HP - damage
	self.HP = math.clamp(0, self.HP, 10)
	self.hit_timer = 0
	--sounds["hurt2.wav"]:play()
end

function player:scaled(name)
	return self[name] * self.scale
end

function player:is_vulnerable()
	return (self.hit_timer > self.hit_delay) and not self:isdashing()
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
	local old_dx, old_dy = self.x - self.oldx, self.y - self.oldy
	self.oldx, self.oldy = self.x, self.y

	self.moving = false
	if key.isDown("space") and (self.dash_timer > self.dash_recharge_time) then
		self.dash_timer = 0.0
	end

	if self:isdashing() or self:isRechargingDash() then
		self.dash_timer = self.dash_timer + dt
	end

	if self.hit_timer < self.hit_delay then
		self.hit_timer = self.hit_timer + dt
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

	-- TODO: Figure out how to clean this up to keep moving in a straight line
	local dx, dy = self.x - self.oldx, self.y - self.oldy
	if dx == 0 and dy == 0 and self:isdashing() then
		local nangle = math.atan2(old_dx, old_dy) 
		self.x, self.y = offsetByVector({x = self.x, y = self.y}, nangle, self:getSpeed() * dt)
		self.x2, self.y2 = offsetByVector({x = self.x, y = self.y}, nangle, 20)
		self:clamp()
		return
	end

	if not self:isdashing() and self.dash_combo > 0 then
		if self.dash_combo > self.dash_max_combo then
			self:enterBulletTime()
		end
		self.dash_max_combo = math.max(self.dash_combo, self.dash_max_combo)
		self.dash_combo = 0
	end

	local angle = math.atan2(dy, dx)
	self.x2, self.y2 = offsetByVector({x = self.x, y = self.y}, angle, 20)
	self:clamp()
end

function player:clamp()
	local px, py = planet.center.x, planet.center.y
	if math.dist(px, py, self.x, self.y) > planet.r then
		local angle = math.atan2(self.y - py, self.x - px)
		self.x, self.y = offsetByVector({x = px, y = py}, angle, planet.r)
	end
end

function player:render()
	local gfx = love.graphics
	local hp = self.hp_bar
	gfx.setColor({255,255,0})
	gfx.setFont(fonts.atSize(14))
	gfx.print({
			 {255,255,0}, "COMBO: " .. self.dash_combo .. "/" .. self.dash_max_combo ,
			 {255,255,0}, "  TIME:" .. string.format("%.2f", self.dash_time - self.dash_timer),
		},
		hp.x, hp.y - 10)
	gfx.line(hp.x,  hp.y + 10, 50 + hp.w * math.clamp(0.1, (self.dash_combo / self.dash_max_combo), 1), hp.y + 10)

	if self:isRechargingDash() then
		gfx.setColor({255,0,255})
		gfx.print("REST:", hp.x - 40, hp.y + 7)
		gfx.line(hp.x, hp.y + 16, hp.w * math.clamp(0, self.dash_timer / self.dash_recharge_time, 1), hp.y + 16)
	end

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

