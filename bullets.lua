local player = require("player")
local planet = require("planet")
local sounds = require("sounds")
local blorb = require("blorb")

local win_combo = 700

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
				player:comboup()
				b.remove = true
			elseif d < 10 then
				b.remove = true
			end
		end

		for i=1, #blorb.instances do
			local bl = blorb.instances[i]

			-- Where 5 is the bullet render radius
			if math.dist(bl.x, bl.y, b.x, b.y) < bl.r + 5  then
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
end


return bullets