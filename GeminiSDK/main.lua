--
-- This is sample code.  Change this for your application.
--

gemini = require('gemini')
display = require('display')
physics = require('physics')
local director = require('director')


print("Lua: using main")

-- create a blended layer in front of the default layer
local layer1 = display.newLayer(2)
layer1:setBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA)

-- draw a star using a poly line
star = display.newLine( 150/2,30/2, 177/2,115/2 )
star:append( 255/2,115/2, 193/2,166/2, 215/2,240/2, 150/2,195/2, 85/2,240/2, 107/2,165/2, 45/2,115/2, 123/2,115/2, 150/2,30/2 )
star:setColor( 0, 0, 1.0, 0.5 )
star.width = 5
star.yReference = 60
local group1 = display.newGroup()
layer1:insert(group1)
group1:insert(star)
group1.xReference = star.x
group1.yReference = star.y
group1.x = 240
group1.y = 160

-- draw a red rectangle with a white border
rectangle = display.newRect(100/2,100/2,100/2,100/2)
rectangle:setFillColor(1.0,0,0,1.0)
rectangle:setStrokeColor(1.0,1.0,1.0,1.0)
rectangle.strokeWidth = 2.5
rectangle.x = 375
rectangle.y = 225
rectangle.rotation = 30

rectangle3 = display.newRect(200/2,300/2,100/2,100/2)
rectangle3:setFillColor(0.5,0.25,0.75,1.0)
rectangle3:setStrokeColor(1.0,1.0,1.0,1.0)
rectangle3.strokeWidth = 2.5
rectangle3.x = 125
rectangle3.y = 225
rectangle3.rotation = 40
rectangle3.name = "rectangle3"

rectangle4 = display.newRect(600/2,400/2,100/2,100/2)
rectangle4:setFillColor(0,0.5,0.5,1.0)
rectangle4:setStrokeColor(1.0,1.0,1.0,1.0)
rectangle4.strokeWidth = 2.5
rectangle4.x = 275
rectangle4.y = 250
rectangle4.rotation = -20
rectangle4.name = "rectangle4"


local collisionPresolve = function(event)
  local obj = event.source
  print(string.format("Lua: %s - BANGED!", obj.name))
  print(string.format("Using main"))  
end

local collisionPostsolve = function(event)
  local obj = event.source
  print(string.format("Lua: %s - BANGED!", obj.name))
  print(string.format("Using main"))
end

function rectangle4:collision(event)
  local obj = event.source
  print(string.format("Lua: %s - BANGED!", obj.name))
  print(string.format("Using main"))
end

print(string.format("Using main"))

physics.setScale(100)
physics.setGravity(0, -9.8)
physics.addBody(rectangle3, "dynamic", { density=3.0, friction=0.5, restitution=0.7 } )
--rectangle3:addEventListener("collision:postsolve", collisionPresolve)
physics.addBody(rectangle4, "dynamic", { density=3.0, friction=0.5, restitution=0.7 } )
--rectangle4:addEventListener("collision:postsolve", collisionPresolve)
rectangle4:addEventListener("collision", rectangle4)


ground = display.newRect(480/2,0,960/2,30/2)
ground:setFillColor(0,1.0,0,1.0)
physics.addBody(ground)

leftSide = display.newRect(0,320/2,30/2,640/2)
leftSide:setFillColor(0,1.0,0,1.0)
physics.addBody(leftSide)

rightSide = display.newRect(960/2,320/2,30/2,640/2)
rightSide:setFillColor(0,1.0,0,1.0)
physics.addBody(rightSide)


-- draw a blue rectangle with a green border
rectangle2 = display.newRect(200/2,200/2,50/2,50/2)
rectangle2:setFillColor(0,0,1.0,1.0)
rectangle2:setStrokeColor(0,1.0,0,1.0)
rectangle2.strokeWidth = 1.0
rectangle2.rotation = -15

director.loadScene('scene1')
director.gotoScene('scene1', {transition="GEM_FADE_TRANSITION"})


-- add an event listener that will fire every frame
local myListener = function(event)
  -- rotate our star and rectangles about their centers (reference points)
  star.rotation = star.rotation + 0.2
  rectangle.rotation = rectangle.rotation - 1.0
  rectangle2.rotation = rectangle2.rotation - 3.0
end 
-- the "enterFrame" event fires at the beginning of each render loop
Runtime:addEventListener("enterFrame", myListener)


