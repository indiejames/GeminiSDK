----------------------------------------------------------------------------------
--
-- scene_template.lua
--
----------------------------------------------------------------------------------

local timer = require("timer")
local director = require( "director" )
local scene = director.newScene()

local star

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
    
	local layer1 = display.newLayer(1)
	layer1:setBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA)
	
    print("Lua: Adding layer1 to scene")
	self:addLayer(layer1)
    print("Lua: Creating green rectangle")
	-- draw a green rectangle with a white border
	local rectangle = display.newRect(100,100,100,100)
	rectangle:setFillColor(0.0,1,0,1.0)
	rectangle:setStrokeColor(1.0,1.0,1.0,1.0)
	rectangle.strokeWidth = 5.0
	rectangle.x = 750
	rectangle.y = 450
	rectangle.rotation = 30
    rectangle.name = "GREEN_RECTANGLE"
    layer1:insert(rectangle)
    
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
    local rectangle = display.newRect(100,100,100,100)
    rectangle:setFillColor(1.0,0,0,1.0)
    rectangle:setStrokeColor(1.0,1.0,1.0,1.0)
    rectangle.strokeWidth = 5.0
    rectangle.x = 750
    rectangle.y = 450
    rectangle.rotation = 30
    layer1:insert(rectangle)

    local rectangle3 = display.newRect(200,300,100,100)
    rectangle3:setFillColor(0.5,0.25,0.75,1.0)
    rectangle3:setStrokeColor(1.0,1.0,1.0,1.0)
    rectangle3.strokeWidth = 5.0
    rectangle3.x = 250
    rectangle3.y = 450
    rectangle3.rotation = 40
    rectangle3.name = "rectangle3"
    layer1:insert(rectangle3)

    local rectangle4 = display.newRect(600,400,100,100)
    rectangle4:setFillColor(0,0.5,0.5,1.0)
    rectangle4:setStrokeColor(1.0,1.0,1.0,1.0)
    rectangle4.strokeWidth = 5.0
    rectangle4.x = 550
    rectangle4.y = 500
    rectangle4.rotation = -20
    rectangle4.name = "rectangle4"
    layer1:insert(rectangle4)


    local collisionPresolve = function(event)
      local obj = event.source
      print(string.format("Lua: %s - BANG!", obj.name))
      print(string.format("Using main"))
    end

    local collisionPostsolve = function(event)
      local obj = event.source
      print(string.format("Lua: %s - BANG!", obj.name))
      print(string.format("Using main"))
    end

    function rectangle4:collision(event)
      local obj = event.source
      print(string.format("Lua: %s - BANG!", obj.name))
      print(string.format("Using main"))
    end


    physics.setScale(213)
    physics.setGravity(0, -9.8)
    physics.addBody(rectangle3, "dynamic", { density=3.0, friction=0.5, restitution=0.7 } )
    --rectangle3:addEventListener("collision:postsolve", collisionPresolve)
    physics.addBody(rectangle4, "dynamic", { density=3.0, friction=0.5, restitution=0.7 } )
    --rectangle4:addEventListener("collision:postsolve", collisionPresolve)
    rectangle4:addEventListener("collision", rectangle4)


    local ground = display.newRect(512,0,1024,36)
    ground:setFillColor(0,1.0,0,1.0)
    layer1:insert(ground)
    physics.addBody(ground)

    local leftSide = display.newRect(0,384,36,768)
    leftSide:setFillColor(0,1.0,0,1.0)
    layer1:insert(leftSide)
    physics.addBody(leftSide)

    local rightSide = display.newRect(1024,384,36,768)
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
    
    director.loadScene('scene2')
    
    -- add an event listener that will fire every frame
    scene.starListener = function(event)
      -- rotate our star and rectangles about their centers (reference points)
      star.rotation = star.rotation + 0.2
      --rectangle.rotation = rectangle.rotation - 1.0
      --rectangle2.rotation = rectangle2.rotation - 3.0
    end 
    -- the "enterFrame" event fires at the beginning of each render loop
    Runtime:addEventListener("enterFrame", scene.starListener)
    
    local function listener(event)
    
        director.gotoScene("scene2",
            {transition="GEM_PAGE_TURN_SCENE_TRANSITION", duration=5.0}
            --{transition="GEM_SLIDE_SCENE_TRANSITION", duration=5.0, direction="up"}
        )    end
    
    timer.performWithDelay(5000, listener)

end


-- Called when scene is about to move offscreen:
function scene:exitScene( event )
	

	-----------------------------------------------------------------------------

	--	INSERT code here (e.g. stop timers, remove listeners, unload sounds, etc.)

	-----------------------------------------------------------------------------
    
    Runtime:removeEventListener("enterFrame", scene.starListener)

    print("Exiting scene 1")

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