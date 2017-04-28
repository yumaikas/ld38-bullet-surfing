local planet = require("planet")
local fonts = require("fonts")
local sounds = require("sounds")
require("utils")
local win_combo = 700
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
	dash_recharge_time = 1.5,
	dash_recharge_timer = 0.0,
	dash_timer = 0.0,
	dash_max_time = 2.5,
	dash_time = 0.0,
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
	player.dash_timer = player.dash_timer + math.clamp(0.5,  player.dash_combo / win_combo , 1)

	if player.dash_timer > player.dash_max_time then
		player.dash_timer = player.dash_max_time
	end

	local top = player.dash_combo - player:previousTarget() + 1
	--print("top: ".. tostring(top))
	local bot = player:targetCombo() - player:previousTarget()
	--print("bot: ".. tostring(bot))

	local pitchVal = 2 * top / bot
	if player.dash_combo == player:previousTarget() then
		pitchVal = 4
	end
	-- print("Pitch".. tostring(pitchVal))
	sounds.pickup:setPitch(pitchVal)
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
	if self:isdashing() then
		return self.speed * self.dash_speed_boost
	else
		return self.speed
	end
end

function player:isdashing()
	return self.dash_timer > 0.0
end

function player:isRechargingDash()
	return not self:isdashing() and (self.dash_recharge_timer > 0.0)
end

function player:update(dt)
	key = love.keyboard
	local old_dx, old_dy = self.oldx - self.x, self.oldy - self.y
	local joySticks = love.joystick.getJoysticks()
	local j
	if #joySticks >= 1 then
		j = joySticks[1]
	end

	if (key.isDown("space") or 
		(#joySticks >=1 and j:isGamepadDown("a", "b", "x", "y")))
		and not self:isdashing() and not self:isRechargingDash() 
		and self.angle
		then
		self:comboup()
	end

	if not self:isdashing() and self.dash_combo > 0 then
		self:enterBulletTime()
		-- self.dash_max_combo = math.max(self.dash_combo, self.dash_max_combo)
		self.dash_recharge_timer = self.dash_recharge_time
		self.dash_combo = 0
	end

	if self:isRechargingDash() then
		self.dash_recharge_timer = self.dash_recharge_timer - dt
	end

	if self:isdashing() then
		self.dash_timer = math.clamp(0.0, self.dash_timer - dt, self.dash_max_time)
		self.dash_time = self.dash_time + dt
	else
		self.dash_time = 0
	end

	local dx, dy = 0, 0
	if not self:isdashing() then
		dx = 0
		dy = 0
	end

	if key.isDown("w") then
		dy = 0 - self:getSpeed() * dt
	end
	if key.isDown("s") then
		dy = self:getSpeed() * dt
	end
	if key.isDown("d") then
		dx = self:getSpeed() * dt
	end
	if key.isDown("a") then
		dx = 0 - self:getSpeed() * dt
	end

	-- Allow a gamepad to override the keyboard
	if #joySticks >= 1 then
		dx = j:getGamepadAxis("leftx")
		dy = j:getGamepadAxis("lefty")
	end

	if dx > 0 then
		self.scale.x = math.copysign(self.scale.x, 1)
	else
		self.scale.x = math.copysign(self.scale.x, -1)
	end

	self.moving = math.abs(dx) > 0.001

	-- TODO: Figure out how to clean this up to keep moving in a straight line
	-- local dx, dy = self.x - self.oldx, self.y - self.oldy


	local angle = math.atan2(dy, dx) 
	self.oldx, self.oldy = self.x, self.y
	if dx ~= 0 or dy ~= 0 then
		self.x, self.y = offsetByVector({x = self.x, y = self.y}, angle, self:getSpeed() * dt)
		self.x2, self.y2 = offsetByVector({x = self.x, y = self.y}, angle, 20)
		self.angle = angle
	elseif self.angle and self:isdashing() then
		self.x, self.y = offsetByVector({x = self.x, y = self.y}, self.angle, self:getSpeed() * dt)
		self.x2, self.y2 = offsetByVector({x = self.x, y = self.y}, self.angle, 20)
	end
	self:clamp()
end

function player:clamp()
	local px, py = planet.center.x, planet.center.y
	if math.dist(px, py, self.x, self.y) > planet.r then
		local angle = math.atan2(self.y - py, self.x - px)
		self.x, self.y = offsetByVector({x = px, y = py}, angle, planet.r)
	end
end

local targets = {0, 10, 40, 70, 100, 150, 200, 400, 700 }

function player:targetCombo()
	for i=1, #targets do
		if self.dash_combo < targets[i] then 
			return targets[i]
		end
	end
	return 1000
end

function player:previousTarget()
	for i=2, #targets do
		if self.dash_combo <= targets[i] then 
			return targets[i - 1]
		end
	end
	return 700
end

function player:render()
	local gfx = love.graphics
	local hp = self.hp_bar
	gfx.setColor({255,255,0})
	gfx.setFont(fonts.atSize(14))
	gfx.print({
			 {255,255,0}, "COMBO: " .. self.dash_combo .. " TARGET: " .. self:targetCombo(),
			 {255,255,0}, "  TIME:" .. string.format("%.2f", self.dash_time),
		},
		hp.x, hp.y - 10)
	gfx.line(hp.x,  hp.y + 10, 50 + hp.w * ((self.dash_timer) / self.dash_max_time), hp.y + 10)

	if self:isRechargingDash() then
		gfx.setColor({255,0,255})
		gfx.print("REST:", hp.x - 40, hp.y + 7)
		gfx.line(hp.x, hp.y + 16, hp.w * math.clamp(0, self.dash_recharge_timer / self.dash_recharge_time, 1), hp.y + 16)
	end


	-- Render shield
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

