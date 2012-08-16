//
//  LGeminiTimer.m
//  Gemini
//
//  Created by James Norton on 6/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "LGeminiTimer.h"
#import "GemTimer.h"
#import "GemGLKViewController.h"
#import "Gemini.h"

static int performWithDelay(lua_State *L){
    int numArgs = lua_gettop(L);
    
    double delay = luaL_checknumber(L, 1);
    
    // copy the listener to the top of the stack
    lua_pushvalue(L, -2);
    // get a reference to the listener
    int listener = luaL_ref(L, LUA_REGISTRYINDEX);
    
    int numIterations = 1; // default
    
    if (numArgs == 3) {
        // num iterations was specified
        numIterations = luaL_checkint(L, -1);
    }
    
    
    GemTimer *timer = [[GemTimer alloc] initWithLuaState:L Delay:delay Listener:listener NumIterations:numIterations];
    [((GemGLKViewController *)([Gemini shared].viewController)).timerManager addTimer:timer];
    
    GemTimer **lTimer = (GemTimer **)lua_newuserdata(L, sizeof(GemTimer *));
    
    *lTimer = timer;
    
    setupObject(L, GEMINI_TIMER_LUA_KEY, timer);
    
    return 1;
    
}

static int cancel(lua_State *L){
    GemTimer **timer = luaL_checkudata(L, 1, GEMINI_TIMER_LUA_KEY);
    [*timer cancel];
    
    return 0;
}

static int doPause(lua_State *L){
    GemTimer **timer = luaL_checkudata(L, 1, GEMINI_TIMER_LUA_KEY);
    [*timer pause:((GemGLKViewController *)([Gemini shared].viewController)).updateTime];
    
    return 0;

}

static int resume(lua_State *L){
    GemTimer **timer = luaL_checkudata(L, 1, GEMINI_TIMER_LUA_KEY);
    [*timer resume:((GemGLKViewController *)([Gemini shared].viewController)).updateTime];
    
    return 0;
    
}

static int timerGC (lua_State *L){
   
    GemTimer  **timer = (GemTimer **)luaL_checkudata(L, 1, GEMINI_TIMER_LUA_KEY);
    [*timer release];
    
    return 0;
}

static int timerNewIndex(lua_State *L){
    
    // defualt to storing value in attached lua table
    lua_getuservalue( L, -3 );
    /* object, key, value */
    lua_pushvalue(L, -3);
    lua_pushvalue(L,-3);
    lua_rawset( L, -3 );
                        
    return 0;
}

// the mappings for the library functions
static const struct luaL_Reg timerLib_f [] = {
    {"performWithDelay", performWithDelay},
    {"pause", doPause},
    {"resume", resume},
    {NULL, NULL}
};

// mappings for the timer methods
static const struct luaL_Reg timer_m [] = {
    {"__gc", timerGC},
    {"__index", genericIndex},
    {"__newindex", timerNewIndex},
    {NULL, NULL}
};


int luaopen_timer_lib (lua_State *L){
    // create meta tables for our timer type /////////
    
    // timer
    createMetatable(L, GEMINI_TIMER_LUA_KEY, timer_m);

    
    /////// finished with metatables ///////////
    
    // create the table for this library and popuplate it with our functions
    luaL_newlib(L, timerLib_f);
    
    return 1;
}