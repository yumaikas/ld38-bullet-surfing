local sounds = {}

sounds["shot"] = love.audio.newSource("assets/sound/BossShot.wav", "static")
sounds["pickup"] = love.audio.newSource("assets/sound/pickup.wav", "static")
sounds["blorbone"] = love.audio.newSource("assets/sound/Blurb.wav", "static")
sounds["blorbtwo"] = love.audio.newSource("assets/sound/Blurb.wav", "static")
sounds["blorbthree"] = love.audio.newSource("assets/sound/Blurb.wav", "static")
sounds.music = love.audio.newSource("assets/sound/music.wav")
sounds.music:setLooping(true)


return sounds