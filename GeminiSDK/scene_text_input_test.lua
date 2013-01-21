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
local text_input
local text_input2


---------------------------------------------------------------------------------
-- Scene event handlers
---------------------------------------------------------------------------------

-- Called when the scene is first created
function scene:createScene(event)

	-----------------------------------------------------------------------------
	--	CREATE display objects here (layers, groups, sprites, etc.)
	-----------------------------------------------------------------------------
    
    font_list = system.listSystemFonts()
    print(font_list)
    print("FONT LIST")
    for family_name,values in pairs(font_list) do
        print(family_name)
        for i, name in ipairs(values) do
            print("--" .. name)
        end
    
    end

    text_input = ui.newTextField(240,260,250,50)
    text_input.name = "test_text"
    text_input.font = "Courier"
    text_input.fontSize = 24
    text_input:setBackgroundColor(0,0.5,0,1.0)
    text_input:setFontColor(1.0,1.0,1.0,1.0)
    text_input.placeholder = "type something"
    text_input.keyboardType = UIKeyboardTypeEmailAddress
    self:addNativeObject(text_input)
    
    text_input2 = ui.newTextField(240, 180, 250, 50)
    text_input2.name = "test_text2"
    text_input2.font = "Courier"
    text_input2.fontSize = 24
    text_input2:setBackgroundColor(1,1,1,1)
    text_input2:setFontColor(0,0,0,1)
    self:addNativeObject(text_input2)
    
end

-- Called immediately after scene has moved onscreen
function scene:enterScene(event)

	-----------------------------------------------------------------------------
	--	Start timers, set up event listeners, etc.  
	-----------------------------------------------------------------------------
    
    function handleInput(event)
        print("Handling input")
        if event == nil then
            print ("Event is nil")
        end
        
        print ("OK")
        local input = event.target
        print("AA")
        print(input)
        if input == nil then
            print ("input is nil")
        end
        print("DOKEY")
        text = input.text
        print("Input has text " .. text)
        
        text_input2:takeFocus()
        
    end
    
    text_input:addEventListener("enterPressed", handleInput)

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