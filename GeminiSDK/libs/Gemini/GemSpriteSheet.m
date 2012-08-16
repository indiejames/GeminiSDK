//
//  GeminiSpriteSheet.m
//  Gemini
//
//  Created by James Norton on 3/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GemSpriteSheet.h"


@implementation GemSpriteSheet

@synthesize imageFileName;
@synthesize textureInfo;
@synthesize frameCount;
@synthesize frames;
@synthesize frameCoords;

static GLKTextureInfo *createTexture(NSString * imgFileName){
    
    NSRange separatorRange = [imgFileName rangeOfString:@"."];
    
    NSString *imgFilePrefix = [imgFileName substringToIndex:separatorRange.location];
    NSString *imgFileSuffix = [imgFileName substringFromIndex:separatorRange.location + 1];
    
    NSMutableDictionary *options = [NSMutableDictionary dictionaryWithCapacity:1];
    [options setValue:[NSNumber numberWithBool:YES] forKey:GLKTextureLoaderOriginBottomLeft];
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:imgFilePrefix ofType:imgFileSuffix];
    
    GLKTextureInfo *textId = [GLKTextureLoader textureWithContentsOfFile:filePath options:options error:nil];
    
    assert(textId != nil);
    
    return textId;
}

-(id) initWithImage:(NSString *)imgFileName Data:(NSArray *)data {
    self = [super init];
    
    if (self) {
        
        imageFileName = [[NSString alloc] initWithString:imgFileName];
        textureInfo = [createTexture(imageFileName) retain];
        GLfloat imgWidth = textureInfo.width;
        GLfloat imgHeight = textureInfo.height;
        frames = (GLKVector4 *)malloc([data count] * sizeof(GLKVector4));
        frameCount = [data count];
        frameWidths = (GLfloat *)malloc([data count] * sizeof(GLfloat));
        frameHeights = (GLfloat *)malloc([data count] * sizeof(GLfloat));
        frameCoords = (GLfloat *)malloc([data count] * 12 *sizeof(GLfloat));
        for (int i=0; i<[data count]; i++) {
            NSDictionary *frame = (NSDictionary *)[data objectAtIndex:i];
            
            GLfloat frmWidth = [(NSNumber *)[frame valueForKey:@"width"] floatValue];
            GLfloat frmHeight = [(NSNumber *)[frame valueForKey:@"height"] floatValue];
            GLfloat x = [(NSNumber *)[frame valueForKey:@"x"] floatValue];
            GLfloat y = [(NSNumber *)[frame valueForKey:@"y"] floatValue];
            
            GLfloat x0 = x / imgWidth;
            GLfloat y0 = (imgHeight - y - frmHeight) / imgHeight; // reorient y axis
            GLfloat x1 = x0 + frmWidth / imgWidth;
            GLfloat y1 = y0 + frmHeight / imgHeight;
            
            frames[i] = GLKVector4Make(x0,y0,x1,y1);
            frameWidths[i] = frmWidth;
            frameHeights[i] = frmHeight;
            
            frameCoords[i*12] = -frmWidth / 2.0;
            frameCoords[i*12+1] = -frmHeight / 2.0;
            frameCoords[i*12+2] = 1.0;
            frameCoords[i*12+3] = -frmWidth / 2.0;
            frameCoords[i*12+4] = frmHeight / 2.0;
            frameCoords[i*12+5] = 1.0;
            frameCoords[i*12+6] = frmWidth / 2.0;
            frameCoords[i*12+7] = -frmHeight / 2.0;
            frameCoords[i*12+8] = 1.0;
            frameCoords[i*12+9] = frmWidth / 2.0;
            frameCoords[i*12+10] = frmHeight / 2.0;
            frameCoords[i*12+11] = 1.0;
        }
    }
    
    return self;
}

-(id)initWithImage:(NSString *)imgFileName FrameWidth:(int)width FrameHeight:(int)height {
    
    self = [super init];
    
    if (self) {
        imageFileName = [[NSString alloc] initWithString:imgFileName];
        textureInfo = [createTexture(imageFileName) retain];
        frameWidth = width;
        frameHeight = height;
        GLfloat imgWidth = textureInfo.width;
        GLfloat imgHeight = textureInfo.height;
        framesPerRow = textureInfo.width / frameWidth;
        numRows = textureInfo.height / frameHeight;
        frames = (GLKVector4 *)malloc(numRows * framesPerRow * sizeof(GLKVector4));
        frameCount = numRows * framesPerRow;
        frameWidths = (GLfloat *)malloc(numRows * framesPerRow * sizeof(GLfloat));
        frameHeights = (GLfloat *)malloc(numRows * framesPerRow * sizeof(GLfloat));
        frameCoords = (GLfloat *)malloc(numRows * framesPerRow * 12 *sizeof(GLfloat));
        for (int i=0; i<numRows*framesPerRow; i++) {
            unsigned int row = i / framesPerRow;
            unsigned int col = i % framesPerRow;
            GLfloat y0 = (imgHeight - (row + 1) * frameHeight) / imgHeight;
            GLfloat x0 = (col * frameWidth) / imgWidth;
            GLfloat x1 = x0 + frameWidth / imgWidth;
            GLfloat y1 = y0 + frameHeight / imgHeight;
            
            frames[i] = GLKVector4Make(x0, y0, x1, y1);
            frameWidths[i] = frameHeight;
            frameHeights[i] = frameWidth;
            
            frameCoords[i*12] = -frameWidth / 2.0;
            frameCoords[i*12+1] = -frameHeight / 2.0;
            frameCoords[i*12+2] = 1.0;
            frameCoords[i*12+3] = -frameWidth / 2.0;
            frameCoords[i*12+4] = frameHeight / 2.0;
            frameCoords[i*12+5] = 1.0;
            frameCoords[i*12+6] = frameWidth / 2.0;
            frameCoords[i*12+7] = -frameHeight / 2.0;
            frameCoords[i*12+8] = 1.0;
            frameCoords[i*12+9] = frameWidth / 2.0;
            frameCoords[i*12+10] = frameHeight / 2.0;
            frameCoords[i*12+11] = 1.0;

        }
    }
        
    
    return self;
}

-(GLfloat)frameWidth:(unsigned int)frameNum {
    return frameWidths[frameNum];

}

-(GLfloat)frameHeight:(unsigned int)frameNum {
    return frameHeights[frameNum];
}

-(GLKVector4)texCoordsForFrame:(unsigned int)frameNum {
    return frames[frameNum];
}


-(void)dealloc {
    [imageFileName release];
    free(frames);
    [super dealloc];
}

@end
