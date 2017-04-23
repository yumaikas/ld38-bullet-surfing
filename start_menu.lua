local fonts = require("fonts")
local starfield = require("starfield")()

local start_menu = {}

function start_menu:update(dt)
	starfield:update(dt)
end

function yellow_font()
	local g = love.graphics
	g.setColor(0,255,255)
end
function white_font()
	local g = love.graphics
	g.setColor(255,255,255)
end

function red_font()
	local g = love.graphics
	g.setColor(255,0,0)
end

function start_menu:render()
	local bigf = fonts.atSize(80)
	local smallf = fonts.atSize(28)
	local g = love.graphics
	g.push()
	-- g.scale(2,2)
	g.translate(210, 180)
	g.setFont(bigf)
	red_font()
	g.print("PSI-land")
	g.translate(80, 110)
	white_font()
	g.setFont(smallf)
	yellow_font()
	g.print("Omega Llama")
	g.translate(90, 40)
	g.print("vs")
	g.translate(-90 - 80, 40)
	g.print("The Mad Alien Cotxahol")
	g.pop()
	starfield:render()
end

return start_menu