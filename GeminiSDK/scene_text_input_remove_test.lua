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
    charSet = text.newCharset("FONT1", "chilopod_gd")
    local label = text.newText("FONT1", "Hello, World")
    label.x = 240
    label.y = 160
    layer1:insert(label)
    
    
end

-- Called immediately after scene has moved onscreen
function scene:enterScene(event)

	-----------------------------------------------------------------------------
	--	Start timers, set up event listeners, etc.  
	-----------------------------------------------------------------------------
    print ("Lua: enterStart")

    director.destroyScene("scene_text_input_test")
    
    print ("Lua: enterEnd")
    
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