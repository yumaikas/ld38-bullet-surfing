local sounds = {}

sounds["shot"] = love.audio.newSource("assets/sound/BossShot.wav", "static")
sounds["pickup"] = love.audio.newSource("assets/sound/pickup.wav", "static")

return sounds