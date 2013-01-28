----------------------------------------------------------------------------------
--
-- scene_template.lua
--
----------------------------------------------------------------------------------

local timer = require("timer")
local director = require( "director" )
local scene = director.newScene()

local star
local greenRectangle
local redRectangle
local rectangle3
local rectangle4
local redCircle

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
	print("Lua: Creating scene1")
    
	local layer2 = display.newLayer(-1)
	layer2:setBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA)
	
    print("Lua: Adding layer2 to scene")
	self:addLayer(layer2)
    print("Lua: Creating green rectangle")
	-- draw a green rectangle with a white border
	greenRectangle = display.newRect(50,50,50,50)
	greenRectangle:setFillColor(0.0,1,0,1.0)
	greenRectangle:setStrokeColor(1.0,1.0,1.0,1.0)
	greenRectangle.strokeWidth = 2.5
	greenRectangle.x = 375
	greenRectangle.y = 225
	--greenRectangle.rotation = 30
    greenRectangle.name = "GREEN_RECTANGLE"
    layer2:insert(greenRectangle)
    
    local layer1 = display.newLayer(1)
	layer1:setBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA)
    self:addLayer(layer1)
    
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
    
    local greenCircle = display.newCircle(300, 170, 30)
    greenCircle:setFillColor(0,1.0,0,1.0)
    layer1:insert(greenCircle)
    
    -- draw a red circle with a white border
    redCircle = display.newCircle(200,200,30)
    redCircle.name = "RED CIRCLE"
    redCircle:setFillColor(1.0,0,0,1.0)
    redCircle:setGradient(1.0,1.0,1.0,1.0, 1.0,0,0,1.0)
    redCircle.strokeWidth = 3.0
    redCircle:setStrokeColor(1.0,1.0,1.0,1.0)
    
    layer1:insert(redCircle)
    
    -- draw a blue circle with a white border
    local blueCircle = display.newCircle(50,50,40)
    blueCircle:setFillColor(0,0,1.0,1.0)
    blueCircle:setGradient(1.0,1.0,1.0,1.0,  0,0,1.0,1.0)
    --blueCircle.alpha = 0.5
    blueCircle.name = "BLUE CIRCLE"
    layer1:insert(blueCircle)
    
    -- draw a red rectangle with a white border
    redRectangle = display.newRect(100/2,100/2,100/2,100/2)
    redRectangle:setFillColor(1.0,0,0,1.0)
    redRectangle:setGradient(1.0,0,0,1.0, 1.0,0,0,1.0, 1.0,1.0,1.0,1.0, 1.0,1.0,1.0,1.0)
    redRectangle:setStrokeColor(1.0,1.0,1.0,1.0)
    redRectangle.strokeWidth = 2.5
    redRectangle.x = 375
    redRectangle.y = 225
    redRectangle.rotation = 30
    redRectangle.name = "RED RECTANGLE"
    layer1:insert(redRectangle)

    rectangle3 = display.newRect(200/2,300/2,100/2,100/2)
    rectangle3:setFillColor(0.5,0.25,0.75,1.0)
    rectangle3:setStrokeColor(1.0,1.0,1.0,1.0)
    rectangle3.strokeWidth = 3
    rectangle3.x = 125
    rectangle3.y = 225
    rectangle3.rotation = 40
    rectangle3.name = "rectangle3"
    layer1:insert(rectangle3)

    rectangle4 = display.newRect(600/2,400/2,100/2,100/2)
    rectangle4:setFillColor(0,0.5,0.5,1.0)
    rectangle4:setStrokeColor(1.0,1.0,1.0,1.0)
    rectangle4.strokeWidth = 3
    rectangle4.x = 275
    rectangle4.y = 250
    --rectangle4.rotation = -20
    rectangle4.name = "rectangle4"
    layer1:insert(rectangle4)


    physics.setScale(100)
    physics.setGravity(0, -9.8)
    physics.setDrawMode("normal")
    physics.addBody(rectangle3, "dynamic", { density=3.0, friction=0.5, restitution=0.7 } )
    physics.addBody(rectangle4, "dynamic", { density=3.0, friction=0.5, restitution=0.7 } )
    
    physics.addBody(redCircle, "dynamic", {density=3.0, friction=0.5, restitution=0.7})
    
    redCircle:applyForce(0,250)

    local ground = display.newRect(480/2,0,960/2,30/2)
    ground:setFillColor(0,1.0,0,1.0)
    layer1:insert(ground)
    ground.name = "GROUND"
    physics.addBody(ground)

    local leftSide = display.newRect(0,320/2,30/2,640/2)
    leftSide:setFillColor(0,1.0,0,1.0)
    layer1:insert(leftSide)
    physics.addBody(leftSide)

    local rightSide = display.newRect(960/2,320/2,30/2,640/2)
    rightSide:setFillColor(0,1.0,0,1.0)
    layer1:insert(rightSide)
    physics.addBody(rightSide)

end


-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
	

	-----------------------------------------------------------------------------

	--	INSERT code here (e.g. start timers, load audio, start listeners, etc.)

	-----------------------------------------------------------------------------
    
    print("Entering scene 1")
    
    rectangle3.isActive = true
    rectangle4.isActive = true
    redCircle.isActive = true
    
    local zoom = 3.0
    local currentZoom = 1.0
    
     -- add an event listener that will fire every frame
    scene.starListener = function(event)
      -- rotate our star
      --star.rotation = star.rotation + 0.2
      if currentZoom < zoom then
        self:zoom(1.0 + 1.0/60.0)
        currentZoom = currentZoom + 1.0 / 60.0
      end

      
    end 
    -- the "enterFrame" event fires at the beginning of each render loop
    Runtime:addEventListener("enterFrame", scene.starListener)
    
    self:pan(60.0, 10)
    
    
    --self:zoom(0.5)
    
    self:zoom(2.0)
    
    --self:pan(-100.0, 0)
   
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