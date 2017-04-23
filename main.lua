local typecheck = require("typecheck")
local start_menu = require("start_menu")
local fonts = require("fonts")
-- Loading in the set of tiems
local updateables = {}
local renderables = {}
local enemies = {}
local player_spells = {}
local other_spells = {}

G = {}

function love.load()
	-- body
	G = start_menu
	love.math.setRandomSeed(os.time())
	require("starfield")
end

function love.draw()
	love.graphics.setFont(fonts.atSize(10))
	local w, h = love.graphics.getDimensions()
	love.graphics.print("w: " ..w)
	love.graphics.print("h: " ..h, 0, 10)

	if G.render then
		G:render()
		return
	end
	if shake_timer < shake_time then
		love.graphics.push()
		love.graphics.translate(math.prandom(-shake_mag, shake_mag), math.prandom(-shake_mag, shake_mag))
	end
	--renderTable(lavaPictureName)
	for i, surface in ipairs(renderables) do
		if surface.render then
			-- Some objects need to control how they render
			surface:render()
		elseif surface.offset then
			-- Other objects embed images/information
			local offset = surface.offset
			love.graphics.draw(
				surface.image,
				surface.x,
				surface.y,
				surface.rotation,
				surface.scale.x,
				surface.scale.y,
				offset.x,
				offset.y)
		else
			love.graphics.draw(surface.image, surface.x, surface.y, surface.rotation, surface.scale.x, surface.scale.y)
		end
	end
	local fps = tostring(love.timer.getFPS())
	-- font.printLineRightAligned(768, 460, fps .. " FPS")
	--[[
	if player.HP == 0 then
		w, h = images["game_over2.png"]:getDimensions()
		love.graphics.draw(images["game_over2.png"], g_height / 2, g_width / 2, 0, 2, 2, w/2, h/2)
	elseif count_down:isBoss() and dragon.HP == 0 then
		w, h = images["you_win2.png"]:getDimensions()
		love.graphics.draw(images["you_win2.png"], g_height / 2, g_width / 2, 0, 2, 2, w/2, h/2)
	end
	]]
	if shake_timer < shake_time then
		love.graphics.pop()
	end
end

function love.update(dt)
	if G.update then
		G:update(dt)
		return
	end

	if is_menu then
		update_menu(dt)
		return
	end
	if shake_timer < shake_time then
		shake_timer = shake_timer + dt
	end
	if paused then
		return
	end
	if player.HP == 0 then
		end_game_timer = end_game_timer + dt
		return
	end

	flux.update(dt)
	local spawn_new = false
	for i, enemy in ipairs(enemies) do
		for i, shot in ipairs(player_spells) do
			if (math.dist(enemy.x, enemy.y, shot.x, shot.y) < (enemy.r + shot.r)) then
				shot.rm_update = true
				shot.rm_render = true
				shot.rm_player_spell = true
				enemy:harm(1)
				shake_timer = 0
				if enemy.rm_enemy and enemy.rm_player_spell == nil then
					spawn_new = true
				end
			end
		end
	end

	for i=1, #other_spells do
		local _spell = other_spells[i]
		if (not _spell.rm_other_spell) and math.dist(_spell.x, _spell.y, player.x, player.y) < _spell.r  then
			_spell:collide()
		end
	end
	for i, v in ipairs(updateables) do
		v:update(dt)
	end

	function nilTable(array, key)
		for i=#array, 1, -1 do
			if array[i][key] then
				table.remove(array, i)
			end
		end
	end

	nilTable(updateables, "rm_update")
	nilTable(renderables, "rm_render")
	nilTable(enemies, "rm_enemy")
	nilTable(player_spells, "rm_player_spell")
	nilTable(other_spells, "rm_other_spell")
end

local isUpdatable = typecheck.checker({
	rm_update = "boolean",
	update = "function",
})

function addUpdateable(item)
	valid, msg = isUpdatable(item, update_reqs)
	if valid then
		table.insert(updateables, item)
	else
		print(msg)
		error("Tried to add non-updatable to updateables")
	end
end

local isRenderFunc = typecheck.checker({
	rm_render = "boolean",
	render = "function",
})

local canRender = typecheck.checker({
	rm_render = "boolean",
	image = "userdata",
	x = "number",
	y = "number",
	rotation = "number",
	scale = "table",
})

function addRenderable(item)
	valid, msg = isRenderFunc(item)
	valid2, msg2 = canRender(item)
	if valid or valid2 then
		table.insert(renderables, item)
	else
		print (msg)
		print (msg2)
		error("Tried to add non-renderable to renerables")
	end
end