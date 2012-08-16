//
//  GeminiEvent.m
//  Gemini
//
//  Created by James Norton on 2/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GemEvent.h"
#import "LGeminiEvent.h"

@implementation GemEvent
@synthesize source;

-(id)initWithLuaState:(lua_State *)luaState Source:(GemObject *)src {
    self = [super initWithLuaState:luaState];
    if (self) {
        self.source = src;
        
        // create a lua object for this event
        GemEvent **levent = (GemEvent **)lua_newuserdata(L, sizeof(GemEvent *));
        *levent = self;
        
        luaL_getmetatable(L, GEMINI_EVENT_LUA_KEY);
        
        lua_setmetatable(L, -2);
        
        lua_newtable(L);
        
        // add a reference to the source into the userdata
        if (src != nil) {
            lua_pushstring(L, "source");
            lua_rawgeti(L, LUA_REGISTRYINDEX, src.selfRef);
            lua_rawset(L, -3);
        }
                
        lua_pushvalue(L, -1); // make a copy of the table becaue the next line pops the top value
        // store a reference to this table so our event methods can access it
        self.propertyTableRef = luaL_ref(L, LUA_REGISTRYINDEX);
        lua_setuservalue(L, -2);
        
        lua_pushvalue(L, -1); // make another copy of the userdata since the next line will pop it off
        self.selfRef = luaL_ref(L, LUA_REGISTRYINDEX);
        
        
        
        // empty the stack
        lua_pop(L, lua_gettop(L));
        
    }
    
    return self;
}

@end
