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