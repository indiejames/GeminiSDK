----------------------------------------------------------------------------------
--
-- scene1.lua
--
----------------------------------------------------------------------------------

local timer = require("timer")
local director = require("director")
local scene = director.newScene()
local sprite = require("sprite")
local system = require("system")
local cannon = require("cannon")
local walker = require("walker")

local redRectangle
local runner


---------------------------------------------------------------------------------
-- Scene event handlers
---------------------------------------------------------------------------------

-- Called when the scene is first created
function scene:createScene(event)

	-----------------------------------------------------------------------------
	--	CREATE display objects here (layers, groups, sprites, etc.)
	-----------------------------------------------------------------------------
    
    local layer1 = display.newLayer(1)
    redRectangle = display.newRect(100, 100, 50, 50)
    redRectangle:setFillColor(1, 0, 0, 1)
    
    redRectangle:setStrokeColor(1, 1, 1, 1)
    redRectangle:setStrokeWidth(2.0)
    
    layer1:insert(redRectangle)
    
    local cannonSpriteSheet = sprite.newSpriteSheetFromData("cannon.png", cannon.getSpriteSheetData())
    
    local box = sprite.newImage(cannonSpriteSheet, "box.png")
    box.x = 200
    box.y = 200
    layer1:insert(box)
    
    local walkerSpriteSheet = sprite.newSpriteSheetFromData("walker.png", walker.getSpriteSheetData())
    print("Lua: A")
    local runnerSpriteSet = sprite.newSpriteSet(walkerSpriteSheet, 1, 10)
    print("Lua: B")
    runner = sprite.newSprite(runnerSpriteSet)
    print("Lua: C")
    print("Lua: D")
    runner:prepare("default")
    runner.x = 300
    runner.y = 300
    layer1:insert(runner)

end

-- Called immediately after scene has moved onscreen
function scene:enterScene(event)

	-----------------------------------------------------------------------------
	--	Start timers, set up event listeners, etc.  
	-----------------------------------------------------------------------------

    function screenshot()
        system.screenshot()
    end
    
    timer.performWithDelay(3000, screenshot)
    runner:play()
end


-- Called when scene is about to move offscreen
function scene:exitScene(event)

	-----------------------------------------------------------------------------
	--	Stop timers, remove event listeners, etc.
	-----------------------------------------------------------------------------
	

end


-- Called when the scene is about to be deallocated
function scene:destroyScene(event)

	-----------------------------------------------------------------------------
	--	Cleanup scene elements here
	-----------------------------------------------------------------------------

end

---------------------------------------------------------------------------------
-- End of event handers
---------------------------------------------------------------------------------

scene:addEventListener("createScene", scene)

scene:addEventListener("enterScene", scene)

scene:addEventListener("exitScene", scene)

scene:addEventListener("destroyScene", scene)

return scene