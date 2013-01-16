----------------------------------------------------------------------------------
--
-- scene1.lua
--
----------------------------------------------------------------------------------

local timer = require("timer")
local director = require("director")
local scene = director.newScene()
local system = require("system")

local redRectangle


---------------------------------------------------------------------------------
-- Scene event handlers
---------------------------------------------------------------------------------

-- Called when the scene is first created
function scene:createScene(event)

	-----------------------------------------------------------------------------
	--	CREATE display objects here (layers, groups, sprites, etc.)
	-----------------------------------------------------------------------------
    
    local layer1 = display.newLayer(1)
    self:addLayer(layer1)
    redRectangle = display.newRect(100, 100, 50, 50)
    redRectangle.name = "redRectangle"
    redRectangle:setFillColor(1, 0, 0, 1)
    redRectangle:setStrokeColor(1, 1, 1, 1)
    redRectangle:setStrokeWidth(2.0)
    
    layer1:insert(redRectangle)

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