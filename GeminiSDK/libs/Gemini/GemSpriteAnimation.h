//
//  GeminiSpriteAnimation.h
//  Gemini
//
//  Created by James Norton on 3/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

/*
 loopCount - 
 A value of 1 or greater sets the number of times the animation sequence will loop. When done it will stop on the last frame of the sequence.
 A loopParam of 0 (which is the default) means that the sequence will loop indefinitely.
 A loopParam of -1 means that the sequence will "bounce" back and forth exactly once (1, 2, 3, 2, 1).
 Finally, a loopParam of -2 means that the sequence will bounce back and forth forever. In our 3-frame example, this would play in the following order: 1, 2, 3, 2, 1, 2, 3, 2, 1 (...) and so on.
 
 */

#import <Foundation/Foundation.h>

@interface GemSpriteAnimation : NSObject {
    int startFrame;
    int frameCount;
    float frameDuration;
    int loopCount;
}

@property (nonatomic) int startFrame;
@property (nonatomic) int frameCount;
@property (nonatomic) float frameDuration;
@property (nonatomic) int loopCount;

@end
