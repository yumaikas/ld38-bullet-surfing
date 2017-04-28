local fonts = require("fonts")
local starfield = require("starfield")
local boss = require("boss")
local planet = require("planet")
local player = require("player")
local phase_one = require("phase1")
local sounds = require("sounds")

local start_menu = {}

function start_menu:update(dt)
	starfield:update(dt)
	player:update(dt)
	-- sounds.music:play()
	sounds.music:setVolume(0.5)
end

function start_menu:keypressed(key, scancode, isrepeat)
	if key == "w" or key == "s" or key == "a" or key == "d" or key == "space" then
		phase_one.next = start_menu
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
	local gfx = love.graphics
	gfx.push()
	-- g.scale(2,2)
	gfx.translate(270, 220)
	gfx.setFont(bigf)
	red_font()
	gfx.print("Omega Llama")
	white_font()
	gfx.setFont(smallf)
	gfx.print("in", 110, 50)
	gfx.setFont(bigf)
	gfx.setColor({255,0,255})
	gfx.print("BULLET SURFING", -20, 90)
	gfx.setFont(tinyf)
	gfx.setColor({0,255,255})
	gfx.print("W/A/S/D and Spacebar. ESC exits", -10, 150)
	gfx.pop()
end

function start_menu:render()
	starfield:render()
	planet:render()
	render_first_menu()
end

return start_menu