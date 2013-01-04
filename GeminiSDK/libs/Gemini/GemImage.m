//
//  GemImage.m
//  GeminiSDK
//
//  Created by James Norton on 1/3/13.
//
//

#import "GemImage.h"

@implementation GemImage {
    NSString *imageName;
}

@synthesize imageName;

-(id) initWithLuaState:(lua_State *)luaState SpriteSheet:(GemSpriteSheet *)ss ForImageName:(NSString *)imgName {
    
    GLuint imageIndex = [ss indexForFilename:imgName];
    GemSpriteSet *gss = [[GemSpriteSet alloc] initWithSpriteSheet:ss StartFrame:imageIndex NumFrames:1];
    
    self = [super initWithLuaState:luaState SpriteSet:gss];
    
    if (self) {
        imageName = imgName;
        currentFrame = 1;
    }
    
    return self;
}

// overrides of sprite animation methods that don't apply to static images
-(void)prepare {
}

-(void)prepareAnimation:(NSString *)animationName {
}

-(void)play:(double)currentTime{
}

-(void)pause:(double)currentTime {
}

-(void)update:(double)currentTime {
}

-(void)setCurrentFrame:(int)cframe {
}

// end of overrides

@end
