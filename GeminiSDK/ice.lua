-- Project: Ice
--
-- Version: 1.0
--
-- Author: Graham Ranson 
--
-- Support: www.monkeydeadstudios.com or www.grahamranson.co.uk
--
-- Copyright (C) 2011 MonkeyDead Studios Limited. All Rights Reserved.


version = 1.0

-- INCLUDES --

local json = require( "json" )
require( "sqlite3" )

-- LOCAL FUNCTIONS --

local printError = function( message )
	print( "Ice error - " .. message )
end

local function tableToString( t, indent )

    local str = "" 

    if(indent == nil) then 
        indent = 0 
    end 

    -- Check the type 
    if(type(t) == "string") then 
        str = str .. (" "):rep(indent) .. t .. "\n" 
    elseif(type(t) == "number") then 
        str = str .. (" "):rep(indent) .. t .. "\n" 
    elseif(type(t) == "boolean") then 
        if(t == true) then 
            str = str .. "true" 
        else 
            str = str .. "false" 
        end 
    elseif(type(t) == "table") then 
        local i, v 
        for i, v in pairs(t) do 
            -- Check for a table in a table 
            if(type(v) == "table") then 
                str = str .. (" "):rep(indent) .. i .. ":\n" 
                str = str .. tableToString(v, indent + 2) 
            else 
                str = str .. (" "):rep(indent) .. i .. ": " .. tableToString(v, 0) 
            end 
        end 
    else 
        print("Error: unknown data type: %s", type(t)) 
    end 

    return str 
end

local createHeader = function()

	local header = {}
	
	header.version = version
	header.created = os.time()
	header.modified = os.time()
	header.saved = os.time()

	return header
	
end

local openDatabase = function( databaseName )

	if databaseName then

		local path = system.pathForFile( databaseName, system.DocumentsDirectory )
		
		return sqlite3.open( path )

	end
	
end

local saveDatabase = function( database, items, header )

	if database then

		local query = [[CREATE TABLE IF NOT EXISTS icebox (id INTEGER PRIMARY KEY, value, header);]]
	
		database:exec( query )
		
		local encodedItems = json.encode( items or {} )

		if header then
			header.saved = os.time()
		end
		
		local encodedHeader = json.encode( header or createHeader() )
	
		local query = [[INSERT INTO icebox VALUES (NULL, ']] .. encodedItems .. [[',']] .. encodedHeader .. [['); ]]

		database:exec( query )
		
		database:close()
		
	end
	
end

local loadDatabase = function( database )

	local result = database:exec("SELECT * FROM icebox")
	local items = {}
	local header = {}
	
	if database then

		if result == 0 then
		
			for row in database:nrows("SELECT * FROM icebox") do

				local encodedItems = row.value
				items = json.decode( encodedItems )

				local encodedHeader = row.header
				header = json.decode( encodedHeader )
				
				if encodedHeader == "[]" then
					header = createHeader()
				end
						
			end
		
		end
		
	end

	return items, header
	
end

local deleteDatabase = function( databaseName )

	if databaseName then

		local path = system.pathForFile( databaseName, system.DocumentsDirectory )
		
		os.remove( path )

	end
	
end

local createRestorePointName = function( restorePointName, databaseName )
	if restorePointName and databaseName then
		return "ICE-RESTORE|" .. restorePointName .. "|" .. databaseName
	end
end

-- ICE --

Ice = {}
Ice_mt = { __index = Ice }

--- Constructs a new Ice object.
function Ice:new()

	local self = {}
	
	self._boxes = {}
	
	setmetatable( self, Ice_mt )

	return self
	
end

