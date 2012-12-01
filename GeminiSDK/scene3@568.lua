----------------------------------------------------------------------------------
--
-- scene_template.lua
--
----------------------------------------------------------------------------------

local director = require( "director" )
local sprite = require("sprite")
local timer = require("timer")
local scene = director.newScene()
local marios = require("marios")


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

	local layer = display.newLayer(1)
	layer:setBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA)
    self:addLayer(layer)

    local spriteSheet = sprite.newSpriteSheetFromData("marios.png", marios.getSpriteSheetData())
 
    local spriteSet = sprite.newSpriteSet(spriteSheet, 1, 8)
    
    local ys = 22
    local x0 = 10

    for j=1,10 do
        local xs = x0
        for i=1,37 do
            if i < 16 or i > 22 or j < 4 or j > 7 then
                local sprite = sprite.newSprite(spriteSet)
                sprite.x = xs
                sprite.y = ys
                --sprite.xScale = 1.5
                --sprite.yScale = 1.5
                sprite:prepare()
                sprite:play()
                layer:insert(sprite)
            end
            xs = xs + 15
        end
        ys = ys + 30
    end
    
    -- make a big sprite
    local bigSprite = sprite.newSprite(spriteSet)
    bigSprite.x = 284
    bigSprite.y = 160
    bigSprite.xScale = 2.5
    bigSprite.yScale = 2.5
    bigSprite:prepare()
    bigSprite:play()
    layer:insert(bigSprite)

end


-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
	

	-----------------------------------------------------------------------------

	--	INSERT code here (e.g. start timers, load audio, start listeners, etc.)

	-----------------------------------------------------------------------------
    
    print("Entering scene 3")
    
    levelLabel:setText("Level 3")
    transition.to(levelLabelGroup, {time=levelFadeDuration, alpha=1})

    
    local function listener(event)
        director.gotoScene(
            "scene4",
            {transition="GEM_SLIDE_SCENE_TRANSITION", duration=2.5, direction="left"})
    end
    
    timer.performWithDelay(25000, listener)

end


-- Called when scene is about to move offscreen:
function scene:exitScene( event )
	

	-----------------------------------------------------------------------------

	--	INSERT code here (e.g. stop timers, remove listeners, unload sounds, etc.)

	-----------------------------------------------------------------------------
    
    print("Exiting scene 3")
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