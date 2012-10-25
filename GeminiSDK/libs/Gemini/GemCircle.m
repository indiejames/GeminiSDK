//
//  GemCircle.m
//  GeminiSDK
//
//  Created by James Norton on 10/15/12.
//
//

#import "GemCircle.h"

#define GEM_SLICE_TOLERANCE (300.0/160.0)

@implementation GemCircle


-(id) initWithLuaState:(lua_State *)luaState X:(GLfloat)x0 Y:(GLfloat)y0 Radius:(GLfloat)rad {
    self = [super initWithLuaState:luaState LuaKey:GEMINI_CIRCLE_LUA_KEY];
    
    if (self) {
        self.xOrigin = x0;
        self.yOrigin = y0;
        self.xReference = 0;
        self.yReference = 0;
        self.radius = rad;
        gradient = 0;
        
        verts = (GLfloat *)malloc(30*3*sizeof(GLfloat));
        vertColor = (GLfloat *)malloc(30*4*sizeof(GLfloat));
        vertIndex = (GLushort *)malloc(30*sizeof(GLushort));
        self.strokeWidth = 0;
        
        needsUpdate = YES;
        
        [self computeVertices];
        
        [self setStrokeColor:GLKVector4Make(1.0, 1.0, 1.0, 1.0)];
        [self setFillColor:GLKVector4Make(1.0, 1.0, 1.0, 1.0)];
    }
    
    return self;
}

-(void)dealloc {
   
    free(verts);
    free(vertIndex);
    free(vertColor);
    if (gradient != 0) {
        free(gradient);
    }
}

/*-(void)setLayer:(GemLayer *)_layer {
    [super setLayer:_layer];
}*/

/*-(void)setStrokeColor:(GLKVector4)sColor {
    unsigned int numSlices = [self numSlices];
    int numInnerVerts = numSlices + 1;
    int numVerts = 3 * numSlices + 1;
    
    strokeColor = sColor;
    
    if (self.strokeWidth > 0) {
        for (int i=numInnerVerts; i<numVerts; i++) {
            vertColor[i*4] = sColor.r;
            vertColor[i*4+1] = sColor.g;
            vertColor[i*4+2] = sColor.b;
            vertColor[i*4+3] = sColor.a;
        }
    }
    
}

-(GLKVector4)strokeColor {
    return strokeColor;
}

-(void)setFillColor:(GLKVector4)fill {
    unsigned int numSlices = [self numSlices];
    unsigned int numVerts = numSlices + 1;
    
    fillColor = fill;
    for (int i=0; i<numVerts; i++) {
        vertColor[i*4] = fill.r;
        vertColor[i*4+1] = fill.g;
        vertColor[i*4+2] = fill.b;
        vertColor[i*4+3] = fill.a;
    }
}

-(GLKVector4)fillColor {
    return fillColor;
}*/

// always pass in two colors, one for center and one for edge
-(void)setGradient:(GLKVector4 *)grad {
    unsigned int numSlices = [self numSlices];
    unsigned int numVerts = numSlices + 1;
    if (gradient == 0) {
        gradient = (GLKVector4 *)malloc(2*sizeof(GLKVector4));
    }
    memcpy(gradient, grad, 2*sizeof(GLKVector4));
    
    // set the center vertex to the first color
    vertColor[0] = grad[0].r;
    vertColor[1] = grad[0].g;
    vertColor[2] = grad[0].b;
    vertColor[3] = grad[0].a;
    
    // set the outer vertices to the second color
    for (int i=1; i<numVerts; i++) {
        vertColor[i*4] = grad[1].r;
        vertColor[i*4+1] = grad[1].g;
        vertColor[i*4+2] = grad[1].b;
        vertColor[i*4+3] = grad[1].a;
    }
    
}

-(GLKVector4 *)gradient {
    return gradient;
}

/*-(GLfloat *)verts {
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
}*/

/*-(unsigned int) vertexCount {
    unsigned int numSlices = [self numSlices];
    unsigned int numVerts = numSlices + 1;
    if (self.strokeWidth > 0) {
        numVerts = numVerts + numSlices * 2;
    }
    
    return numVerts;
}*/

-(GLuint)vertCount {
    GLuint vCount = [super vertCount];
    return vCount;
}

-(GLuint)vertIndexCount {
    unsigned int numSlices = [self numSlices];
    unsigned int indexCount = 2 * numSlices + 4;
    if (self.strokeWidth > 0) {
        indexCount = indexCount + numSlices * 2 + 4;
    }
    
    return indexCount;
}

-(GLuint)numSlices {
    int numSlices = self.radius * GEM_SLICE_TOLERANCE;
    if (numSlices > 150) {
        numSlices = 150;
    }
    // TEST
    //numSlices = 8;
    return numSlices;
}


