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
@synthesize target;
@synthesize timestamp;

-(id) initWithLuaState:(lua_State *)luaState Target:(GemObject *)trgt LuaKey:(const char *)luaKey {
    self = [super initWithLuaState:luaState LuaKey:luaKey];
    // empty the stack
    lua_pop(L, lua_gettop(L));
    if (self) {
        target = trgt;
    }
    
    return self;
}

-(id)initWithLuaState:(lua_State *)luaState Target:(GemObject *)trgt {
    self = [super initWithLuaState:luaState LuaKey:GEMINI_EVENT_LUA_KEY];
    // empty the stack
    lua_pop(L, lua_gettop(L));
    if (self) {
        target = trgt;
    }
    
    return self;

}

/*
-(id)initWithLuaState:(lua_State *)luaState Target:(GemObject *)trgt Event:(UIEvent *)evt; {
    self = [super initWithLuaState:luaState LuaKey:GEMINI_EVENT_LUA_KEY];
    if (self) {
        target = trgt;
        if (evt) {
            timestamp = [NSNumber numberWithDouble:evt.timestamp];
        }
        
    }
    
    return self;
}*/

@end
