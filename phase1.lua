local fonts = require("fonts")
local starfield = require("starfield")
local boss = require("boss")
local planet = require("planet")
local player = require("player")

local phase_one = {}

function phase_one:update(dt)
	starfield:update(dt)
	boss:update(dt)
	player:update(dt)
end

function phase_one:render()
	starfield:render()
	planet:render()
	boss:render()
	player:render()
end

function phase_one:keypressed(key, scancode, isrepeat)
	-- body
end

return phase_one