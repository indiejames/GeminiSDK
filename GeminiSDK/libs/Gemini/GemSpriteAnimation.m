//
//  GeminiSpriteAnimation.m
//  Gemini
//
//  Created by James Norton on 3/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GemSpriteAnimation.h"

@implementation GemSpriteAnimation
@synthesize startFrame, frameCount, frameDuration, loopCount;

-(id) init {
    self = [super init];
    
    if (self) {
        // defaults
        startFrame = 1;
        frameCount = 0;
        frameDuration = 0.1;
        loopCount = 0;
    }
    
    return self;
}

@end
