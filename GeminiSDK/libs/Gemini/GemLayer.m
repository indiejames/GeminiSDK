//
//  GeminiLayer.m
//  Gemini
//
//  Created by James Norton on 5/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GemLayer.h"
#import "LGeminiDisplay.h"

@implementation GemLayer
@synthesize index;
@synthesize sourceBlend;
@synthesize destBlend;
@synthesize isBLendingLayer;
@synthesize scene;

-(id)initWithLuaState:(lua_State *)luaState {
    self = [super initWithLuaState:luaState LuaKey:GEMINI_LAYER_LUA_KEY];
    if (self) {
        // default is no blending
        sourceBlend = GL_SRC_ALPHA;
        destBlend = GL_ONE_MINUS_SRC_ALPHA;
        isBLendingLayer = YES;
    }
    
    return self;
}

-(void) setBlendFuncSource:(GLenum)srcBlend Dest:(GLenum)dstBlend {
    sourceBlend = srcBlend;
    destBlend = dstBlend;
    if (srcBlend == GL_ONE && dstBlend == GL_ZERO) {
        isBLendingLayer = NO;
    } else {
        isBLendingLayer = YES;
    }
}

-(void)insert:(GemDisplayObject *)obj {
    NSLog(@"GemLayer %d inserting object %@", self.index, obj.name);
    [super insert:obj];
}

// layers take up the whole screen so this always passes
// TODO - change this to check to see if the point is within the
// screen bounds
-(BOOL)doesContainPoint:(GLKVector2)point {
    return YES;
}

@end
