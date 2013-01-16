----------------------------------------------------------------------------------
--
-- scene1.lua
--
----------------------------------------------------------------------------------

local timer = require("timer")
local director = require("director")
local system = require("system")
local text = require("text")
local ui = require("UI")

local scene = director.newScene()
local text_input


---------------------------------------------------------------------------------
-- Scene event handlers
---------------------------------------------------------------------------------

-- Called when the scene is first created
function scene:createScene(event)

	-----------------------------------------------------------------------------
	--	CREATE display objects here (layers, groups, sprites, etc.)
	-----------------------------------------------------------------------------
    
    text_input = ui.newTextField(100,100,250,50)
    self:addNativeObject(text_input)
    
end

-- Called immediately after scene has moved onscreen
function scene:enterScene(event)

	-----------------------------------------------------------------------------
	--	Start timers, set up event listeners, etc.  
	-----------------------------------------------------------------------------

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