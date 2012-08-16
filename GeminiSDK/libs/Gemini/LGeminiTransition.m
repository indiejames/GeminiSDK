//
//  LGeminiTransition.m
//  Gemini
//
//  Created by James Norton on 5/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "LGeminiTransition.h"
#import "GemDisplayObject.h"
#import "GemTransistion.h"
#import "GemTransitionManager.h"

int luaopen_transition_lib (lua_State *L);

// call onComplete that takes a display object as its parameter
void callOnStartForDisplayObject(lua_State *L, int methodRef, GemDisplayObject *obj){
    lua_rawgeti(L, LUA_REGISTRYINDEX, methodRef);
    
    if(lua_istable(L, -1)) {
        lua_pushstring(L, "onStart");
        lua_rawget(L, -2);
    } 
    
    lua_rawgeti(L, LUA_REGISTRYINDEX, obj.selfRef);
    lua_pcall(L, 1, 0, 0);
    // empty the stack
    lua_pop(L, lua_gettop(L));
}

// call onComplete that takes a display object as its parameter
void callOnCompleteForDisplayObject(lua_State *L, int methodRef, GemDisplayObject *obj){
    lua_rawgeti(L, LUA_REGISTRYINDEX, methodRef);
    
    if(lua_istable(L, -1)) {
        lua_pushstring(L, "onComplete");
        lua_rawget(L, -2);
    } 
    
    lua_rawgeti(L, LUA_REGISTRYINDEX, obj.selfRef);
    lua_pcall(L, 1, 0, 0);
    // empty the stack
    lua_pop(L, lua_gettop(L));
}


static int createTransition(lua_State *L, BOOL to){
    GemDisplayObject **displayObj = (GemDisplayObject **)lua_touserdata(L, 1);
    if (!lua_istable(L, 2)) {
        luaL_error(L, "transition.to/from expects second parameter to be a table");
        return 0;
    }
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:1];
    
    lua_pushnil(L);  /* first key */
    while (lua_next(L, 2) != 0) {
        /* uses 'key' (at index -2) and 'value' (at index -1) */
        printf("%s - %s\n",
               lua_typename(L, lua_type(L, -2)),
               lua_typename(L, lua_type(L, -1)));
        const char *key = lua_tostring(L, -2);
        if (strcmp(key, "onStart") == 0 || strcmp(key, "onComplete") == 0) {
            // value is a function
            int ref = luaL_ref(L, LUA_REGISTRYINDEX);
            [params setObject:[NSNumber numberWithInt:ref] forKey:[NSString stringWithUTF8String:key]];
        } else {
            
            double val = lua_tonumber(L, -1);
            
            [params setObject:[NSNumber numberWithDouble:val] forKey:[NSString stringWithUTF8String:key]];
            
        }
                
        /* removes 'value'; keeps 'key' for next iteration */
        lua_pop(L, 1);
    }
    
    GemTransistion *transition = [[GemTransistion alloc] initWithLuaState:L Object:*displayObj Data:params To:to];
    GemTransistion **ltrans = (GemTransistion **)lua_newuserdata(L, sizeof(GemTransistion *));
    *ltrans = transition;
    
    [[GemTransitionManager shared] addTransition:transition];
    
    return 1;
}

static int transitionTo(lua_State *L){
    return createTransition(L, YES);
}

static int transitionFrom(lua_State *L){
    return createTransition(L, NO);
}

static int transitionCancel(lua_State *L){
    GemTransistion **trans = (GemTransistion **)luaL_checkudata(L, 1, GEMINI_TRANSITION_LUA_KEY);
    [[GemTransitionManager shared] removeTransition:*trans];
    
    return 0;
}

static int transitionDissolve(lua_State *L){
    return 0;
}

static int gc(lua_State *L){
    GemTransistion **trans = (GemTransistion **)luaL_checkudata(L, 1, GEMINI_TRANSITION_LUA_KEY);
    [*trans release];
    
    return 0;
}

static int newIndex(lua_State *L){
    
    return 0;
}



// the mappings for the library functions
static const struct luaL_Reg transitionLib_f [] = {
    {"to", transitionTo},
    {"from", transitionFrom},
    {"cancel", transitionCancel},
    {NULL, NULL}
};

// mappings for the transition methods
static const struct luaL_Reg transition_m [] = {
    {"cancel", transitionCancel},
    {"dissolve", transitionDissolve},
    {"__gc", gc},
    {"__index", genericIndex},
    {"__newindex", newIndex},
    {NULL, NULL}
};

int luaopen_transition_lib (lua_State *L){
    // create meta table for transition objects /////////
    createMetatable(L, GEMINI_TRANSITION_LUA_KEY, transition_m);
        
    // create the table for this library and popuplate it with our functions
    luaL_newlib(L, transitionLib_f);
    
    return 1;
}