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

-- draw a star using a poly line
star = display.newLine( 150,30, 177,115 )
star:append( 255,115, 193,166, 215,240, 150,195, 85,240, 107,165, 45,115, 123,115, 150,30 )
star:setColor( 0, 0, 1.0, 0.5 )
star.width = 10
star.yReference = 120
local group1 = display.newGroup()
layer1:insert(group1)
group1:insert(star)
group1.xReference = star.x
group1.yReference = star.y
group1.x = 480
group1.y = 320

-- draw a red rectangle with a white border
--local rectangle = display.newRect(10,10,100,100)
--rectangle:delete()
--collectgarbage("collect")
rectangle = display.newRect(100,100,100,100)
rectangle:setFillColor(1.0,0,0,1.0)
rectangle:setStrokeColor(1.0,1.0,1.0,1.0)
rectangle.strokeWidth = 5.0
rectangle.x = 750
rectangle.y = 450
rectangle.rotation = 30

rectangle3 = display.newRect(200,300,100,100)
rectangle3:setFillColor(0.5,0.25,0.75,1.0)
rectangle3:setStrokeColor(1.0,1.0,1.0,1.0)
rectangle3.strokeWidth = 5.0
rectangle3.x = 250
rectangle3.y = 450
rectangle3.rotation = 40
rectangle3.name = "rectangle3"

rectangle4 = display.newRect(600,400,100,100)
rectangle4:setFillColor(0,0.5,0.5,1.0)
rectangle4:setStrokeColor(1.0,1.0,1.0,1.0)
rectangle4.strokeWidth = 5.0
rectangle4.x = 550
rectangle4.y = 500
rectangle4.rotation = -20
rectangle4.name = "rectangle4"


local collisionPresolve = function(event)
  local obj = event.source
  print(string.format("Lua: %s - BANGER!", obj.name))  
  print(string.format("Using main"))
end

local collisionPostsolve = function(event)
  local obj = event.source
  print(string.format("Lua: %s - BANGER!", obj.name))
  print(string.format("Using main"))
end

function rectangle4:collision(event)
  local obj = event.source
  print(string.format("Lua: %s - BANGER!", obj.name))
  print(string.format("Using main"))
end


physics.setScale(213)
physics.setGravity(0, -9.8)
physics.addBody(rectangle3, "dynamic", { density=3.0, friction=0.5, restitution=0.7 } )
--rectangle3:addEventListener("collision:postsolve", collisionPresolve)
physics.addBody(rectangle4, "dynamic", { density=3.0, friction=0.5, restitution=0.7 } )
--rectangle4:addEventListener("collision:postsolve", collisionPresolve)
rectangle4:addEventListener("collision", rectangle4)


ground = display.newRect(512,0,1024,36)
ground:setFillColor(0,1.0,0,1.0)
physics.addBody(ground)

leftSide = display.newRect(0,384,36,768)
leftSide:setFillColor(0,1.0,0,1.0)
physics.addBody(leftSide)

rightSide = display.newRect(1024,384,36,768)
rightSide:setFillColor(0,1.0,0,1.0)
physics.addBody(rightSide)


-- draw a blue rectangle with a green border
rectangle2 = display.newRect(200,200,50,50)
rectangle2:setFillColor(0,0,1.0,1.0)
rectangle2:setStrokeColor(0,1.0,0,1.0)
rectangle2.strokeWidth = 2.0
rectangle2.rotation = -15

print("Lua: using main@ipad.lua")

director.loadScene('scene1')
director.gotoScene('scene1')


-- add an event listener that will fire every frame
local myListener = function(event)
  -- rotate our star and rectangles about their centers (reference points)
  star.rotation = star.rotation + 0.2
  rectangle.rotation = rectangle.rotation - 1.0
  rectangle2.rotation = rectangle2.rotation - 3.0
end 
-- the "enterFrame" event fires at the beginning of each render loop
Runtime:addEventListener("enterFrame", myListener)
