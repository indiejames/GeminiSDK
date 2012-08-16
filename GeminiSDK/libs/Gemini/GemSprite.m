//
//  GeminiSprite.m
//  Gemini
//
//  Created by James Norton on 3/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GemSprite.h"
#import <GLKit/GLKit.h>
#import "GemSpriteAnimation.h"


@implementation GemSprite
@synthesize paused;

-(id)initWithLuaState:(lua_State *)luaState SpriteSet:(GemSpriteSet *)spSet {
    self = [super initWithLuaState:luaState];
    
    if (self) {
        spriteSet = [spSet retain];
        spriteSheet = [spriteSet.spriteSheet retain];
        frameCoords = spriteSheet.frameCoords;
        frames = spriteSheet.frames;
        currentAnimation = [spriteSet getAnimation:GEMINI_DEFAULT_ANIMATION];
        paused = YES;
        currentFrame = 0;
        accumulatedTime = 0;
    }
    
    return self;
}

/*-(NSDictionary *)currentFrameData {
    unsigned int sequenceFrame = currentAnimation.startFrame + currentFrame - 1;
   
    return (NSDictionary *)[spriteSet.spriteSheet.frames objectAtIndex:sequenceFrame];
}*/

-(GLKTextureInfo *)textureInfo {
    GLKTextureInfo *texInfo = spriteSheet.textureInfo;
    return texInfo;
}

-(GLKVector4)textureCoord {
    unsigned int sequenceFrame = currentAnimation.startFrame + currentFrame - 1;
    return [spriteSheet texCoordsForFrame:sequenceFrame];
}

-(GLfloat *)frameCoords {
    unsigned int sequenceFrame = currentAnimation.startFrame + currentFrame - 1;
    return frameCoords + sequenceFrame * 12;
}

// height and width can change with each frame
-(GLfloat)width {
    return [spriteSheet frameWidth:currentFrame];
}

-(GLfloat)height {
    return [spriteSheet frameHeight:currentFrame];
}

-(void)prepare {
    currentFrame = 0;
    accumulatedTime = 0;
}

-(void)prepareAnimation:(NSString *)animationName {
    currentAnimation = [spriteSet getAnimation:animationName];
    [self prepare];
}

-(void)play:(double)currentTime{
    lastUpdateTime = currentTime;
    paused = NO;
}

-(void)pause:(double)currentTime {
    [self update:currentTime];
    paused = YES;
}

-(void)update:(double)currentTime {
    // TODO - verify this logic
    if (!paused) {
        double timeDelta = currentTime - lastUpdateTime;
        lastUpdateTime = currentTime;
        accumulatedTime += timeDelta;
        unsigned int rawFrameNum = (int)(accumulatedTime / currentAnimation.frameDuration);
        if (currentAnimation.loopCount == 0) {
            // loop forever
            currentFrame = rawFrameNum % (currentAnimation.frameCount);
            //NSLog(@"Current frame = %d", currentFrame);
            
        } else if(currentAnimation.loopCount >= 1){
            // loop n times then stop on last frame
            currentFrame = rawFrameNum % currentAnimation.frameCount;
            if (currentFrame >= currentAnimation.loopCount * currentAnimation.frameCount) {
                currentFrame = currentAnimation.frameCount - 1;
                paused = YES;
            } else {
                currentFrame = rawFrameNum % currentAnimation.frameCount;
            }
        } else if(currentAnimation.loopCount == -1) {
            // see-saw back and forth between first and last frame exacly once
            if (rawFrameNum >= 2*(currentAnimation.frameCount - 1)) {
                currentFrame = 0;
            } else {
                currentFrame = rawFrameNum % (2*(currentAnimation.frameCount-1));
                if (currentFrame >= currentAnimation.frameCount) {
                    currentFrame = currentAnimation.frameCount - currentFrame % (currentAnimation.frameCount - 1) - 1;
                }
            }
            
        } else {
            // see-saw back and forth forever
            currentFrame = rawFrameNum % (2*(currentAnimation.frameCount-1));
            if (currentFrame >= currentAnimation.frameCount) {
                currentFrame = currentAnimation.frameCount - currentFrame % (currentAnimation.frameCount - 1) - 1;
            }
        }
    }
}

-(void)setCurrentFrame:(int)cframe {
    currentFrame = cframe;
}

- (void)dealloc
{
    [spriteSheet release];
    [spriteSet release];
    [super dealloc];
}

@end
