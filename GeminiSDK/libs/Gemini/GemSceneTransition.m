//
//  GemSceneTransition.m
//  GeminiSDK
//
//  Created by James Norton on 8/17/12.
//
//

#import "GemSceneTransition.h"
#import "Gemini.h"
#import "GemGLKViewController.h"

@implementation GemSceneTransition

@synthesize sceneA, sceneB, elapsedTime, duration;


// must return YES if the transition is complete, NO otherwise
// overide this to create custom transitions
-(BOOL)transit:(double)timeSinceLastRender {
    // default implementation just switches scenes at end of transition
    BOOL rval = NO;
    elapsedTime += timeSinceLastRender;
    if (elapsedTime > duration) {
        rval = YES;
        // render sceneB
        [((GemGLKViewController *)[Gemini shared].viewController).director.renderer renderScene:sceneB];
    } else {
        // render sceneA
        [((GemGLKViewController *)[Gemini shared].viewController).director.renderer renderScene:sceneA];
    }
    
    return rval;
}

- (id)init
{
    self = [super init];
    if (self) {
        elapsedTime = 0;
    }
    return self;
}


@end
