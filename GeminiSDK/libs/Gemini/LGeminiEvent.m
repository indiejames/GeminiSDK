//
//  LGeminiEvent.m
//  Gemini
//
//  Created by James Norton on 7/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "LGeminiEvent.h"
#import "GemEvent.h"
#import "LGeminiLuaSupport.h"

int luaopen_event_lib(lua_State *L);

static int eventIndex(lua_State *L){
    int rval = 0;
    rval = genericIndex(L);
    return rval;
}


// mappings for the event methods
static const struct luaL_Reg event_m [] = {
    {"__index", eventIndex},
    {NULL, NULL}
};


int luaopen_event_lib (lua_State *L){
    // create meta table for our event type
    createMetatable(L, GEMINI_EVENT_LUA_KEY, event_m);
    
    return 0;
}
