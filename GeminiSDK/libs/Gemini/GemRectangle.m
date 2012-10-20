//
//  GeminiRectangle.m
//  Gemini
//
//  Created by James Norton on 5/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GemRectangle.h"
#import "GemLayer.h"
#import "LGeminiDisplay.h"
#import "GemBoundsTests.h"
#import "GLUtils.h"

@implementation GemRectangle


@synthesize vertColor;


-(id) initWithLuaState:(lua_State *)luaState X:(GLfloat)x0 Y:(GLfloat)y0 Width:(GLfloat)w Height:(GLfloat)h {
    self = [super initWithLuaState:luaState LuaKey:GEMINI_RECTANGLE_LUA_KEY];
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
    NSLog(@"GemRectangle: calling dealloc for rectangle %@", self.name);
    free(verts);
    free(vertIndex);
    free(vertColor);
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
    GLfloat z = 1; // this is not used in the renderer
    
    // inner portion
    vertIndex[0] = 3;
    vertIndex[1] = 3;
    vertIndex[2] = 0;
    vertIndex[3] = 2;
    vertIndex[4] = 1;
    vertIndex[5] = 1;
    
    // border
    vertIndex[6] = 8;
    vertIndex[7] = 8;
    vertIndex[8] = 4;
    vertIndex[9] = 9;
    vertIndex[10] = 5;
    vertIndex[11] = 10;
    vertIndex[12] = 6;
    vertIndex[13] = 11;
    vertIndex[14] = 7;
    vertIndex[15] = 8;
    vertIndex[16] = 4;
    vertIndex[17] = 4;
    
    
         
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

-(BOOL)doesContainPoint:(GLKVector2)point {
    
    if (physicsBody) {
        GemLog(@"Using physics body to test point for %@", name);
        return [super doesContainPoint:point];
    }
    
    GLfloat newVerts[36];
    unsigned int vertCount = 4;
    //unsigned int indexCount = 6;
    unsigned int indexCount = 6;
    if (strokeWidth > 0) {
        vertCount = 12;
        //indexCount = 30;
        indexCount = 18;
    }
    
    // apply the cumulative transform to our vertices
    transformVertices(newVerts, verts, vertCount, cumulativeTransform);
    
    // check our AABB first (determined by our four outer vertices (4,5,6,7)
    GLfloat minX = newVerts[4*3];
    GLfloat minY = newVerts[4*3+1];
    GLfloat maxX = minX;
    GLfloat maxY = minY;
    
    for (int i=5; i<8; i++) {
        if (newVerts[i*3] < minX) {
            minX = newVerts[i*3];
        } else if (newVerts[i*3] > maxX){
            maxX = newVerts[i*3];
        }
        
        if (newVerts[i*3+1] < minY) {
            minY = newVerts[i*3+1];
        } else if (newVerts[i*3+1] > maxY){
            maxY = newVerts[i*3+1];
        }
    }
    
    if (point.x < minX || point.x > maxX || point.y < minY || point.y > maxY) {
        GemLog(@"point is outside bounding box (minX = %f, maxX = %f, minY = %f, maxY = %f", minX,maxX,minY,maxY);
        return NO;
    }
    
    
    // now check every triangle composed by our vertices
    GLKVector2 triangle[3];
    for (int i=2; i<vertCount;i++) {
        for (int j=0; j<3; j++) {
            triangle[j].x = newVerts[(i-j)*3];
            triangle[j].y = newVerts[(i-j)*3+1];
        }
        
        if (testTriangleIntersection(triangle, point)) {
            return YES;
        }
    }
    
    return NO;
}

@end
