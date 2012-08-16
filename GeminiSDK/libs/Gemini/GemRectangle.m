//
//  GeminiRectangle.m
//  Gemini
//
//  Created by James Norton on 5/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GemRectangle.h"
#import "GemLayer.h"

@implementation GemRectangle


@synthesize vertColor;


-(id) initWithLuaState:(lua_State *)luaState X:(GLfloat)x0 Y:(GLfloat)y0 Width:(GLfloat)w Height:(GLfloat)h {
    self = [super initWithLuaState:luaState];
    if (self) {
        self.width = w;
        self.height = h;
        self.xOrigin = x0;
        self.yOrigin = y0;
        self.xReference = 0;
        self.yReference = 0;
        
        //points = (GLKVector2 *)malloc(4*sizeof(GLKVector2));
        //points[0] = GLKVector2Make(x0,y0+h);
        verts = (GLfloat *)malloc(12*3*sizeof(GLfloat));
        vertColor = (GLfloat *)malloc(12*4*sizeof(GLfloat));
        vertIndex = (GLushort *)malloc(30*sizeof(GLushort));
        strokeWidth = 0;
        
        [self setStrokeColor:GLKVector4Make(1.0, 1.0, 1.0, 1.0)];
        [self setFillColor:GLKVector4Make(1.0, 1.0, 1.0, 1.0)];
    }
    
    return self;
}

-(void)dealloc {
    free(verts);
    free(vertIndex);
    free(vertColor);
    
    [super dealloc];
}

-(GLuint) numTriangles {
    GLuint rval = 10;
    
    if (strokeWidth == 0) {
        rval = 2;
    }
    
    return rval;
}

-(void)setLayer:(GemLayer *)_layer {
    [super setLayer:_layer];
}

-(GLfloat) strokeWidth {
    return strokeWidth;
}

-(void)setStrokeWidth:(GLfloat)w {
    strokeWidth = w;
    needsUpdate = YES;
    
}

-(void)setStrokeColor:(GLKVector4)sColor {
    strokeColor = sColor;
    
    for (int i=4; i<12; i++) {
        vertColor[i*4] = sColor.r;
        vertColor[i*4+1] = sColor.g;
        vertColor[i*4+2] = sColor.b;
        vertColor[i*4+3] = sColor.a;
    }
}

-(GLKVector4)strokeColor {
    return strokeColor;
}

-(void)setFillColor:(GLKVector4)fill {
    fillColor = fill;
    for (int i=0; i<4; i++) {
        vertColor[i*4] = fill.r;
        vertColor[i*4+1] = fill.g;
        vertColor[i*4+2] = fill.b;
        vertColor[i*4+3] = fill.a;
    }
}

-(GLKVector4)fillColor {
    return fillColor;
}

// always pass in four colors, one for each corner
-(void)setGradient:(GLKVector4 *)grad {
    memcpy(gradient, grad, 4*sizeof(GLKVector4));
    for (int i=0; i<4; i++) {
        vertColor[i*4] = grad[i].r;
        vertColor[i*4+1] = grad[i].g;
        vertColor[i*4+2] = grad[i].b;
        vertColor[i*4+3] = grad[i].a;
    }

}

-(GLKVector4 *)gradient {
    return gradient;
}

-(GLfloat *)verts {
    if (needsUpdate) {
        [self computeVertices];
        
    }
    
    return verts;
    
}

-(GLushort *)vertIndex {
    if (needsUpdate) {
        [self computeVertices];
    }
    
    return vertIndex;
}

-(void)computeVertices {
    //GLfloat z = ((GLfloat)layerIndex) / 256.0 - 0.5;
    GLfloat z = 1;
    
    // inner portion
    vertIndex[0] = 0;
    vertIndex[1] = 1;
    vertIndex[2] = 2;
    vertIndex[3] = 0;
    vertIndex[4] = 2;
    vertIndex[5] = 3;
    
    // border
    vertIndex[6] = 4;
    vertIndex[7] = 5;
    vertIndex[8] = 9;
    vertIndex[9] = 4;
    vertIndex[10] = 9;
    vertIndex[11] = 8;
    vertIndex[12] = 5;
    vertIndex[13] = 6;
    vertIndex[14] = 10;
    vertIndex[15] = 5;
    vertIndex[16] = 10;
    vertIndex[17] = 9;
    vertIndex[18] = 6;
    vertIndex[19] = 7;
    vertIndex[20] = 11;
    vertIndex[21] = 6;
    vertIndex[22] = 11;
    vertIndex[23] = 10;
    vertIndex[24] = 7;
    vertIndex[25] = 4;
    vertIndex[26] = 8;
    vertIndex[27] = 7;
    vertIndex[28] = 8;
    vertIndex[29] = 11;
    
    if (strokeWidth > 0) {
        // inner portion
        verts[0] = -self.width / 2.0 + strokeWidth;
        verts[1] = -self.height / 2.0 + strokeWidth;
        verts[2] = z;
        verts[3] = self.width / 2.0 - strokeWidth;
        verts[4] = -self.height / 2.0 + strokeWidth;
        verts[5] = z;
        verts[6] = self.width / 2.0 - strokeWidth;
        verts[7] = self.height / 2.0 - strokeWidth;
        verts[8] = z;
        verts[9] = -self.width / 2.0 + strokeWidth;
        verts[10] = self.height / 2.0 - strokeWidth;
        verts[11] = z;
        
        // border
        verts[12] = -self.width / 2.0;
        verts[13] = -self.height / 2.0;
        verts[14] = z;
        verts[15] = self.width / 2.0;
        verts[16] = -self.height / 2.0;
        verts[17] = z;
        verts[18] = self.width / 2.0;
        verts[19] = self.height / 2.0;
        verts[20] = z;
        verts[21] = -self.width / 2.0;
        verts[22] = self.height / 2.0;
        verts[23] = z;
        verts[24] = verts[0];
        verts[25] = verts[1];
        verts[26] = verts[2];
        verts[27] = verts[3];
        verts[28] = verts[4];
        verts[29] = verts[5];
        verts[30] = verts[6];
        verts[31] = verts[7];
        verts[32] = verts[8];
        verts[33] = verts[9];
        verts[34] = verts[10];
        verts[35] = verts[11];
        
        
    } else {
        verts[0] = -self.width / 2.0;
        verts[1] = -self.height / 2.0;
        verts[2] = z;
        verts[3] = self.width / 2.0;
        verts[4] = -self.height / 2.0;
        verts[5] = z;
        verts[6] = self.width / 2.0;
        verts[7] = self.height / 2.0;
        verts[8] = z;
        verts[9] = -self.width / 2.0;
        verts[10] = self.height / 2.0;
        verts[11] = z;
    }
    
    needsUpdate = NO;
}

@end
