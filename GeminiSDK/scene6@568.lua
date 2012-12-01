----------------------------------------------------------------------------------
--
-- scene_template.lua
--
----------------------------------------------------------------------------------

local timer = require("timer")
local director = require( "director" )
local sound = require("sound")
local scene = director.newScene()
local display = require('display')
local sprite = require('sprite')
local mario_game = require('mario_game')
local mountains = require('mountains')
local TextCandy = require("lib_text_candy")

local layer1

local marioSprite
local coin
local cannonSound
local ground

local leftButtonState = 0
local rightButtonState = 0
local jumpButtonState = 0
local joystickStartX

local box = {}

local box_positions = { 
                        -- floor
                         16, 16,
                         48, 16,
                         80, 16,
                        112, 16,
                        144, 16,
                        176, 16,
                        208, 16,
                        240, 16,
                        272, 16,
                        304, 16,
                        336, 16,
                        368, 16,
                        400, 16,
                        432, 16,
                        464, 16,
                        
                        528, 16,
                        560, 16,
                        
                        
                        -- left platform
                        16, 80,
                        48, 80,
                        
                        
                        
                        -- right platform
                        240, 112,
                        272, 112,


                        }
                        

local platform_speed = 0.5                        
local platform = {}
local platform_position = {
                        -- moving platform
                        176, 112,
                        208, 112,
                        }

local wall = {}

local wall_positions = {
                        -- wall
                        496, 16,
                        496, 48,
                        496, 80,
                        496, 112,
                        496, 144,
                        }
                        
function scene:lowerWall()
    for i=1,#wall do
        wall[i]:setLinearVelocity(0, -0.75)
    end
end

