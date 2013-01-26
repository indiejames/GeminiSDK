----------------------------------------------------------------------------------
--
-- scene_template.lua
--
----------------------------------------------------------------------------------

local director = require( "director" )
local scene = director.newScene()
local system = require("system")
local ice = require( "ice" )
local text = require("text")

local layer1
local charSet

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
	print("Lua: Creating ice_test")
    
	layer1 = display.newLayer(1)
    self:addLayer(layer1)
    charSet = text.newCharset("FONT1", "chilopod_gd")
    

end


-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
	

	-----------------------------------------------------------------------------

	--	INSERT code here (e.g. start timers, load audio, start listeners, etc.)

	-----------------------------------------------------------------------------
    
    print("Entering scene ice_test")
    
    -- ICE
    
    local settings = ice:loadBox( "settings" )
    settings:store( "difficulty", "easy" )
    settings:store( "volume", 0.7 )
    settings:store( "playerPosition", { x = 100, y = 45 } )
    settings:save()

    print ("Lua: saved settings")
 
    local scores = ice:loadBox( "scores" )
    scores:store( "best", 100 )
    scores:storeIfHigher( "best", 65 )
    scores:storeIfHigher( "best", 105 )
    scores:save()
 
    print( "Lua: " .. scores:retrieve( "best" ) )

    local label = text.newText("FONT1", "High Score: " .. scores:retrieve("best"))
    label.x = 240
    label.y = 160
    layer1:insert(label)
    
   
end


-- Called when scene is about to move offscreen:
function scene:exitScene( event )
	

	-----------------------------------------------------------------------------

	--	INSERT code here (e.g. stop timers, remove listeners, unload sounds, etc.)

	-----------------------------------------------------------------------------
    
    Runtime:removeEventListener("enterFrame", scene.starListener)
    
    print("Exiting scene 1")
    
    rectangle3.isActive = false
    rectangle4.isActive = false
    redCircle.isActive = false
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

scene.name = "scene1"

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