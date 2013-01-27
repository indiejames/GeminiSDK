--
-- This is sample code.  Change this for your application.
--

gemini = require('gemini')
display = require('display')
physics = require('physics')
local director = require('director')

print("Lua: using main")

topLayer = display.newLayer(99)

director.loadScene('scene1')
director.gotoScene('scene1')

-- Handler for application state change events,
-- Add code here to save/load game state.
function exitHandler(event)
    print ("Lua: Got '" .. event.name .. "' event")
    
end

Runtime:addEventListener("applicationWillExit", exitHandler)
Runtime:addEventListener("applicationDidEnterBackground", exitHandler)
Runtime:addEventListener("applicationWillEnterForeground", exitHandler)