function scene:stopWall()
    for i=1,#wall do
        wall[i]:setLinearVelocity(0, 0)
    end
    wall[#wall].y = 16
end




-- Called when the scene's view does not exist:
function scene:createScene( event )
    print("Lua: Creating scene 6")
    
  layer1 = display.newLayer(1)
  layer1:setBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA)
    self:addLayer(layer1)
    
    local layer2 = display.newLayer(-1)
    layer2:setBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA)
    self:addLayer(layer2)
    
    local backgroundLayer = display.newLayer(-10)
    print ("Created background layer")
    local backgroundSpriteSheet = sprite.newSpriteSheetFromData("mountains.png", mountains.getSpriteSheetData())
    print ("Loaded background sprite sheet")
    local backgroundSpriteSet = sprite.newSpriteSet(backgroundSpriteSheet, 1, 1)
    print ("Created background sprite set")
    backgroundSprite = sprite.newSprite(backgroundSpriteSet)
    print ("Created background sprite")
    backgroundSprite.name = "background"
    backgroundSprite.x = 284
    backgroundSprite.y = 160
    backgroundSprite.xScale = 0.5
    backgroundSprite.yScale = 0.5
    backgroundLayer:insert(backgroundSprite)
    
    self:addLayer(backgroundLayer)
    
    local scaleFactor = 1.0
    local physicsData = (require "mario_game_physics").physicsData(scaleFactor)
    print("Lua: loaded physics data")

    
    -- create our sprites for the game
    local marioSpriteSheet = sprite.newSpriteSheetFromData("mario_game.png", mario_game.getSpriteSheetData())
    
    local marioSpriteSet = sprite.newSpriteSet(marioSpriteSheet, 3, 8)
    
    local blockSpriteSet = sprite.newSpriteSet(marioSpriteSheet, 1, 1)
    
    local coinSpriteSet = sprite.newSpriteSet(marioSpriteSheet, 2, 1)
    
    sprite.add(marioSpriteSet, "walk", 1, 8, 0.1, 0)
    
    sprite.add(marioSpriteSet, "jump", 3, 1, 0.1, 1)
    
    sprite.add(marioSpriteSet, "stand", 1, 1, 0.1, 1)
    
    sprite.add(blockSpriteSet, "block", 1, 1, 0.1, 1)
    sprite.add(coinSpriteSet, "coin", 1, 1, 0.1, 1)

    marioSprite = sprite.newSprite(marioSpriteSet)
    marioSprite:prepare("stand")
    marioSprite.name = "mario"
    marioSprite.x = 100
    marioSprite.y = 55
    marioSprite.fixedRotation = true
    marioSprite.isFlippedHorizontally = true
    layer1:insert(marioSprite)
    physics.addBody(marioSprite, "dynamic", physicsData:get("mario"))
    marioSprite.isActive = false
   
        
    -- boxes
    
    local num_boxes = #box_positions / 2
    
    for i = 0, num_boxes-1 do
        local x = box_positions[i*2+1]
        local y = box_positions[i*2+2]
        
        box[i+1] = sprite.newSprite(blockSpriteSet)
        box[i+1]:prepare("block")
        box[i+1].name = "block" .. (i+1)
        box[i+1].x = x
        box[i+1].y = y
        layer1:insert(box[i+1])
    
        physics.addBody(box[i+1], "static", physicsData:get("brick_block"))
        box[i+1].isActive = false
    end
    
    -- wall
    local num_wall_blocks = #wall_positions / 2
    for i = 0, num_wall_blocks-1 do
        local x = wall_positions[i*2+1]
        local y = wall_positions[i*2+2]
        
        wall[i+1] = sprite.newSprite(blockSpriteSet)
        wall[i+1]:prepare("block")
        wall[i+1].name = "wall" .. (i+1)
        wall[i+1].x = x
        wall[i+1].y = y
        layer1:insert(wall[i+1])
    
        physics.addBody(wall[i+1], "kinematic", physicsData:get("brick_block"))
        wall[i+1].isActive = false
    end
        
    -- platform
    local num_platform_blocks = #platform_position / 2
    for i = 0, num_platform_blocks-1 do
        local x = platform_position[i*2+1]
        local y = platform_position[i*2+2]
        
        platform[i+1] = sprite.newSprite(blockSpriteSet)
        platform[i+1]:prepare("block")
        platform[i+1].name = "platform" .. (i+1)
        platform[i+1].x = x
        platform[i+1].y = y
        layer1:insert(platform[i+1])
    
        physics.addBody(platform[i+1], "kinematic", physicsData:get("platform_block"))
        platform[i+1].isActive = false
    end
    
    -- coin
    coin = sprite.newSprite(coinSpriteSet)
    coin:prepare("coin")
    coin.name = "coin"
    coin.x = 272
    coin.y = 144
    physics.addBody(coin, "static", physicsData:get("coin"))
    coin.isActive = false
    layer1:insert(coin)
    
    
    -- sounds
    cannonSound = sound.new("cannon.wav")
    

end


