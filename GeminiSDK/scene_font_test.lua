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
local text = require("text")
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
    charSet = text.newCharset("FONT1", "chilopod_gd")
 --charSet.scale = 0.5
    local label = text.newText("FONT1", "Hello, World")
    label.x = 240
    label.y = 160
    layer1:insert(label)

    print("Lua: E")

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