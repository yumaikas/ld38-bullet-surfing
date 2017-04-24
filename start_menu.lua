local fonts = require("fonts")
local starfield = require("starfield")
local boss = require("boss")
local planet = require("planet")
local player = require("player")
local phase_one = require("phase1")

local start_menu = {}

function start_menu:update(dt)
	starfield:update(dt)
	player:update(dt)
end

function start_menu:keypressed(key, scancode, isrepeat)
	if key == "w" or key == "s" or key == "a" or key == "d" or key == "space" then
		G = phase_one
	end
end

function yellow_font()
	local g = love.graphics
	g.setColor(255,255,0)
end
function white_font()
	local g = love.graphics
	g.setColor(255,255,255)
end

function red_font()
	local g = love.graphics
	g.setColor(255,0,0)
end

function render_first_menu()
	local bigf = fonts.atSize(40)
	local smallf = fonts.atSize(28)
	local tinyf = fonts.atSize(16)
	local g = love.graphics
	g.push()
	-- g.scale(2,2)
	g.translate(270, 220)
	g.setFont(bigf)
	red_font()
	g.print("Omega Llama")
	white_font()
	g.setFont(smallf)
	g.print("in", 110, 50)
	g.setFont(bigf)
	g.setColor({255,0,255})
	g.print("BULLET SURFING", -20, 90)
	g.setFont(tinyf)
	g.setColor({0,255,255})
	g.print("W/A/S/D and Spacebar. ESC exits", -10, 150)
	g.pop()
end

function start_menu:render()
	starfield:render()
	planet:render()
	render_first_menu()
end

return start_menu