-(void)computeVertices {
    // TODO - make this more efficient by only computing one quadrant and using that to compute the other three, thus
    // avoiding unnecessary calls to sin/cos.
    if (needsUpdate) {
        
        unsigned int numSlices = [self numSlices];
        int numVerts = numSlices + 1;
        numInnerlVerts = numVerts;
        if (self.strokeWidth > 0) {
            numVerts = numVerts + numSlices * 2;
            numBorderVerts = numSlices * 2;
        }
        
        unsigned int numIndex = [self vertIndexCount];
        
        verts = realloc(verts, numVerts * 3 * sizeof(GLfloat));
        vertIndex = realloc(vertIndex, numIndex * sizeof(GLushort));
        vertColor = realloc(vertColor, numVerts * 4 * sizeof(GLfloat));
        
        // inner portion
        verts[0] = 0; // verts are centered on (0,0) - we rely on the tranformation to move to actual (x,y)
        verts[1] = 0;

        verts[2] = 1.0; // homogeneous coordinates
        
        unsigned int indexPtr = 0;
        
        vertIndex[indexPtr++] = 0; // repeat the first and last indices to make it easy to use one draw call for all circles
                          // via degenerate triangles
        
        
        for (int i=0; i<numSlices; i++) {
            GLfloat theta = i * 2*M_PI / (GLfloat)numSlices;
            verts[(i+1)*3] = verts[0] + self.radius * cos(theta);
            verts[(i+1)*3+1] = verts[1] + self.radius * sin(theta);
            verts[(i+1)*3+2] = 1.0;
        }
        
        for (int i=0; i<numSlices/2; i++) {
            
            vertIndex[indexPtr++] = 0;
            vertIndex[indexPtr++] = i*2+1;
            vertIndex[indexPtr++] = i*2+2;
            vertIndex[indexPtr++] = i*2+2; // duplicate point for degen triangle
            
        }
        
        vertIndex[indexPtr++] = 0;
        vertIndex[indexPtr++] = 1;
        vertIndex[indexPtr++] = 1; // add a redundant index to support degenerate triangles for bulk rendering

        
        if (self.strokeWidth > 0) {
            // border portion
            GLfloat innerRadius = self.radius;
            GLfloat outerRadius = self.radius + self.strokeWidth;
            for (int i=0; i<numSlices; i++) {
                GLfloat theta = i * 2*M_PI / (GLfloat)numSlices;
                
                verts[i*6 + (numSlices + 1)*3] = verts[0] + innerRadius * cos(theta);
                verts[i*6 + (numSlices + 1)*3 + 1] = verts[1] + innerRadius * sin(theta);
                verts[i*6 + (numSlices + 1)*3 + 2] = 1.0;
                verts[i*6 + (numSlices + 1)*3 + 3] = verts[0] + outerRadius * cos(theta);
                verts[i*6 + (numSlices + 1)*3 + 4] = verts[1] + outerRadius * sin(theta);
                verts[i*6 + (numSlices + 1)*3 + 5] = 1.0;
                vertIndex[indexPtr++] = i*2 + numSlices + 1;
                if (i==0) {
                    // duplicate first point to support use of degenerate triangles
                    vertIndex[indexPtr++] = i*2 + numSlices + 1;
                }
                vertIndex[indexPtr++] = i*2 + numSlices + 2;
            }
            
            vertIndex[indexPtr++] = numSlices + 1;
            vertIndex[indexPtr++] = numSlices + 2;

            vertIndex[indexPtr++] = numSlices + 2; // duplicate the last point for degenerate triangles
            
            /*for (int i=0; i<numInnerlVerts; i++) {
                GLfloat x = verts[i*3];
                GLfloat y = verts[i*3+1];
                GemLog(@"(x,y) = (%f,%f)", x,y);
            }
            
            for (int i=0; i<numBorderVerts; i++) {
                GLfloat x = verts[(i+numInnerlVerts)*3];
                GLfloat y = verts[(i+numInnerlVerts)*3+1];
                GemLog(@"(x,y) = (%f,%f)", x,y);
            }
            
            for (int i=0; i<indexPtr;i++) {
                GLushort idx = vertIndex[i];
                GemLog(@"index[%d] = %d", i, idx); 
            }*/

        }

    }
    
           
    needsUpdate = NO;
}

-(BOOL)doesContainPoint:(GLKVector2)point {
    GLfloat distSq = (point.x - self.x) * (point.x - self.x) + (point.y - self.y) * (point.y - self.y);
    if (distSq <= self.radius * self.radius) {
        return YES;
    }

    return NO;
}

@end
