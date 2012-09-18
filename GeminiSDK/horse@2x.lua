

-- This file is for use with Corona Game Edition
--
-- The function getSpriteSheetData() returns a table suitable for importing using sprite.newSpriteSheetFromData()
--
-- Usage example:
--			local zwoptexData = require "ThisFile.lua"
-- 			local data = zwoptexData.getSpriteSheetData()
--			local spriteSheet = sprite.newSpriteSheetFromData( "Untitled.png", data )
--
-- For more details, see http://developer.anscamobile.com/content/game-edition-sprite-sheets

local horse = {}
local horse_mt = {__index = Planet}

function horse.getSpriteSheetData()

	local sheet = {
		frames = {
		
			{
				name = "01.png",
				spriteColorRect = { x = 0, y = 8, width = 438, height = 310 }, 
				textureRect = { x = 4, y = 310, width = 438, height = 310 }, 
				spriteSourceSize = { width = 227, height = 161 }, 
				spriteTrimmed = true,
				textureRotated = false
			},
		
			{
				name = "02.png",
				spriteColorRect = { x = 10, y = 2, width = 416, height = 318 }, 
				textureRect = { x = 860, y = 310, width = 416, height = 318 }, 
				spriteSourceSize = { width = 226, height = 161 }, 
				spriteTrimmed = true,
				textureRotated = false
			},
		
			{
				name = "03.png",
				spriteColorRect = { x = 24, y = 4, width = 406, height = 294 }, 
				textureRect = { x = 458, y = 4, width = 406, height = 294 }, 
				spriteSourceSize = { width = 227, height = 161 }, 
				spriteTrimmed = true,
				textureRotated = false
			},
		
			{
				name = "04.png",
				spriteColorRect = { x = 22, y = 0, width = 408, height = 324 }, 
				textureRect = { x = 1280, y = 310, width = 408, height = 324 }, 
				spriteSourceSize = { width = 226, height = 162 }, 
				spriteTrimmed = true,
				textureRotated = false
			},
		
			{
				name = "05.png",
				spriteColorRect = { x = 24, y = 4, width = 410, height = 318 }, 
				textureRect = { x = 446, y = 310, width = 410, height = 318 }, 
				spriteSourceSize = { width = 227, height = 161 }, 
				spriteTrimmed = true,
				textureRotated = false
			},
		
			{
				name = "06.png",
				spriteColorRect = { x = 4, y = 20, width = 432, height = 302 }, 
				textureRect = { x = 1320, y = 4, width = 432, height = 302 }, 
				spriteSourceSize = { width = 226, height = 161 }, 
				spriteTrimmed = true,
				textureRotated = false
			},
		
			{
				name = "07.png",
				spriteColorRect = { x = 2, y = 40, width = 450, height = 280 }, 
				textureRect = { x = 4, y = 4, width = 450, height = 280 }, 
				spriteSourceSize = { width = 227, height = 162 }, 
				spriteTrimmed = true,
				textureRotated = false
			},
		
			{
				name = "08.png",
				spriteColorRect = { x = 0, y = 24, width = 448, height = 296 }, 
				textureRect = { x = 868, y = 4, width = 448, height = 296 }, 
				spriteSourceSize = { width = 226, height = 162 }, 
				spriteTrimmed = true,
				textureRotated = false
			},
		
		}
	}

	return sheet
end

return horse