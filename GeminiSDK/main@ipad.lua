--
-- This is sample code.  Change this for your application.
--

gemini = require('gemini')
display = require('display')
physics = require('physics')
local director = require('director')

print("Lua: using main@ipad.lua")

-- create a blended layer in front of the default layer
local layer1 = display.newLayer(2)
layer1:setBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA)


-- draw a blue rectangle with a green border
rectangle2 = display.newRect(200,200,50,50)
rectangle2:setFillColor(0,0,1.0,1.0)
rectangle2:setStrokeColor(0,1.0,0,1.0)
rectangle2.strokeWidth = 2.0
rectangle2.rotation = -15

print("Lua: using main@ipad.lua")

director.loadScene('scene1')
director.gotoScene('scene1')