-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
	

	-----------------------------------------------------------------------------

	--	INSERT code here (e.g. start timers, load audio, start listeners, etc.)

	-----------------------------------------------------------------------------
    
    print("Entering scene 6")
    
    levelLabel:setText("Level 6")
    transition.to(levelLabelGroup, {time=levelFadeDuration, alpha=1})
    
    physics.setDrawMode("normal")
        
    marioSprite.state = "STANDING"
    marioSprite.isActive = true
    
    local num_boxes = #box
    
    for i = 1, num_boxes do
        box[i].isActive = true
    end
    
    local num_wall_blocks = #wall
    
    for i = 1, num_wall_blocks do
        wall[i].isActive = true
    end
    
    local num_platform_blocks = #platform
    for i = 1, num_platform_blocks do
        platform[i].isActive = true
        platform[i]:setLinearVelocity(-platform_speed, 0)
    end
    
    coin.isActive = true
   
   scene.touchListener = function(event)
        print(event)
        print("TOUCH")
        if event.x > 284 then
            if event.phase == "began" then
                joystickStartX = event.x
            end
        
            if event.phase == "ended" then
            
                rightButtonState = 0
                leftButtonState = 0
            end
        
            if event.phase == "moved" then
            
                if event.x < joystickStartX then
                    leftButtonState = 1
                    rightButtonState = 0
                end
            
                if event.x > joystickStartX then
                    rightButtonState = 1
                    leftButtonState = 0
                end
            
                joystickStartX = event.x
            end
        else
            -- jump button
            if event.phase == "began" then
                jumpButtonState = 1
            end
            
            if event.phase == "ended" then
                jumpButtonState = 0
            end
        
        end
        
        return true
   end
   layer1:addEventListener("touch", scene.touchListener)
   
   function coin:collision(event)
     local obj = event.source
      
     if obj == marioSprite then
        --print "Hit the coin!"
        scene.lowerWall()
        coin.remove = true
        coin.isVisible = false
      end
      
    end
    coin:addEventListener("collision", coin) 
   
   function marioSprite:collision(event)
      local obj = event.source

      if (marioSprite.state == "JUMPING") then
        marioSprite:setLinearVelocity(0,0)
        marioSprite.state = "STANDING"
      end
      
    end
    marioSprite:addEventListener("collision", marioSprite)
    
    
    -- add an event listener that will fire every frame
    scene.loopListener = function(event)

      if rightButtonState == 1 then
        marioSprite.isFlippedHorizontally = true
        if marioSprite.vx < 0.75 and marioSprite.state ~= "JUMPING" then
            marioSprite:applyLinearImpulse(0.05, 0)
            
            if marioSprite.state ~= "WALKING" then
                marioSprite:prepare("walk")
                marioSprite:play()
            end
                
            marioSprite.state = "WALKING"
        end

        
        
      end
      
      if leftButtonState == 1 then
        marioSprite.isFlippedHorizontally = false
        if marioSprite.vx > -0.75 and marioSprite.state ~= "JUMPING" then
            marioSprite:applyLinearImpulse(-0.05, 0)
            
            if marioSprite.state ~= "WALKING" then
                marioSprite:prepare("walk")
                marioSprite:play()
            end
        
            marioSprite.state = "WALKING"
        end
        
      end
      
      if leftButtonState == 0 and rightButtonState == 0 and marioSprite.state == "WALKING" then
        marioSprite:setLinearVelocity(0,0)
        marioSprite.state = "STANDING"
        marioSprite:prepare("stand")
        marioSprite:play()
      end
    
      if jumpButtonState == 1 then
        if (marioSprite.state ~= "JUMPING") then
            marioSprite.y = marioSprite.y + 2
            marioSprite:applyLinearImpulse(marioSprite.vx * 0.1, 0.4)
            marioSprite.state = "JUMPING"
            jumpButtonState = 0
        end
      end
    
      if marioSprite.state == "WALKING" then
        if marioSprite.vx > 0.75 then
            marioSprite:setLinearVelocity(0.75, 0)
        end
        if marioSprite.vx < -0.75 then
            marioSprite:setLinearVelocity(-0.75, 0)
        end
      end
      
      if coin.remove then
        coin.isActive = false
        coin.remove = false
      end

      -- stop wall from falling too far down
      if wall[#wall].y < 16 then
        scene.stopWall()
      end
      
      -- reverse direction of platform if necessary
      if platform[1].x < platform_position[1] - 64 then
        for i = 1, #platform do
            platform[i]:setLinearVelocity(platform_speed, 0)
        end
      else
        if platform[1].x > platform_position[1] then
            for i = 1, #platform do
                platform[i]:setLinearVelocity(-platform_speed, 0)
            end
        end
       end
      
      
    end 
    -- the "enterFrame" event fires at the beginning of each render loop
    Runtime:addEventListener("enterFrame", scene.loopListener)
    
end


-- Called when scene is about to move offscreen:
function scene:exitScene( event )
	

	-----------------------------------------------------------------------------

	--	INSERT code here (e.g. stop timers, remove listeners, unload sounds, etc.)

	-----------------------------------------------------------------------------
    
    print("Exiting scene 6")
    marioSprite:pause();
    marioSprite.isActive = false

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

scene.name = "scene6"

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