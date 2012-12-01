----------------------------------------------------------------------------------
--
-- scene_template.lua
--
----------------------------------------------------------------------------------

local timer = require("timer")
local transition = require("transition")
local director = require( "director" )
local scene = director.newScene()

local circleLabel

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
	print("Lua: Creating scene 2")
    
	local layer1 = display.newLayer(1)
	layer1:setBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA)
	
    print("Lua: Adding layer1 to scene2")
	self:addLayer(layer1)
    scene.group = display.newGroup()
    layer1:insert(scene.group)
    
    -- draw four boxes (and cross bars) and put them in the group
    local x_center = 284
    local y_center = 160

    
    local hbar = display.newRect(x_center,y_center, 250,15)
    hbar:setFillColor(0.0,0.0,1.0,1.0)
    hbar.rotation = 45.0
    scene.group:insert(hbar)
    
    local vbar = display.newRect(x_center,y_center, 15, 250)
    vbar:setFillColor(0.0,0.0,1.0,1.0)
    vbar.rotation = 45.0
    scene.group:insert(vbar)
    
    for j=0,1 do
      local y = y_center - 75 + j * 150
      for i=0,1 do
        local x = x_center - 75 + i * 150
        local rectangle = display.newRect(x,y,50,50)
        rectangle:setFillColor(1.0,0,0,1.0)
        rectangle:setStrokeColor(1.0,1.0,1.0,1.0)
        rectangle.strokeWidth = 3.0
        scene.group:insert(rectangle)
      end
    end
    
    scene.group.xReference = x_center
    scene.group.yReference = y_center
    scene.group.x = x_center
    scene.group.y = y_center
    
    local layer2 = display.newLayer(-1)
    layer2:setBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA)
    print("Lua: Adding layer2 to scene2")
	self:addLayer(layer2)
    local shape1 = display.newShape(20,20, 5,100, 70,120, 145,100, 130,20)
    shape1:setFillColor(0.5,0.4,0,1.0)
    shape1.x = x_center-70
    shape1.y = y_center-110
    layer2:insert(shape1)
    
        
 --[[   TextCandy = require("lib_text_candy")
    
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

  --]]  

end


-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
	

	-----------------------------------------------------------------------------

	--	INSERT code here (e.g. start timers, load audio, start listeners, etc.)

	-----------------------------------------------------------------------------
    
    print("Entering scene 2")
    
    levelLabel:setText("Level 2")
    transition.to(levelLabelGroup, {time=levelFadeDuration, alpha=1})
    
    director.loadScene('scene4')
    
    --director.destroyScene('scene1')
    
    scene.groupListener = function(event)
      -- rotate our rectangles about the group center (reference points) and about each recs center
      scene.group.rotation = scene.group.rotation + 1.0
      for i=3,6 do
        local rec = scene.group[i]
        rec.rotation = rec.rotation - 1.0
      end
    end 
    -- the "enterFrame" event fires at the beginning of each render loop
    Runtime:addEventListener("enterFrame", scene.groupListener)
    
    local function listener(event)
    
        director.gotoScene(
            "scene3",
            {transition="GEM_SLIDE_SCENE_TRANSITION", duration=2.5, direction="left"})
    end
    
    timer.performWithDelay(25000, listener)
    
    print ("setting up label transition")
    -- make the circular label spin two rotations in twenty seconds
   -- transition.to(circleLabel, {time=20000, rotation=720})

    print ("label transition set")

end


-- Called when scene is about to move offscreen:
function scene:exitScene( event )
	

	-----------------------------------------------------------------------------

	--	INSERT code here (e.g. stop timers, remove listeners, unload sounds, etc.)

	-----------------------------------------------------------------------------
    
    print("Exiting scene 2")
    Runtime:removeEventListener("enterFrame", scene.groupListener)
    
    levelLabelGroup.alpha = 0

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

scene.name = "scene2"

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