--- Constructs a new IceBox.
-- @param name The name of the box.
function Ice:newBox( name )

	self:destroyBox( name )
	
	self._boxes[ #self._boxes + 1 ] = IceBox:new( name )

	return self._boxes[ #self._boxes ]
	
end

--- Gets an IceBox.
-- @param name The name of the box.
function Ice:getBox( name )
	for i = 1, #self._boxes, 1 do
		if self._boxes[i]:getName() == name then
			return self._boxes[ i ]
		end
	end
end

--- Destroys an IceBox.
-- @param name The name of the box.
function Ice:destroyBox( name )

	local box = self:getBox( name )
	
	if box then
		box:destroy()
	end
	
end

--- Saves an IceBox.
-- @param name The name of the box.
function Ice:saveBox( name )

	local box = self:getBox( name )
	
	if box then
		box:save()
	end
end

--- Loads an IceBox.
-- @param name The name of the box.
function Ice:loadBox( name )

	local box = self:getBox( name )
		
	if not box then
		self._boxes[ #self._boxes + 1 ] = self:newBox( name )
	
		self._boxes[ #self._boxes ]:load()
	
		self._boxes[ #self._boxes ]:save()
		
		box = self._boxes[ #self._boxes ]
	end
	return box
end

--- Stores/adjusts a value in an IceBox.
-- @param boxName The name of the box.
-- @param valueName The name of the value to store/adjust.
-- @param value The value to store.
function Ice:storeBoxValue( boxName, valueName, value )
	
	local box = self:getBox( boxName )
	
	if box then
		box:store( valueName, value )
	end
	
end

--- Retrieves a value from an IceBox.
-- @param boxName The name of the box.
-- @param valueName The name of the value to retrieve.
-- @return The value or nil if none found.
function Ice:retrieveBoxValue( boxName, valueName )
	
	local box = self:getBox( boxName )
	
	if box then
		return box:retrieve( valueName )
	end
	
end

--- Saves all stored iceboxes to the disk.
function Ice:save()
	for i = 1, #self._boxes, 1 do
		self._boxes[i]:save()
	end
end

--- Clears all items out of the iceboxes and saves them.
function Ice:clear()
	for i = 1, #self._boxes, 1 do
		self._boxes[i]:clear()
	end
end

--- Deletes all stored iceboxes from the disk.
function Ice:delete()
	for i = 1, #self._boxes, 1 do
		self._boxes[i]:delete()
	end
end

--- Clears and deletes all iceboxes.
function Ice:destroy()
	for i = 1, #self._boxes, 1 do
		self._boxes[i]:destroy()
	end
end

-- ICEBOX --

IceBox = {}
IceBox_mt = { __index = IceBox }

--- Constructs a new IceBox object.
-- @param name The name of the box.
function IceBox:new( name )

	local self = {}

	self._items = {}
	self._version = 1.0
	self._name = name or "default"
	self._databaseName = self._name .. ".ice"
	
	setmetatable( self, IceBox_mt )
	
	return self
	
end

--- Saves a value in the icebox.
-- @param name The name of the value to add.
-- @param value The value to save.
-- @return The stored value.
function IceBox:store( name, value )
	if name then
		self._items[ name ] = value
		
		if not self._header then
			self._header = createHeader()
		end
		
		self._header.modified = os.time()

	end
	
	if self:isAutomaticSavingEnabled() then
		self:save()
	end

	return value
	
end

--- Saves a value in the icebox if it isn't already in there.
-- @param name The name of the value to add.
-- @param value The value to save.
-- @return The stored value.
-- @return True if it was added, false if not.
function IceBox:storeIfNew( name, value )
	
	local added = false
	
	if name then

		if self:hasValue( name ) then
		
		else
			self._items[ name ] = value
			added = true
			self._header.modified = os.time()
		end
		
	end
	
	if self:isAutomaticSavingEnabled() then
		self:save()
	end
	
	return added, value
	
end

--- Saves a value in the icebox if it is higher than the one already in there.
-- @param name The name of the value to add.
-- @param value The value to save.
-- @return The stored value.
-- @return True if it was added, false if not.
function IceBox:storeIfHigher( name, value )
	
	local added = false
	
	if name then
		
		local currentValue = self:retrieve( name ) or 0
		
		if currentValue then
			
			if value > currentValue then
				self._items[ name ] = value
				added = true
				self._header.modified = os.time()
			end
		else
			self._items[ name ] = value
			added = true
			self._header.modified = os.time()
		end
		
	end
	
	if self:isAutomaticSavingEnabled() then
		self:save()
	end
	
	return added, value
	
end

--- Saves a value in the icebox if it is lower than the one already in there.
-- @param name The name of the value to add.
-- @param value The value to save.
-- @return The stored value.
-- @return True if it was added, false if not.
function IceBox:storeIfLower( name, value )
        
	local added = false
	
	if name then
			
		local currentValue = self:retrieve( name ) or 0
		
		if currentValue then
			if currentValue ~= 0 then
				if value < currentValue then
					self._items[ name ] = value
					added = true
					self._header.modified = os.time()
				end
			else
				self._items[ name ] = value
				added = true
				self._header.modified = os.time()
			end
		end
		
	end
	
	if self:isAutomaticSavingEnabled() then
		self:save()
	end
	
	return added, value
        
end

--- Retrieves a value from the icebox.
-- @param name The name of the value to retrieve.
-- @return The value. Nil if none found.
function IceBox:retrieve( name )
	if name then
		return self._items[ name ]
	end
end

--- Increments a value in the icebox.
-- @param name The name of the value to increment. Must be a number type.
-- @param amount The amount to increment the value. Optional, default is 1.
function IceBox:increment( name, amount )

	local value = self:retrieve( name )
	
	if not value then
		value = self:store( name, 0 )
	end
	
	if value and type( value ) == "number" then
		value = value + ( amount or 1 )
	end
	
	self:store( name, value )
	
	self._header.modified = os.time()
	
	if self:isAutomaticSavingEnabled() then
		self:save()
	end	
	
end

--- Decrements a value in the icebox.
-- @param name The name of the value to decrement. Must be a number type.
-- @param amount The amount to decrement the value. Optional, default is 1.
function IceBox:decrement( name, amount )
	
	local value = self:retrieve( name )
	
	if not value then
		value = self:store( name, 0 )
	end
	
	if value and type( value ) == "number" then
		value = value - ( amount or 1 )
	end
	
	self:store( name, value )
	
	self._header.modified = os.time()
	
	if self:isAutomaticSavingEnabled() then
		self:save()
	end
	
end

--- Checks if a value is in the icebox.
-- @param name The name of the value to check for.
-- @return True of the value exists, False otherwise.
function IceBox:hasValue( name )
	if name then
		if self._items[ name ] ~= nil then
			return true
		else
			return false
		end
	end

end

--- Removes a value from the icebox.
-- @param name The name of the value to remove.
function IceBox:remove( name )
	if name then
		if self:hasValue( name ) then
			self._items[ name ] = nil
			self._header.modified = os.time()
		end
	end
	
	if self:isAutomaticSavingEnabled() then
		self:save()
	end
end

--- Returns all items in the icebox.
-- @return The stored items.
function IceBox:getItems()
	return self._items
end

--- Returns the header of the icebox.
-- @return The header.
function IceBox:getHeader()
	return self._header
end

--- Enables automatic saving. If enabled, the icebox will save everytime an element is added, remove or changed.
function IceBox:enableAutomaticSaving()
	self._automaticSavingEnabled = true
end

--- Disables automatic saving.
function IceBox:disbleAutomaticSaving()
	self._automaticSavingEnabled = false
end

--- Checks if automatic saving is enabled or not.
-- @return True if it is, false if not.
function IceBox:isAutomaticSavingEnabled()
	return self._automaticSavingEnabled
end

--- Saves the icebox to disk.
function IceBox:save()

	self:delete()
	
	local database = openDatabase( self._databaseName )
	
	if database then
		saveDatabase( database, self._items, self._header )
  	end
	
end

--- Loads the icebox from disk.
function IceBox:load()

	local database = openDatabase( self._databaseName )
	
	if database then
		self._items, self._header = loadDatabase( database )
	
		if not self._header or self._header == {} then
			self._header = createHeader()
		end
  	end
  	
end

--- Gets the name of the icebox.
function IceBox:getName()
	return self._name
end

--- Prints out all items in the icebox.
function IceBox:print()
	print( tableToString( self._items ) )
end

--- Bookmarks the current state of the icebox so that it can be restored at any time.
-- @param name The name of the restore point.
function IceBox:setRestorePoint( name )
	
	if name then
	
		local restoreName = createRestorePointName( name, self._databaseName )
		
		local database = openDatabase( restoreName )
		
		if database then
			saveDatabase( database, self._items )
		end
		
	end
	
end

--- Restores the state of the icebox from a bookmarked point.
-- @param name The name of the restore point.
function IceBox:restoreToPoint( name )
	
	if name then
	
		local restoreName = createRestorePointName( name, self._databaseName )
		
		local database = openDatabase( restoreName )
		
		if database then
	
			self:clear()
			
			self._items, self._header = loadDatabase( database )
	
			if self:isAutomaticSavingEnabled() then
				self:save()
			end
	
		end
	
	end
	
end


--- Deletes a bookmarked point.
-- @param name The name of the restore point.
function IceBox:deleteRestorePoint( name )

	if name then
	
		local restoreName = createRestorePointName( name, self._databaseName )
		
		deleteDatabase( restoreName )
		
	end
end

--- Clears all items out of the icebox and saves it.
function IceBox:clear()
	self._items = nil
	self._items = {}
	
	if self:isAutomaticSavingEnabled() then
		self:save()
	end
	
end

--- Deletes the stored icebox from the disk.
function IceBox:delete()
	local path = system.pathForFile( self._databaseName, system.DocumentsDirectory )
	os.remove( path )
end

--- Clears and deletes the icebox.
function IceBox:destroy()
	self:clear()
	self:delete()
end

--_G.ice = Ice:new()

return Ice:new()
