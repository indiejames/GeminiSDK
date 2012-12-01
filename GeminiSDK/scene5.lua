----------------------------------------------------------------------------------
--
-- scene_template.lua
--
----------------------------------------------------------------------------------

local timer = require("timer")
local director = require( "director" )
local sound = require("sound")
local scene = director.newScene()
local display = require('display')
local sprite = require('sprite')
local cannon = require('cannon')

local cannonSprite
local cannonBall
local cannonSound
local box = {}

local box_positions = { 355, 32,
                        405, 32,
                        455, 32,
                        380, 80,
                        430, 80,
                        405, 128,
                        }

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
    
    local layer2 = display.newLayer(-1)
    layer2:setBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA)
	
	self:addLayer(layer1)
    
    -- create our sprite for the running walker
    local cannonSpriteSheet = sprite.newSpriteSheetFromData("cannon.png", cannon.getSpriteSheetData())
    local cannonSpriteSet = sprite.newSpriteSet(cannonSpriteSheet, 1, 3)
    sprite.add(cannonSpriteSet, "fire", 2, 3, 0.1, -1)
    sprite.add(cannonSpriteSet, "box", 1, 1, 0.1, 1)
    cannonSprite = sprite.newSprite(cannonSpriteSet)
    cannonSprite:prepare("fire")
    cannonSprite.name = "cannon"
    cannonSprite.x = 50
    cannonSprite.y = 47
    layer1:insert(cannonSprite)
    
    
    local scaleFactor = 1.0
    local physicsData = (require "cannon_physics").physicsData(scaleFactor)
    print("Lua: loaded physics data")
    physics.addBody( cannonSprite, "static", physicsData:get("cannon03") )
    cannonSprite.isActive = false
    
    cannonBall = display.newCircle(52,58, 7.5)
    cannonBall:setFillColor(0.5,0.5,0.5,1.0)
    layer2:insert(cannonBall)
    physics.addBody(cannonBall, "dynamic", {density=10.0, friction=0.5, restitution=0.7})
    cannonBall.isActive = false
    cannonBall.isVisible = false
    
    -- boxes
    
    local num_boxes = #box_positions / 2
    
    for i = 0, num_boxes-1 do
        local x = box_positions[i*2+1]
        local y = box_positions[i*2+2]
        
        box[i+1] = sprite.newSprite(cannonSpriteSet)
        box[i+1]:prepare("box")
        box[i+1].name = "box1"
        box[i+1].x = x
        box[i+1].y = y
        layer1:insert(box[i+1])
    
        physics.addBody(box[i+1], "dynamic", physicsData:get("box"))
        box[i+1].isActive = false
    end
    
    
    
    
    -- ground
    
    local ground = display.newRect(480/2,0,960/2,30/2)
    ground:setFillColor(0,1.0,0,1.0)
    layer1:insert(ground)
    ground.name = "GROUND"
    ground.isVisible = false
    physics.addBody(ground)
    
    
    -- sounds
    cannonSound = sound.new("cannon.wav")
        
end


-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
	

	-----------------------------------------------------------------------------

	--	INSERT code here (e.g. start timers, load audio, start listeners, etc.)

	-----------------------------------------------------------------------------
    
    print("Entering scene 5")
    
    cannonSprite.isActive = true
    
    cannonBall.isActive = true
    cannonBall.isVisible = true
    
    local num_boxes = #box_positions / 2
    
    for i = 1, num_boxes do
        box[i].isActive = true
    end
    
    function cannonSprite:touch(event)
        cannonSound:play()
        cannonSprite:play()
        cannonBall:applyForce(55,52)
        
        return true
    end
    cannonSprite:addEventListener("touch", cannonSprite)


       
    local function listener(event)
        director.gotoScene(
            "scene1",
            {transition="GEM_SLIDE_SCENE_TRANSITION", duration=2.5, direction="down"})
    end
    
    --timer.performWithDelay(5000, listener)

end


-- Called when scene is about to move offscreen:
function scene:exitScene( event )
	

	-----------------------------------------------------------------------------

	--	INSERT code here (e.g. stop timers, remove listeners, unload sounds, etc.)

	-----------------------------------------------------------------------------
    
    print("Exiting scene 5")
    cannonSprite:pause();
    cannonSprite.isActive = false

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