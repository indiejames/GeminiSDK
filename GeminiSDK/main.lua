--
-- This is sample code.  Change this for your application.
--

gemini = require('gemini')
display = require('display')
physics = require('physics')
local director = require('director')
TextCandy = require("lib_text_candy")

print("Lua: using main")

topLayer = display.newLayer(99)

 -- create a label for the levels
TextCandy.AddCharsetFromGlyphDesigner( "FONT1", "chilopod_gd", 32)

TextCandy.ScaleCharset("FONT1", .5)
levelLabel = TextCandy.CreateText({
    fontName    = "FONT1",
        x               = 284,
        y               = 300,
        text            = "Level 5",
        originX         = "CENTER",
        originY         = "CENTER",
        textFlow        = "CENTER",
        wrapWidth       = 350,
        lineSpacing     = -4,
        charBaseLine = "TOP",
        showOrigin      = false
    })
    
levelLabelGroup = display.newGroup()
levelLabelGroup:insert(levelLabel)
levelLabelGroup.alpha = 0
topLayer:insert(levelLabelGroup)

levelFadeDuration = 1000

director.loadScene('scene1')
director.gotoScene('scene1')