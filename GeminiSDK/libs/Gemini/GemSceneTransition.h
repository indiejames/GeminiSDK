//
//  GemSceneTransition.h
//  GeminiSDK
//
//  Created by James Norton on 8/17/12.
//
//

#import <Foundation/Foundation.h>
#import "GemScene.h"

@interface GemSceneTransition : NSObject {
    GemScene *sceneA;
    GemScene *sceneB;
    double startTime;
    double duration;
}

@property (nonatomic, retain) GemScene *sceneA;
@property (nonatomic, retain) GemScene *sceneB;
@property (nonatomic) double startTime;
@property (nonatomic) double duration;

-(id)init;
-(BOOL)transit:(double)currentTime;

@end
