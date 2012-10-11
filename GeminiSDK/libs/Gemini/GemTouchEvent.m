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

-(id)initWithLuaState:(lua_State *)luaState Target:trgt  {
    self = [super initWithLuaState:luaState Target:trgt];
    
    if (self) {
        
    }
    
    return self;
}

@end
