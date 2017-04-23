local fonts = {}

local sizedFonts = {}


local fs = love.filesystem

-- love.graphics.setFilter("linear", "nearest");

function fonts.atSize(size) 
	if sizedFonts[size] == nil then
		sizedFonts[size] = love.graphics.newFont("assets/font/Hyperspace.otf", size)
	end
	return sizedFonts[size]
end

return fonts