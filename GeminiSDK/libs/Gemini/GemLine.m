//
//  GeminiLine.m
//  Gemini
//
//  Created by James Norton on 3/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GemLine.h"
#import "GemDisplayGroup.h"

@implementation GemLine

@synthesize points;
@synthesize numPoints;
@synthesize verts;
@synthesize vertIndex;
@synthesize color;

-(id)initWithLuaState:(lua_State *)luaState X1:(GLfloat)x1 Y1:(GLfloat)y1 X2:(GLfloat)x2 Y2:(GLfloat)y2 {
    self = [super initWithLuaState:luaState];
    if (self) {
        points = (GLfloat *)malloc(4 * sizeof(GLfloat));
        points[0] = 0;
        points[1] = 0;
        points[2] = x2 - x1;
        points[3] = y2 - y1;
        numPoints = 2;
        self.xOrigin = x1;
        self.yOrigin = y1;
        verts = NULL;
        vertIndex = NULL;
        width = 1.0;
        [self computeVertices];
    }
    
    return self;
    
}

-(id)initWithLuaState:(lua_State *)luaState Parent:(GemDisplayGroup *)prt X1:(GLfloat)x1 Y1:(GLfloat)y1 X2:(GLfloat)x2 Y2:(GLfloat)y2 {
    self = [super initWithLuaState:luaState];
    
    if (self) {
        [prt insert:self]; 
        points = (GLfloat *)malloc(4 * sizeof(GLfloat));
        points[0] = 0;
        points[1] = 0;
        points[2] = x2-x1;
        points[3] = y2-y1;
        numPoints = 2;
        self.xOrigin = x1;
        self.yOrigin = y1;
        verts = NULL;
        vertIndex = NULL;
        width = 1.0;
        [self computeVertices];
    }
    
    return self;
}

-(void)dealloc {
    free(points);
    free(verts);
    free(vertIndex);
    [parent remove:self];
}

// add points to this line - expect newPoints to hold 2 * count GLfloats
-(void)append:(int)count Points:(const GLfloat *)newPoints {
    points = (GLfloat *)realloc(points, (numPoints + count) * 2 * sizeof(GLfloat));
    memcpy(points + numPoints * 2, newPoints, count*2*sizeof(GLfloat));
    
    // normalize points
    for (int i=numPoints; i<numPoints + count; i++) {
        points[i*2] = points[i*2] - self.xOrigin;
        points[i*2+1] = points[i*2+1] - self.yOrigin;
    }
    
    numPoints = numPoints + count;
    
    [self computeVertices];
}

// need to override this to force verts to be recomputed
-(void)setWidth:(GLfloat)w {
    [super setWidth:w];
    [self computeVertices];
}

