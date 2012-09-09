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
#import "LGeminiObject.h"

static int performWithDelay(lua_State *L){
    // stack : 1 - delay, 2 - callback (funciton or table/userdata), 3 - num iterations (optional)
    GemLog(@"LGeminiTimer:performWithDelay()");
    int numArgs = lua_gettop(L);
    
    double delay = luaL_checknumber(L, 1);
    
    int numIterations = 1; // default
    
    if (numArgs == 3) {
        // num iterations was specified
        numIterations = luaL_checkint(L,3);
    }
    
    
    GemTimer *timer = [[GemTimer alloc] initWithLuaState:L Delay:delay Listener:-1 NumIterations:numIterations];
    
    
    int timerIndex = lua_gettop(L);
    
    [((GemGLKViewController *)([Gemini shared].viewController)).timerManager addTimer:timer];
    
    
   // __unsafe_unretained GemTimer **lTimer = (__unsafe_unretained GemTimer **)lua_newuserdata(L, sizeof(GemTimer *));
    
    //*lTimer = timer;
    
    const char *ename = [GEM_TIMER_EVENT_NAME UTF8String];
    
    lua_pushstring(L, ename);
    
    // copy the listener to the top of the stack
    lua_pushvalue(L, 2);

    // remove the bottom of the stack so the next call will work
    lua_remove(L, 1);
    lua_remove(L, 1);
    if (numArgs == 3) {
        lua_remove(L, 1);
    }
   
    addEventListener(L);
    
    // put our new timer on top of the stack
    lua_pushvalue(L, -1);
    
    GemLog(@"LGeminiTimer:performWithDelay - done");
    
    return 1;
    
}

static int cancel(lua_State *L){
    __unsafe_unretained GemTimer **timer = (__unsafe_unretained GemTimer **)luaL_checkudata(L, 1, GEMINI_TIMER_LUA_KEY);
    [*timer cancel];
    
    return 0;
}

static int doPause(lua_State *L){
    __unsafe_unretained GemTimer **timer = (__unsafe_unretained GemTimer **)luaL_checkudata(L, 1, GEMINI_TIMER_LUA_KEY);
    [*timer pause:((GemGLKViewController *)([Gemini shared].viewController)).updateTime];
    
    return 0;

}

static int resume(lua_State *L){
    __unsafe_unretained GemTimer **timer = (__unsafe_unretained GemTimer **)luaL_checkudata(L, 1, GEMINI_TIMER_LUA_KEY);
    [*timer resume:((GemGLKViewController *)([Gemini shared].viewController)).updateTime];
    
    return 0;
    
}

static int timerGC (lua_State *L){
   
   // __unsafe_unretained GemTimer  **timer = (__unsafe_unretained GemTimer **)luaL_checkudata(L, 1, GEMINI_TIMER_LUA_KEY);
   
    
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