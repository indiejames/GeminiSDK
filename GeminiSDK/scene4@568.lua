----------------------------------------------------------------------------------
--
-- scene_template.lua
--
----------------------------------------------------------------------------------

local timer = require("timer")
local director = require( "director" )
local scene = director.newScene()
local display = require('display')
local sprite = require('sprite')
local walker = require('walker')

local sprite1
local sprite2
local sprite3

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
    print("Lua: Creating scene 4")
    
	local layer1 = display.newLayer(1)
	layer1:setBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA)
	
	self:addLayer(layer1)
    
    -- create our sprite for the running walker
    local sprite1Sheet = sprite.newSpriteSheetFromData("walker.png", walker.getSpriteSheetData())
    local sprite1Set = sprite.newSpriteSet(sprite1Sheet, 1, 10)
    sprite1 = sprite.newSprite(sprite1Set)
    sprite1.x = 240
    sprite1.y = 160
    layer1:insert(sprite1)
    
    sprite2 = sprite.newSprite(sprite1Set)
    sprite2.x = 100
    sprite2.y = 100
    layer1:insert(sprite2)
    
    sprite3 = sprite.newSprite(sprite1Set)
    sprite3.x = 400
    sprite3.y = 240
    sprite3.name = "sprite3"
    layer1:insert(sprite3)
    
    local scaleFactor = 1.0
    local physicsData = (require "test_physics").physicsData(scaleFactor)
    print("Lua: loaded physics data")
    physics.addBody( sprite3, "dynamic", physicsData:get("runner") )
    physics.addBody(sprite2, "dynamic", physicsData:get("runner") )
    physics.addBody(sprite1, "dynamic", physicsData:get("runner") )
    sprite3.isActive = false
    sprite2.isActive = false
    sprite1.isActive = false
    
    local ground = display.newRect(568/2,0,1136/2,30/2)
    ground:setFillColor(0,1.0,0,1.0)
    layer1:insert(ground)
    ground.name = "GROUND"
    physics.addBody(ground)
    ground.isVisible = false
    
    
end


-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
	

	-----------------------------------------------------------------------------

	--	INSERT code here (e.g. start timers, load audio, start listeners, etc.)

	-----------------------------------------------------------------------------
    
    print("Entering scene 4")
    levelLabel:setText("Level 4")
    transition.to(levelLabelGroup, {time=levelFadeDuration, alpha=1})
    
    physics.setDrawMode("hybrid")
    
    sprite1:prepare()
    sprite1:play()
    sprite2:prepare()
    sprite2:play()
    sprite3:prepare()
    sprite3:play()
    sprite3.isActive = true
    sprite2.isActive = true
    sprite1.isActive = true
    
    local function listener(event)
        director.gotoScene(
            "scene5",
            {transition="GEM_SLIDE_SCENE_TRANSITION", duration=2.5, direction="down"})
    end
    
    timer.performWithDelay(25000, listener)

end


-- Called when scene is about to move offscreen:
function scene:exitScene( event )
	

	-----------------------------------------------------------------------------

	--	INSERT code here (e.g. stop timers, remove listeners, unload sounds, etc.)

	-----------------------------------------------------------------------------
    
    print("Exiting scene 4")
    sprite1:pause();
    sprite1.isActive = false
    sprite2:pause();
    sprite2.isActive = false
    sprite3:pause();
    sprite3.isActive = false
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

scene.name = "scene4"

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