-(void)computeVertices {
    
    GLfloat z = 1;
    verts = (GLfloat *)realloc(verts, 2*3*numPoints*sizeof(GLfloat));
    vertIndex = (GLushort *)realloc(vertIndex, 6*(numPoints - 1)*sizeof(GLushort));
    GLfloat halfWidth = self.width / 2.0;
    
    for (int i=0; i<numPoints; i++) {
        
        if (i != 0){
            vertIndex[(i-1)*6] = (i-1)*2;
            vertIndex[(i-1)*6+1] = (i-1)*2+1;
            vertIndex[(i-1)*6+2] = (i-1)*2+2;
            vertIndex[(i-1)*6+3] = (i-1)*2+1;
            vertIndex[(i-1)*6+4] = (i-1)*2+3;
            vertIndex[(i-1)*6+5] = (i-1)*2+2;
            
        }
        
        if (i == 0) { // first point
            
            // compute adjacent points
            GLKVector2 vecA = GLKVector2Make(points[i*2], points[i*2+1]);
            GLKVector2 vecB = GLKVector2Make(points[(i+1)*2], points[(i+1)*2+1]);
            GLKVector2 vecAB = GLKVector2Subtract(vecB, vecA);
            GLKVector2 vecABhat = GLKVector2Normalize(vecAB);
            GLKVector2 vecA0 = GLKVector2Add(GLKVector2MultiplyScalar(GLKVector2Make(-vecABhat.y, vecABhat.x), halfWidth), vecA);
            GLKVector2 vecA1 = GLKVector2Add(GLKVector2MultiplyScalar(GLKVector2Make(vecABhat.y, -vecABhat.x), halfWidth), vecA);
            verts[0] = vecA0.x;
            verts[1] = vecA0.y;
            verts[2] = z;
            verts[3] = vecA1.x;
            verts[4] = vecA1.y;
            verts[5] = z;
            
        } else if(i == numPoints - 1) { // last point            
            
            // compute adjacent points
            GLKVector2 vecC = GLKVector2Make(points[i*2], points[i*2+1]);
            GLKVector2 vecB = GLKVector2Make(points[(i-1)*2], points[(i-1)*2+1]);
            GLKVector2 vecBC = GLKVector2Subtract(vecC, vecB);
            GLKVector2 vecBChat = GLKVector2Normalize(vecBC);
            GLKVector2 vecC0 = GLKVector2Add(GLKVector2MultiplyScalar(GLKVector2Make(-vecBChat.y, vecBChat.x), halfWidth), vecC);
            GLKVector2 vecC1 = GLKVector2Add(GLKVector2MultiplyScalar(GLKVector2Make(vecBChat.y, -vecBChat.x), halfWidth), vecC);
            verts[i*6] = vecC0.x;
            verts[i*6+1] = vecC0.y;
            verts[i*6+2] = z;
            verts[i*6+3] = vecC1.x;
            verts[i*6+4] = vecC1.y;
            verts[i*6+5] = z;
            
            
        } else {
            
            // get the previous computed points
            GLKVector2 vecA = GLKVector2Make(points[(i-1)*2], points[(i-1)*2+1]);
            GLKVector2 vecB = GLKVector2Make(points[i*2], points[i*2+1]);
            GLKVector2 vecC = GLKVector2Make(points[(i+1)*2], points[(i+1)*2+1]);
            
            GLKVector2 vecA0 = GLKVector2Make(verts[(i-1)*6], verts[(i-1)*6+1]);
            GLKVector2 vecA1 = GLKVector2Make(verts[(i-1)*6+3], verts[(i-1)*6+4]);
            
            GLKVector2 vecAB = GLKVector2Subtract(vecB, vecA);
            GLKVector2 vecBC = GLKVector2Subtract(vecC, vecB);
            GLKVector2 vecBChat = GLKVector2Normalize(vecBC);
            
            GLKVector2 vecC0 = GLKVector2Add(GLKVector2MultiplyScalar(GLKVector2Make(-vecBChat.y, vecBChat.x), halfWidth), vecC);
            GLKVector2 vecC1 = GLKVector2Add(GLKVector2MultiplyScalar(GLKVector2Make(vecBChat.y, -vecBChat.x), halfWidth), vecC);
           
            
            // find the lines parallel to AB throug A0 and A1 and lines parallel to CB though
            // C0 and C1 - handle infinte slope cases
            if (vecAB.x == 0) {
                // infite slope from A to B
                if (vecBC.x == 0) {
                    // infinite slope from B to C
                    // point B is in the middle of a vertical segment so just offset x for adjacent
                    // points B0 and B1
                    GLfloat B0y = vecB.y;
                    GLfloat B1y = vecB.y;
                    GLfloat B0x;
                    GLfloat B1x;
                    
                    if (vecAB.y < 0) {
                        // point B is below point A
                        B0x = vecB.x + halfWidth;
                        B1x = vecB.x - halfWidth;
                    } else {
                        B0x = vecB.x - halfWidth;
                        B1x = vecB.x + halfWidth;
                    }
                    
                    verts[i*6] = B0x;
                    verts[i*6+1] = B0y;
                    verts[i*6+2] = z;
                    verts[i*6+3] = B1x;
                    verts[i*6+4] = B1y;
                    verts[i*6+5] = z;
                    
                } else {
                    // find equations of lines BC0 and BC1 and use x=A0x,A1x to find intercepts
                    GLfloat slopeBC = vecBC.y / vecBC.x;
                    GLfloat bC0 = vecC0.y - slopeBC * vecC0.x;
                    GLfloat bC1 = vecC1.y - slopeBC * vecC1.x;
                    GLfloat B0x = vecA0.x;
                    GLfloat B1x = vecA1.x;
                    GLfloat B0y = slopeBC * B0x + bC0;
                    GLfloat B1y = slopeBC * B1x + bC1;
                    
                    verts[i*6] = B0x;
                    verts[i*6+1] = B0y;
                    verts[i*6+2] = z;
                    verts[i*6+3] = B1x;
                    verts[i*6+4] = B1y;
                    verts[i*6+5] = z;
                    
                }
                
            } else {
                GLfloat slopeAB = vecAB.y / vecAB.x;
                GLfloat bA0 = vecA0.y - slopeAB * vecA0.x;
                GLfloat bA1 = vecA1.y - slopeAB * vecA1.x;
                if (vecBC.x == 0) {
                    // infinite slope from B to C - use equations of lines A0B, A1B and C0x,C1x
                    GLfloat B0x = vecC0.x;
                    GLfloat B1x = vecC1.x;
                    GLfloat B0y = slopeAB * B0x + bA0;
                    GLfloat B1y = slopeAB * B1x + bA1;
                    
                    verts[i*6] = B0x;
                    verts[i*6+1] = B0y;
                    verts[i*6+2] = z;
                    verts[i*6+3] = B1x;
                    verts[i*6+4] = B1y;
                    verts[i*6+5] = z;

                    
                    
                } else {
                    
                   /* C0x = -vecCBhat.y;
                    C0y = vecCBhat.x;
                    C1x = vecCBhat.y;
                    C1y = -vecCBhat.x;*/
                    GLfloat slopeBC = vecBC.y / vecBC.x;
                    GLfloat bC0 = vecC0.y - slopeBC * vecC0.x;
                    GLfloat bC1 = vecC1.y - slopeBC * vecC1.x;
                    
                    // now find intersection
                    
                    GLfloat B0x = (bC0 - bA0)/(slopeAB - slopeBC);
                    GLfloat B0y = slopeAB * B0x + bA0;
                    
                    
                    GLfloat B1x = (bC1 - bA1)/(slopeAB - slopeBC);
                    GLfloat B1y = slopeAB * B1x + bA1;
                    
                    verts[i*6] = B0x;
                    verts[i*6+1] = B0y;
                    verts[i*6+2] = z;
                    verts[i*6+3] = B1x;
                    verts[i*6+4] = B1y;
                    verts[i*6+5] = z;
                    
                    
                }
   
            }
            
        }
                  
    }
}

@end
