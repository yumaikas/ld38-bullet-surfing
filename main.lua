local typecheck = require("typecheck")
local start_menu = require("start_menu")
local fonts = require("fonts")
local planet = require("planet")
-- Loading in the set of tiems

G = {}

function love.load()
	-- body
	G = start_menu
	love.math.setRandomSeed(os.time())
	-- love.mouse.setGrabbed(true)
	require("starfield")
	mouse_down_x = planet.center.x 
	mouse_down_y = planet.center.y
end

-- GLOBAL HAX
function love.mousepressed(x, y, button, istouch) 
	if button == 1 then
		mouse_down_x = x
		mouse_down_y = y
	end
end

function love.gamepadpressed(_joystick, button)
	love.keypressed("space", 0, false)
	if button == "back" then
		love.event.quit()
	end

end

function love.keypressed(key, scancode, isrepeat)
	if key == "escape" then
		love.event.quit()
	end
	G:keypressed(key, scancode, isrepeat)
end

function love.draw()
	love.graphics.setFont(fonts.atSize(10))
	love.graphics.print("FPS: " .. tostring(love.timer.getFPS()), 10, 590)

	if G.render then
		G:render()
		return
	end
	
	if shake_timer < shake_time then
		love.graphics.push()
		love.graphics.translate(math.prandom(-shake_mag, shake_mag), math.prandom(-shake_mag, shake_mag))
	end
	if shake_timer < shake_time then
		love.graphics.pop()
	end
end

function love.update(dt)
	if G.update then
		G:update(dt)
		return
	end
end

