//
//  GeminiEvent.h
//  Gemini
//
//  Created by James Norton on 2/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GemObject.h"

#define GEM_EVENT_LUA_KEY "GeminiLib.GEMINI_EVENT_LUA_KEY"


@interface GemEvent : GemObject {
    GemObject *target;  // the object receiving the event
    NSNumber *timestamp;
}

@property (nonatomic, strong) GemObject *target;
@property (readonly) NSNumber *timestamp;

-(id) initWithLuaState:(lua_State *)luaState Target:(GemObject *)trgt LuaKey:(const char *)luaKey;
-(id)initWithLuaState:(lua_State *)luaState Target:(GemObject *)trgt;
//-(id)initWithLuaState:(lua_State *)luaState Target:(GemObject *)trgt Event:(UIEvent *)event;

@end