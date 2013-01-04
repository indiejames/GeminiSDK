-- This file is for use with Corona(R) SDK
--
-- This file is automatically generated with PhysicsEdtior (http://physicseditor.de). Do not edit
--
-- Usage example:
--			local scaleFactor = 1.0
--			local physicsData = (require "shapedefs").physicsData(scaleFactor)
--			local shape = display.newImage("objectname.png")
--			physics.addBody( shape, physicsData:get("objectname") )
--

-- copy needed functions to local scope
local unpack = unpack
local pairs = pairs
local ipairs = ipairs

local M = {}

function M.physicsData(scale)
	local physics = { data =
	{ 
		
		["cannon03"] = {
                    
                    
                    
                    
                    {
                    pe_fixture_id = "cannon_top", density = 2, friction = 0, bounce = 0, 
                    filter = { categoryBits = 1, maskBits = 65535, groupIndex = 0 },
                    shape = {   28, -34.5  ,  29, -32.5  ,  -12, -13.5  ,  -13, -15.5  }
                    }
                    
                    
                    
                     ,
                    
                    
                    {
                    pe_fixture_id = "cannon_bottom", density = 2, friction = 0, bounce = 0, 
                    filter = { categoryBits = 1, maskBits = 65535, groupIndex = 0 },
                    shape = {   35, -18.5  ,  36, -16.5  ,  -5, 3.5  ,  -6, 1.5  }
                    }
                    
                    
                    
                     ,
                    
                    
                    {
                    pe_fixture_id = "cannon_back", density = 2, friction = 0, bounce = 0, 
                    filter = { categoryBits = 1, maskBits = 65535, groupIndex = 0 },
                    shape = {   -3, 0.5  ,  -5, 1.5  ,  -15, -19.5  ,  -13, -20.5  }
                    }
                    
                    
                    
                     ,
                    
                    {
                    pe_fixture_id = "cannon_body", density = 2, friction = 0, bounce = 0, 
                    filter = { categoryBits = 1, maskBits = 65535, groupIndex = 0 },
                    radius = 29.155,
					position = { -32.4285714285714, 12.2142857142857 }
                    }
                    
                    
		}
		
		, 
		["box"] = {
                    
                    
                    
                    
                    {
                    pe_fixture_id = "box", density = 0.2, friction = 1, bounce = 0.5, 
                    filter = { categoryBits = 1, maskBits = 65535, groupIndex = 0 },
                    shape = {   23, -23  ,  23, 23  ,  -23, 23  ,  -23, -23  }
                    }
                    
                    
                    
		}
		
	} }

        -- apply scale factor
        local s = scale or 1.0
        for bi,body in pairs(physics.data) do
                for fi,fixture in ipairs(body) do
                    if(fixture.shape) then
                        for ci,coordinate in ipairs(fixture.shape) do
                            fixture.shape[ci] = s * coordinate
                        end
                    else
                        fixture.radius = s * fixture.radius
						fixture.position = { s * fixture.position[1], s * fixture.position[2] }
                    end
                end
        end
	
	function physics:get(name)
		return table.unpack(self.data[name])
	end

	function physics:getFixtureId(name, index)
                return self.data[name][index].pe_fixture_id
	end
	
	return physics;
end

return M
