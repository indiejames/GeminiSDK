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
#import "GemTimer.h"


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

//
// addEventListner - add an event listener/handler to an ojbect.  This handler will get called
// when the objects is notified of the event.
//  GemObjects have tables where the keys are event types and the values are other tables that
// hold events listeners.  These sub tables have the listeners as their keys and the references
// in LUA_REGISTRYINDEX as the values.  The references are used to make sure the listeners don't
// go out of scope and get GC'ed.  This allows anonymous functions to be used for event listeners.
// Listeners can be functions or tables/userdata.  If the listener is a table/userdata, it must
// contain a function of the same name as the event.
int addEventListener(lua_State *L){
    // stack: 1 - object, 2 - event name, 3 - listener (function or table)
    __unsafe_unretained GemObject **go = (__unsafe_unretained GemObject **)lua_touserdata(L, 1);
    const char *eventName = luaL_checkstring(L, 2);
    NSString *name = [NSString stringWithFormat:@"%s", eventName];
    
    if ([name isEqualToString:GEM_TIMER_EVENT_NAME]) {
        GemLog(@"Adding timer event");
    }
    
    // get the event handler table
    lua_rawgeti(L, LUA_REGISTRYINDEX, (*go).eventListenerTableRef);
    // get the event handlers for this event
    lua_getfield(L, -1, eventName);
    
    if (lua_istable(L, -1)) {
        // use the existing table that holds listeners for this event
        
        // push the listener to the top of the stack twice since the next operation will pop it
        lua_pushvalue(L, 3);
        lua_pushvalue(L, -1);
        // get a ref for this listener
        int ref = luaL_ref(L, LUA_REGISTRYINDEX);
        lua_pushinteger(L, ref);
        // use listener as key and ref as value for event listener table
        lua_rawset(L, -3);
    } else {
        lua_pushstring(L, eventName);
        // create a new table to hold listeners for this event
        lua_newtable(L);
        // make the new table the event table for the given event name
        lua_settable(L, -4);
        // pull our event table back out since it just popped of the stack
        lua_getfield(L, -2, eventName);
        
        // push the listener to the top of the stack twice since the next operation will pop it
        lua_pushvalue(L, 3);
        lua_pushvalue(L, -1);
        int ref = luaL_ref(L, LUA_REGISTRYINDEX);
        lua_pushinteger(L, ref);
        // add the listener to the new table as the key with the ref as the value
        lua_rawset(L, -3);
        
    }
    
    GemLog(@"LGeminiObject: Added event listener for %@ event for %@", name, (*go).name);
    
    return 0;
}

int removeEventListener(lua_State *L){
    // stack: 1 - object, 2 - event name, 3 - listener
    __unsafe_unretained GemObject **go = (__unsafe_unretained GemObject **)lua_touserdata(L, 1);
    const char *eventName = luaL_checkstring(L, 2);
    NSString *name = [NSString stringWithFormat:@"%s", eventName];
    
    // get the event handler table
    lua_rawgeti(L, LUA_REGISTRYINDEX, (*go).eventListenerTableRef);
    // get the event handlers for this event
    lua_getfield(L, -1, eventName);
    
    if (lua_istable(L, -1)) {
        // use the existing table that holds listeners for this event
       // push the listener to the top of the stack
        lua_pushvalue(L, 3);
        lua_settable(L, -3);
    } else {
        lua_pushstring(L, eventName);
        // create a new table to hold listeners for this event
        lua_newtable(L);
        lua_settable(L, -4);
        lua_getfield(L, -2, eventName);
        lua_pushinteger(L, 1);
        // push the listener to the top of the stack
        lua_pushvalue(L, 3);
        lua_settable(L, -3);
    }

    
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