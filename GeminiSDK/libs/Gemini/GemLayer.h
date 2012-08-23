//
//  GeminiLayer.h
//  Gemini
//
//  Created by James Norton on 5/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GemDisplayGroup.h"

@class GemScene;

@interface GemLayer : GemDisplayGroup {
    int index; // the relative depth of the layer
    GLenum sourceBlend;
    GLenum destBlend;
    BOOL isBLendingLayer;
    GLfloat _alpha;
    GemScene *scene;
}

@property (nonatomic) int index;
@property (readonly) GLenum sourceBlend;
@property (readonly) GLenum destBlend;
@property (nonatomic) BOOL isBLendingLayer;
@property (nonatomic, retain) GemScene *scene;

-(void)setBlendFuncSource:(GLenum)srcBlend Dest:(GLenum)dstBlend;

@end
