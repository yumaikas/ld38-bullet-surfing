require("utils")
-- local debug = require("lovedebug")

local function update(self, dt)
	for i=1, #self.stars do
		local s = self.stars[i]
		s.timer = s.timer + dt

		if s.timer > s.timing[s.states:current()] then
			s.states:goNext()
			s.timer = 0.0
		end
	end
end

local function render(self) 
	local gfx = love.graphics
	gfx.setPointSize(1,1)
	gfx.push()
	for i=1, #self.stars do
		local s = self.stars[i]
			if s.states:current() == "up" then
			gfx.setColor(s.color)
			gfx.points(s.coords[1], s.coords[2])
		end
	end
	gfx.pop()
end

local function makeStar() 
	local w, h = 800, 600
	local r = love.math.random(100, 255)
	local g = love.math.random(100, 255)
	local b = love.math.random(100, 255)
	-- print("r".. r .. "g" .. g .."b"..b)
	local x = love.math.random(5, w)
	local y = love.math.random(5, h)

	local up = math.prandom(1, 10)
	local down = math.prandom(1, 10)

	local states = rotatingArray({"up", "down"})
	states.idx = love.math.random(1, 2)

	return {
		color = {r,g,b},
		coords = {x,y},
		timing = {
			["up"] = up,
			["down"] = down,
		},
		timer = 0.0,
		states = states,
	}
end

function make_starfield()
	local starfield = {
		stars = {},
		update = update,
		render = render,
		rm_render = false,
		rm_update = false,
	}
	for i=1, 100 do
		table.insert(starfield.stars, makeStar())
	end
	return starfield
end

return make_starfield
