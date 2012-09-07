//
//  LGeminiObject.m
//  Gemini
//
//  Created by James Norton on 2/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#include <stdio.h>
#import "Gemini.h"
#import "GemObject.h"
#import "LGeminiObject.h"


static int newGeminiObject(lua_State *L){
    GemObject *go = [[GemObject alloc] initWithLuaState:L];
    
    __unsafe_unretained GemObject **lgo = (__unsafe_unretained GemObject **)lua_newuserdata(L, sizeof(GemObject *));
    *lgo = go;
    
    luaL_getmetatable(L, GEMINI_OBJECT_LUA_KEY);
    lua_setmetatable(L, -2);
    
    lua_newtable(L);
    lua_pushvalue(L, -1); // make a copy of the table becaue the next line pops the top value
    // store a reference to this table so our sprite methods can access it
    go.propertyTableRef = luaL_ref(L, LUA_REGISTRYINDEX);
    lua_setuservalue(L, -2);
    
    lua_pushvalue(L, -1); // make another copy of the userdata since the next line will pop it off
    go.selfRef = luaL_ref(L, LUA_REGISTRYINDEX);
    
    // create a table for the event listeners
    lua_newtable(L);
    go.eventListenerTableRef = luaL_ref(L, LUA_REGISTRYINDEX);
    
    // copy the userdata to the top of the stack
    lua_pushvalue(L, -2);
    
    GemLog(@"New GeminiObject created");
    
    // add this new object to the globall list of objects
    [[Gemini shared].geminiObjects addObject:go];
    
    return 1;
    
}

static int geminiObjectGC (lua_State *L){
    GemLog(@"GeminiObject released");
    return 0;
}

int addEventListener(lua_State *L){
    __unsafe_unretained GemObject **go = (__unsafe_unretained GemObject **)lua_touserdata(L, 1);
    const char *eventName = luaL_checkstring(L, 2);
    NSString *name = [NSString stringWithFormat:@"%s", eventName];
    
        
    //int callback = luaL_ref(L, LUA_REGISTRYINDEX);

    //[*go addEventListener:callback forEvent:name];
    
    // get the event handler table
    lua_rawgeti(L, LUA_REGISTRYINDEX, (*go).eventListenerTableRef);
    // get the event handlers for this event
    lua_getfield(L, -1, eventName);
    
    if (lua_istable(L, -1)) {
        int index = luaL_len(L, -1);
        lua_pushinteger(L, index+1);
        lua_pushvalue(L, 3);
        lua_settable(L, -3);
    } else {
        lua_pushstring(L, eventName);
        lua_newtable(L);
        lua_settable(L, -4);
        lua_getfield(L, -2, eventName);
        lua_pushinteger(L, 1);
        lua_pushvalue(L, 3);
        lua_settable(L, -3);
    }
    
    GemLog(@"LGeminiObject: Added event listener for %@ event for %@", name, (*go).name);
    
    return 0;
}

int removeEventListener(lua_State *L){
    __unsafe_unretained GemObject **go = (__unsafe_unretained GemObject **)lua_touserdata(L, 1);
    const char *eventName = luaL_checkstring(L, 2);
    NSString *name = [NSString stringWithFormat:@"%s", eventName];
    int callback = luaL_ref(L, LUA_REGISTRYINDEX);
    [*go removeEventListener:callback forEvent:name];
    
    GemLog(@"LGeminiObject: Removed event listener for %@ event for %@", name, (*go).name);
    
    
    return 0;

    
}



static int l_irc_index( lua_State* L )
{
    GemLog(@"Calling l_irc_index()");
    /* object, key */
    /* first check the environment */ 
    lua_getuservalue( L, -2 );
    if(lua_isnil(L,-1)){
        GemLog(@"user value for user data is nil");
    }
    lua_pushvalue( L, -2 );
    
    lua_rawget( L, -2 );
    if( lua_isnoneornil( L, -1 ) == 0 )
    {
        return 1;
    }
    
    lua_pop( L, 2 );
    
    /* second check the metatable */    
    lua_getmetatable( L, -2 );
    lua_pushvalue( L, -2 );
    lua_rawget( L, -2 );
    
    /* nil or otherwise, we return here */
    return 1;
}

// this function gets called with the table on the bottom of the stack, the index to assign to next,
// and the value to be assigned on top
// TODO - set the underlying GeminiObject properties to match the lua table value
static int l_irc_newindex( lua_State* L )
{
    GemLog(@"Calling l_irc_newindex()");
    int top = lua_gettop(L);
    GemLog(@"stack has %d values", top);
    /* object, key, value */
    
    lua_getuservalue( L, -3 );  // table attached is attached to objects via user value
    /*BOOL newtable = NO;
    if (lua_isnil(L, -1)) {
        GemLog(@"No data table for lua object");
        // this object has no lua table associated with it yes, so create a table and set it
        lua_newtable(L);
        newtable = YES;
    }
    if (newtable) {
        lua_pushvalue( L, -4 );
        lua_pushvalue( L, -4 );
        lua_rawset( L, -3 );
        lua_setuservalue(L, -5);
    } else {*/
        lua_pushvalue(L, -3);
        lua_pushvalue(L,-3);
        lua_rawset( L, -3 );
    //}
    
    return 0;
}

static const struct luaL_Reg geminiObjectLib_f [] = {
    {"new", newGeminiObject},
    {NULL, NULL}
};

static const struct luaL_Reg geminiObjectLib_m [] = {
    {"addEventListener", addEventListener},
    {"removeEventListener", removeEventListener},
    {"__gc", geminiObjectGC},
    {"__index", l_irc_index},
    {"__newindex", l_irc_newindex},
    {NULL, NULL}
};

int luaopen_geminiObjectLib (lua_State *L){
    // create the metatable and put it into the registry
    luaL_newmetatable(L, GEMINI_OBJECT_LUA_KEY);
    
    lua_pushvalue(L, -1); // duplicates the metatable
    
    
    luaL_setfuncs(L, geminiObjectLib_m, 0);
    
    // create a table/library to hold the functions
    luaL_newlib(L, geminiObjectLib_f);
    
    GemLog(@"gemini lib opened");
    
    return 1;
}