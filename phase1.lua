local fonts = require("fonts")
local starfield = require("starfield")
local boss = require("boss")
local planet = require("planet")
local player = require("player")
local bullets = require("bullets")
local blorb = require("blorb")
local sounds = require("sounds")

local phase_one = {}
local win_combo = 700

function phase_one:update(dt)
	sounds.music:setVolume(.1)
	if player.dash_combo <= win_combo then
		starfield:update(dt)
		boss:update(dt)
		bullets:update(dt)
		player:update(dt)
		blorb:update(dt)
	end
end

local function showWinScreen()
	starfield:render()
	planet:render()

	local bigf = fonts.atSize(40)
	local smallf = fonts.atSize(28)
	local tinyf = fonts.atSize(16)
	local gfx = love.graphics
	gfx.push()
	-- g.scale(2,2)
	gfx.translate(200, 220)
	gfx.setFont(bigf)
	gfx.setColor({255,0,255})
	gfx.print("A RADICAL SURFER!")
	red_font()
	gfx.setFont(tinyf)
	gfx.print("SPACE to surf again", 70, 60)
	gfx.print("ESC to go back to less-radical things", 30, 90)
	gfx.pop()

end

function phase_one:render()
	if player.dash_combo <= win_combo then
		starfield:render()
		planet:render()
		boss:render()
		blorb:render()
		bullets:render()
		player:render()
	else
		showWinScreen()
	end
end

function phase_one:keypressed(key, scancode, isrepeat)
	if player.dash_combo > win_combo and key == "space" then
		player.dash_combo = 0
		-- This is set in start_menu.lua
		G = self.next
	end
end

return phase_one