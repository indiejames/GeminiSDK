----------------------------------------------------------------------------------
--
-- scene_template.lua
--
----------------------------------------------------------------------------------

local director = require( "director" )
local timer = require("timer")
local scene = director.newScene()

local rectangle

----------------------------------------------------------------------------------
-- 
--	NOTE:
--	
--	Code outside of listener functions (below) will only be executed once,
--	unless director.removeScene() is called.
-- 
---------------------------------------------------------------------------------

---------------------------------------------------------------------------------
-- BEGINNING OF YOUR IMPLEMENTATION
---------------------------------------------------------------------------------

-- Called when the scene's view does not exist:
function scene:createScene( event )
	print("Lua: Creating scene 3")

	local layer1 = display.newLayer(1)
	layer1:setBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA)
    
    --[[local rect = display.newRect(240,160,480,320)
    layer1:insert(rect)
    rect:setFillColor(1,1,1,1)
	
    local redCircle = display.newCircle(190,110,100)
    layer1:insert(redCircle)
    redCircle:setFillColor(1,0,0,0.5)
    local blueCircle = display.newCircle(290,110,100)
    layer1:insert(blueCircle)
    blueCircle:setFillColor(0,0,1,0.5)
    local greenCircle = display.newCircle(240, 210, 100)
    layer1:insert(greenCircle)
    greenCircle:setFillColor(0,1,0,0.5)
    --]]
    
    TextCandy = require("lib_text_candy")
    
    print("TextCandy loaded")

    TextCandy.AddCharsetFromGlyphDesigner( "FONT1", "chilopod_gd", 32)

    TextCandy.ScaleCharset("FONT1", .5)

    -- create a label that will follow a circle
    circleLabel = TextCandy.CreateText({
    fontName    = "FONT1",
        x               = 240,
        y               = 160,
        text            = "This text is in a  circle",
        originX         = "CENTER",
        originY         = "CENTER",
        textFlow        = "CENTER",
        wrapWidth       = 350,
        lineSpacing     = -4,
        charBaseLine = "TOP",
        showOrigin      = false
    })
    
    layer1:insert(circleLabel)

    circleLabel:applyDeform({
        type            = TextCandy.DEFORM_CIRCLE,
        radius          = 90,
        radiusChange    = 0,
        angleStep       = 12,
        stepChange      = .175,
        autoStep        = false,
        ignoreSpaces    = false
    })

end


-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
	

	-----------------------------------------------------------------------------

	--	INSERT code here (e.g. start timers, load audio, start listeners, etc.)

	-----------------------------------------------------------------------------
    
    print("Entering scene 3")

    
 local function listener(event)
    director.gotoScene(
        "scene4",
        {transition="GEM_SLIDE_SCENE_TRANSITION", duration=2.5, direction="left"})
  end
    
  timer.performWithDelay(7000, listener)

end


-- Called when scene is about to move offscreen:
function scene:exitScene( event )
	

	-----------------------------------------------------------------------------

	--	INSERT code here (e.g. stop timers, remove listeners, unload sounds, etc.)

	-----------------------------------------------------------------------------
    
    print("Exiting scene 3")
    Runtime:removeEventListener("enterFrame", myListener)

end


-- Called prior to the removal of scene's "view" (display group)
function scene:destroyScene( event )
	

	-----------------------------------------------------------------------------

	--	INSERT code here (e.g. remove listeners, widgets, save state, etc.)

	-----------------------------------------------------------------------------

end

---------------------------------------------------------------------------------
-- END OF YOUR IMPLEMENTATION
---------------------------------------------------------------------------------

scene.name = "scene3"

-- "createScene" event is dispatched if scene's view does not exist
scene:addEventListener( "createScene", scene )

-- "enterScene" event is dispatched whenever scene transition has finished
scene:addEventListener( "enterScene", scene )

-- "exitScene" event is dispatched before next scene's transition begins
scene:addEventListener( "exitScene", scene )

-- "destroyScene" event is dispatched before view is unloaded, which can be
-- automatically unloaded in low memory situations, or explicitly via a call to
-- storyboard.purgeScene() or storyboard.removeScene().
scene:addEventListener( "destroyScene", scene )

return scene