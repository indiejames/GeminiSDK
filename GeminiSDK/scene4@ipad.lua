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
	print("Lua: Creating scene 4 using ipad file")
    
	local layer1 = display.newLayer(1)
	layer1:setBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA)
	
	self:addLayer(layer1)
    -- create our sprite for the running walker
    local walkerSpriteSheet = sprite.newSpriteSheetFromData("walker.png", walker.getSpriteSheetData())
    local walkerSpriteSet = sprite.newSpriteSet(walkerSpriteSheet, 1, 10)
    walkerSprite = sprite.newSprite(walkerSpriteSet)
    walkerSprite.x = 500
    walkerSprite.y = 350
    walkerSprite.xScale = 2.0
    walkerSprite.yScale = 2.0
    layer1:insert(walkerSprite)
    
    sprite2 = sprite.newSprite(walkerSpriteSet)
    sprite2.x = 100
    sprite2.y = 100
    layer1:insert(sprite2)
    
    sprite3 = sprite.newSprite(walkerSpriteSet)
    sprite3.x = 924
    sprite3.y = 680
    layer1:insert(sprite3)
    
end

local myListener = function(event)
  -- rotate our rectangle about its center (reference point)
  rectangle.rotation = rectangle.rotation + 1.0
  
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