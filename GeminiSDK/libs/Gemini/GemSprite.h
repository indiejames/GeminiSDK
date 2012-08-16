//
//  GeminiSprite.h
//  Gemini
//
//  Created by James Norton on 3/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GemDisplayObject.h"
#import "GemSpriteSet.h"


@interface GemSprite : GemDisplayObject {
    GemSpriteSet *spriteSet;
    GemSpriteAnimation *currentAnimation;
    GemSpriteSheet *spriteSheet;
    GLKVector4 *frames;
    GLfloat *frameCoords;
    double lastUpdateTime;
    double accumulatedTime;
    unsigned int currentFrame;
    BOOL paused;
}

@property (readonly) GLKTextureInfo *textureInfo;
@property (readonly) GLKVector4 textureCoord;
@property BOOL paused;
@property (readonly) GLfloat *frameCoords;

-(id) initWithLuaState:(lua_State *)luaState SpriteSet:(GemSpriteSet *)ss;
-(void)prepare;
-(void)prepareAnimation:(NSString *)animationName;
-(void)update:(double)currentTime;
-(void)play:(double)currentTime;
-(void)pause:(double)currentTime;
-(void)setCurrentFrame:(int)cframe;

@end
