//
//  GemCollisionEvent.m
//  GeminiSDK
//
//  Created by James Norton on 11/29/12.
//
//

#import "GemCollisionEvent.h"


@implementation GemCollisionEvent
@synthesize source;

-(id) initWithLuaState:(lua_State *)luaState Target:(GemDisplayObject *)trgt Source:(GemDisplayObject *)src {
    self = [super initWithLuaState:luaState Target:trgt LuaKey:GEM_COLLISION_EVENT_LUA_KEY];
    
    if (self) {
        self.source = src;
    }
    
    return self;
}


@end
