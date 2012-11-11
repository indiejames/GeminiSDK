//
//  GemConvexShape.m
//  GeminiSDK
//
//  Created by James Norton on 11/7/12.
//
//

#import "GemConvexShape.h"

@interface GemConvexShape () {
    GLfloat *points;
    unsigned int numPoints;
}

@end

@implementation GemConvexShape

-(id)initWithLuaState:(lua_State *)luaState Points:(GLfloat *)pts NumPoints:(unsigned int)nPoints {
    self = [super initWithLuaState:luaState LuaKey:GEMINI_CONVEX_SHAPE_LUA_KEY];
    if (self) {
        numPoints = nPoints;
        points = pts;
        verts = (GLfloat *)malloc(3*numPoints*sizeof(GLfloat));
        vertIndex = (GLushort *)malloc(numPoints*sizeof(GLushort));
        vertColor = (GLfloat *)malloc(4*numPoints * sizeof(GLfloat));
        numInnerlVerts = numPoints;
        
        self.strokeWidth = 0;
        
        needsUpdate = YES;
        
        [self computeVertices];
        
        // default to white polys
        [self setFillColor:GLKVector4Make(1.0, 1.0, 1.0, 1.0)];

    }
    
    return self;
}

-(void) dealloc {
    free(points);
    free(verts);
    free(vertIndex);
}

-(GLuint)vertIndexCount {
    // one for each point plus two extra for the redundant verts used for degenerate triangles
    return numPoints+2;
}

-(void) computeVertices {
    GLfloat z = 1; // homogeneous coordinates to allow fast matrix math
    
    verts = (GLfloat *)realloc(verts, numPoints * 3 * sizeof(GLfloat));
    vertIndex = (GLushort *)realloc(vertIndex, [self vertIndexCount]*sizeof(GLushort));
    
    for (int i=0; i<numPoints; i++) {
        verts[i*3] = points[i*2];
        verts[i*3+1] = points[i*2+1];
        verts[i*3+2] = z;
    }
    
    // find point with greatest y value as strarting index, then alternate left and right verts to form triangle strip
    GLfloat maxY = points[1];
    unsigned int maxIndex = 0;
    for (int i=0; i<numPoints; i++) {
        if (points[i*2+1] > maxY){
            maxY = points[i*2+1];
            maxIndex = i;
        }
    }
    
   
    unsigned int indexCount = 0;
    vertIndex[indexCount++] = maxIndex;
    vertIndex[indexCount++] = maxIndex;
    int offset = -1;
    while (indexCount < [self vertIndexCount]) {
        int index = maxIndex + offset;
        if (index < 0) {
            index = numPoints + index;
        } else if (index > numPoints - 1){
            index = index - numPoints;
        }
        
        vertIndex[indexCount++] = index;
        if (offset < 0) {
            offset = -offset;
        } else {
            offset = -offset - 1;
        }
        if (indexCount == [self vertIndexCount]) {
            vertIndex[indexCount] = index;
        }
        
    }


}

@end
