----------------------------------------------------------------------------------
--
-- scene_template.lua
--
----------------------------------------------------------------------------------

local director = require( "director" )
local scene = director.newScene()
local display = require('display')
local sprite = require('sprite')
local walker = require('walker')

local walkerSprite
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
    local walkerSpriteSheet = sprite.newSpriteSheetFromData("walker.png", walker.getSpriteSheetData())
    local walkerSpriteSet = sprite.newSpriteSet(walkerSpriteSheet, 1, 10)
    walkerSprite = sprite.newSprite(walkerSpriteSet)
    walkerSprite.x = 240
    walkerSprite.y = 160
    layer1:insert(walkerSprite)
    
    sprite2 = sprite.newSprite(walkerSpriteSet)
    sprite2.x = 100
    sprite2.y = 100
    layer1:insert(sprite2)
    
    sprite3 = sprite.newSprite(walkerSpriteSet)
    sprite3.x = 400
    sprite3.y = 240
    sprite3.name = "sprite3"
    layer1:insert(sprite3)
    
    local scaleFactor = 1.0
    local physicsData = (require "test_physics").physicsData(scaleFactor)
    print("Lua: loaded physics data")
    local data,data2,data3,data4,data5 = physicsData:get("runner")
    print("Lua: got physics data for runner using file data")
    physics.addBody( sprite3, "dynamic", data )
    --physics.addBody( sprite3, "dynamic", { density=3.0, friction=0.5, restitution=0.7, radius=0.1 })
    sprite3.isActive = false
    print("Lua: added physics to sprite3")
    
    
end


-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
	

	-----------------------------------------------------------------------------

	--	INSERT code here (e.g. start timers, load audio, start listeners, etc.)

	-----------------------------------------------------------------------------
    
    print("Entering scene 4")
    
    
    walkerSprite:prepare()
    walkerSprite:play()
    sprite2:prepare()
    sprite2:play()
    sprite3:prepare()
    sprite3:play()
    sprite3.isActive = true
    
    local function listener(event)
        director.gotoScene(
            "scene1",
            {transition="GEM_SLIDE_SCENE_TRANSITION", duration=2.5, direction="down"})
    end
    
    timer.performWithDelay(5000, listener)

end


-- Called when scene is about to move offscreen:
function scene:exitScene( event )
	

	-----------------------------------------------------------------------------

	--	INSERT code here (e.g. stop timers, remove listeners, unload sounds, etc.)

	-----------------------------------------------------------------------------
    
    print("Exiting scene 4")
    walkerSprite:pause();

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