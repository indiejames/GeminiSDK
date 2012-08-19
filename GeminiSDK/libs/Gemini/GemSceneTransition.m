//
//  GemSceneTransition.m
//  GeminiSDK
//
//  Created by James Norton on 8/17/12.
//
//

#import "GemSceneTransition.h"

@implementation GemSceneTransition


// must return YES if the transition is complete, NO otherwise
-(BOOL)transit:(double)currentTime {
    // default implementation just switches scenes at end of transition
    BOOL rval = NO;
    if (currentTime > startTime + duration) {
        rval = YES;
        // render sceneB
    } else {
        // render sceneA
    }
    
    return rval;
}

- (id)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

-(void)dealloc {
    [super dealloc];
}

@end
