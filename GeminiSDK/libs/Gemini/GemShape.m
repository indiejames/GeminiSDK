//
//  GemShape.m
//  GeminiSDK
//
//  Created by James Norton on 10/20/12.
//
//

#import "GemShape.h"

@implementation GemShape

@synthesize vertColor;

-(GLfloat) strokeWidth {
    return strokeWidth;
}

-(void)setStrokeWidth:(GLfloat)w {
    strokeWidth = w;
    needsUpdate = YES;
    
}

-(void)setFillColor:(GLKVector4)fill {
    fillColor = fill;
    for (int i=0; i<numInnerlVerts; i++) {
        vertColor[i*4] = fill.r;
        vertColor[i*4+1] = fill.g;
        vertColor[i*4+2] = fill.b;
        vertColor[i*4+3] = fill.a;
    }
}


-(GLKVector4)fillColor {
    return fillColor;
}

-(void)setStrokeColor:(GLKVector4)sColor {
    strokeColor = sColor;
    
    for (int i=numInnerlVerts; i<numBorderVerts+numInnerlVerts; i++) {
        vertColor[i*4] = sColor.r;
        vertColor[i*4+1] = sColor.g;
        vertColor[i*4+2] = sColor.b;
        vertColor[i*4+3] = sColor.a;
    }
}

-(GLKVector4)strokeColor {
    return strokeColor;
}


-(void)setLayer:(GemLayer *)_layer {
    [super setLayer:_layer];
}

-(GLfloat *)verts {
    if (needsUpdate) {
        [self computeVertices];
        
    }
    
    return verts;
    
}

-(GLuint)vertCount {
    return numInnerlVerts + numBorderVerts;
}

-(GLuint)vertIndexCount {
    // must be overriden by subclasses
    
    return 0;
}

-(GLushort *)vertIndex {
    if (needsUpdate) {
        [self computeVertices];
    }
    
    return vertIndex;
}

-(void)computeVertices {
    // must be overridden by subclasses
}

@end
