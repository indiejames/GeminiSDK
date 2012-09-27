//
//  GemOpenGLState.m
//  GeminiSDK
//
//  Created by James Norton on 9/24/12.
//
//

#import "GemOpenGLState.h"

GemOpenGLState *gemOpenGLStateSingleton = nil;

@implementation GemOpenGLState

-(id)init {
    self = [super init];
    
    if (self) {
        [self setGlDepthMask:GL_FALSE];
        [self setGlBlend:GL_FALSE];
    }
    
    return self;
}

+(GemOpenGLState *) shared {
    
    if (gemOpenGLStateSingleton == nil) {
        gemOpenGLStateSingleton = [[GemOpenGLState alloc] init];
    }
    
    return gemOpenGLStateSingleton;
}
@end
