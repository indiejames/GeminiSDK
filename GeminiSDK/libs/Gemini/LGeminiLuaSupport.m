//
//  LGeminiLuaSupport.m
//  Gemini
//
//  Created by James Norton on 5/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "LGeminiLuaSupport.h"

// call a lua method that takes a display object as its parameter
void callLuaMethodForDisplayObject(lua_State *L, int methodRef, GemDisplayObject *obj){
    lua_rawgeti(L, LUA_REGISTRYINDEX, methodRef);
    lua_rawgeti(L, LUA_REGISTRYINDEX, obj.selfRef);
    lua_pcall(L, 1, 0, 0);
    // empty the stack
    lua_pop(L, lua_gettop(L));
}

void createMetatable(lua_State *L, const char *key, const struct luaL_Reg *funcs){
    luaL_newmetatable(L, key);    
    lua_pushvalue(L, -1); // duplicates the metatable
    luaL_setfuncs(L, funcs, 0);
}

// generic index method for userdata types
int genericIndex(lua_State *L){
    // first check the uservalue 
    lua_getuservalue( L, -2 );
    if(lua_isnil(L,-1)){
        // NSLog(@"user value for user data is nil");
    }
    lua_pushvalue( L, -2 );
    
    lua_rawget( L, -2 );
    if( lua_isnoneornil( L, -1 ) == 0 )
    {
        return 1;
    }
    
    lua_pop( L, 2 );
    
    // second check the metatable   
    lua_getmetatable( L, -2 );
    lua_pushvalue( L, -2 );
    lua_rawget( L, -2 );
    
    // nil or otherwise, we return here
    return 1;
    
}

// generic indexing for GeminiObjects
int genericGeminiDisplayObjectIndex(lua_State *L, GemDisplayObject *obj){
    if (lua_isstring(L, -1)) {
        
        
        const char *key = lua_tostring(L, -1);
        if (strcmp("xReference", key) == 0) {
            
            GLfloat xRef = obj.xReference;
            lua_pushnumber(L, xRef);
            return 1;
        } else if (strcmp("yReference", key) == 0) {
            
            GLfloat yref = obj.yReference;
            lua_pushnumber(L, yref);
            return 1;
            
        } else if (strcmp("xOrigin", key) == 0) {
            
            GLfloat xOrig = obj.xOrigin;
            lua_pushnumber(L, xOrig);
            return 1;
        } else if (strcmp("yOrigin", key) == 0) {
            
            GLfloat yOrig = obj.yOrigin;
            lua_pushnumber(L, yOrig);
            return 1;
            
        } else if (strcmp("x", key) == 0) {
            
            GLfloat x = obj.x;
            lua_pushnumber(L, x);
            return 1;
            
        } else if (strcmp("y", key) == 0) {
            
            GLfloat y = obj.y;
            lua_pushnumber(L, y);
            return 1;
            
        } else if (strcmp("width", key) == 0){
            GLfloat width = obj.width;
            lua_pushnumber(L, width);
            return 1;
            
        } else if (strcmp("alpha", key) == 0){
            GLfloat alpha = obj.alpha;
            lua_pushnumber(L, alpha);
            return 1;
            
        } else if (strcmp("rotation", key) == 0) {
            
            GLfloat rot = obj.rotation;
            lua_pushnumber(L, rot);
            return 1;
            
        } else if (strcmp("name", key) == 0){
            NSString *name = obj.name;
            lua_pushstring(L, [name UTF8String]);
            return 1;
        } else if (strcmp("isVisible", key) == 0){
            bool visible = obj.isVisible;
            lua_pushboolean(L, visible);
            return 1;
        } else {
            return genericIndex(L);
        }
        
    }
    
    return 0;
    
}


