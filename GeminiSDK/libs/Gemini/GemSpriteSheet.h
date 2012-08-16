//
//  GeminiSpriteSheet.h
//  Gemini
//
//  Created by James Norton on 3/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

@interface GemSpriteSheet : NSObject {
    GLKVector4 *frames;
    int frameCount;
    NSString *imageFileName;
    GLKTextureInfo *textureInfo;
    GLfloat frameWidth;
    GLfloat frameHeight;
    int framesPerRow;
    int numRows;
    GLfloat *frameWidths;
    GLfloat *frameHeights;
    GLfloat *frameCoords;
}


@property (readonly) NSString *imageFileName;
@property (readonly) GLKTextureInfo *textureInfo;
//@property (readonly) GLfloat frameWidth;
//@property (readonly) GLfloat frameHeight;
@property (readonly) int frameCount;
@property (readonly) GLKVector4 *frames;
@property (readonly) GLfloat *frameCoords;

-(id) initWithImage:(NSString *)imageFileName Data:(NSArray *)data;
-(id)initWithImage:(NSString *)imgFileName FrameWidth:(int)width FrameHeight:(int)height;
-(GLKVector4)texCoordsForFrame:(unsigned int)frame;
-(GLfloat)frameWidth:(unsigned int)frameNum;
-(GLfloat)frameHeight:(unsigned int)frameNum;

-(int) frameCount;

@end
