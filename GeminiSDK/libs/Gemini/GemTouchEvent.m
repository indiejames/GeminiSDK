//
//  GemTouchEvent.m
//  GeminiSDK
//
//  Created by James Norton on 10/9/12.
//
//

#import "GemTouchEvent.h"


@implementation GemTouchEvent

@synthesize phase;
@synthesize x;
@synthesize y;
@synthesize startX;
@synthesize startY;

-(id)initWithLuaState:(lua_State *)luaState Target:trgt Event:(UIEvent *)evt  {
    self = [super initWithLuaState:luaState Target:trgt LuaKey:GEM_TOUCH_EVENT_LUA_KEY];
    
    if (self) {
        NSTimeInterval ts = evt.timestamp;
        timestamp = [NSNumber numberWithDouble:ts];
    }
    
    return self;
}

@end