// generic new index method for userdata types
int genericGemDisplayObjecNewIndex(lua_State *L, GemDisplayObject **obj){
    
    if (lua_isstring(L, 2)) {
        
        if (obj != NULL) {
            const char *key = lua_tostring(L, 2);
            if (strcmp("xReference", key) == 0) {
                
                GLfloat xref = luaL_checknumber(L, 3);
                [*obj setXReference:xref];
                return 0;
                
            } else if (strcmp("yReference", key) == 0) {
                
                GLfloat yref = luaL_checknumber(L, 3);
                [*obj setYReference:yref];
                return 0;
                
            } else if (strcmp("x", key) == 0) {
                
                GLfloat x = luaL_checknumber(L, 3);
                [*obj setX:x];
                return 0;
                
            } else if (strcmp("y", key) == 0) {
                
                GLfloat y = luaL_checknumber(L, 3);
                [*obj setY:y];
                return 0;
                
            } else if (strcmp("xOrigin", key) == 0) {
                
                GLfloat xOrigin = luaL_checknumber(L, 3);
                [*obj setXOrigin:xOrigin];
                return 0;
                
            } else if (strcmp("yOrigin", key) == 0) {
                
                GLfloat yOrigin = luaL_checknumber(L, 3);
                [*obj setYOrigin:yOrigin];
                return 0;
                
            } else if (strcmp("rotation", key) == 0) {
                
                GLfloat rot = luaL_checknumber(L, 3);
                [*obj setRotation:rot];
                return 0;
                
            } else if (strcmp("xScale", key) == 0){
                GLfloat xScale = luaL_checknumber(L, 3);
                [*obj setXScale:xScale];
                
                return 0;
                
            } else if (strcmp("yScale", key) == 0){
                GLfloat yScale = luaL_checknumber(L, 3);
                [*obj setYScale:yScale];
                return 0;
                
            } else if (strcmp("width", key) == 0){
                GLfloat width = luaL_checknumber(L, 3);
                [*obj setWidth:width];
                return 0;
                
            } else if (strcmp("alpha", key) == 0){
                GLfloat alpha = luaL_checknumber(L, 3);
                [*obj setAlpha:alpha];
                return 0;
                
            } else if (strcmp("name", key) == 0){
                
                const char *valCStr = lua_tostring(L, 3);
                //NSLog(@"Setting object name to %s", valCStr);
                (*obj).name = [NSString stringWithUTF8String:valCStr];
            } else if (strcmp("isVisible", key) == 0){
                BOOL visible = lua_toboolean(L, 3);
                [*obj setIsVisible:visible];
                return 0;
            } 
        }
        
        // defualt to storing value in attached lua table
        lua_getuservalue( L, -3 );
        /* object, key, value */
        lua_pushvalue(L, -3);
        lua_pushvalue(L,-3);
        lua_rawset( L, -3 );
        
        return 0;
    } 
    
    
    
    return 0;
    
}

int removeSelf(lua_State *L){
    GemDisplayObject **displayObj = (GemDisplayObject **)lua_touserdata(L, -1);
    [(*displayObj).parent remove:*displayObj];
    
    return 0;
}

// used to set common defaults for all display objects
// this function expects a table to be the top item on the stack
void setDefaultValues(lua_State *L) {
    assert(lua_type(L, -1) == LUA_TTABLE);
    lua_pushstring(L, "x");
    lua_pushnumber(L, 0);
    lua_settable(L, -3);
    
    lua_pushstring(L, "y");
    lua_pushnumber(L, 0);
    lua_settable(L, -3);
    
    lua_pushstring(L, "xOrigin");
    lua_pushnumber(L, 0);
    lua_settable(L, -3);
    
    lua_pushstring(L, "yOrigin");
    lua_pushnumber(L, 0);
    lua_settable(L, -3);
    
    lua_pushstring(L, "xReference");
    lua_pushnumber(L, 0);
    lua_settable(L, -3);
    
    lua_pushstring(L, "yReference");
    lua_pushnumber(L, 0);
    lua_settable(L, -3);
    
}

// generic init method
void setupObject(lua_State *L, const char *luaKey, GemObject *obj){
    
    luaL_getmetatable(L, luaKey);
    lua_setmetatable(L, -2);
    
    // append a lua table to this user data to allow the user to store values in it
    lua_newtable(L);
    lua_pushvalue(L, -1); // make a copy of the table becaue the next line pops the top value
    // store a reference to this table so our object methods can access it
    obj.propertyTableRef = luaL_ref(L, LUA_REGISTRYINDEX);
    
    // add in some default values for display objects
    if ([obj isKindOfClass:[GemDisplayObject class]]) {
        setDefaultValues(L);
    }
    
    
    // set the table as the user value for the Lua object
    lua_setuservalue(L, -2);
    
    lua_pushvalue(L, -1); // make another copy of the userdata since the next line will pop it off
    obj.selfRef = luaL_ref(L, LUA_REGISTRYINDEX);
}

