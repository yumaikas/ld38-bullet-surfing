local player = require("player")
local planet = require("planet")
local sounds = require("sounds")
require("utils")

local bullets = {
	shots = {},
	turrets = {},
	bullet_time = 5.0,
	bullet_timer = 5.1,
}

function bullets:addWithTarget(x,y,tx, ty)
	sounds.shot:setPitch(0.1* love.math.random(8,12))
	sounds.shot:play()

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

	gfx.setColor({255,0,255})
	gfx.circle("line", planet.center.x, planet.center.y, 20)
end

function player:enterBulletTime()
	bullets.bullet_timer = 0.0
end

function player:inBulletTime()
	return bullets.bullet_timer < bullets.bullet_time
end

function bullets:update(dt)
	if self.bullet_timer < self.bullet_time then
		self.bullet_timer = self.bullet_timer + dt 
	end

	for i=1, #self.shots do
		local b = self.shots[i]

		if self.bullet_timer < self.bullet_time then
			b.x = b.x + (b.dx * b.speed * dt / 4)
			b.y = b.y + (b.dy * b.speed * dt / 4)
		else 
			b.x = b.x + (b.dx * (b.speed + (player.dash_max_combo / 4)) * dt)
			b.y = b.y + (b.dy * (b.speed + (player.dash_max_combo / 4)) * dt)
		end

		local d = math.dist(b.x, b.y, player.x, player.y)
		local d2 = math.dist(b.x, b.y, player.x2, player.y2)
		if d < 20 or d2 < 20 then
			if player:isdashing() then
				player:heal(0.5)
				player.dash_timer = math.clamp(-2.1, player.dash_timer - math.clamp(0.25,  player.dash_combo / player.dash_max_combo, 1), 4)
				player:comboup()
				b.remove = true
			elseif d < 10 then
				player:harm(1)
				b.remove = true
			end
		end

		if math.dist(b.ox,b.oy, b.x, b.y) > 500 then
			b.remove = true
		end
	end

	for i=#self.shots, 1, -1 do
		if self.shots[i].remove then
			table.remove(self.shots, i)
		end	
	end

	if math.dist(player.x, player.y, planet.center.x, planet.center.y) <= 20 then
		player.dash_timer = player.dash_time + 0.1
	end
end


return bullets