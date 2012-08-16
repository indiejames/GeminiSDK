//
//  GeminiLine.h
//  Gemini
//
//  Created by James Norton on 3/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GemDisplayObject.h"

@interface GemLine : GemDisplayObject {
    GLfloat *points;
    unsigned int numPoints;
    GLKVector4 color;
    GLfloat *verts;
    GLushort *vertIndex;
}

@property (readonly) GLfloat *points;
@property (readonly) unsigned int numPoints;
@property (readonly) GLfloat *verts;
@property (readonly) GLushort *vertIndex;
@property (nonatomic) GLKVector4 color;

-(id)initWithLuaState:(lua_State *)luaState X1:(GLfloat)x1 Y1:(GLfloat)y1 X2:(GLfloat)x2 Y2:(GLfloat)y2;
-(id)initWithLuaState:(lua_State *)luaState Parent:(GemDisplayGroup *)prt X1:(GLfloat)x1 Y1:(GLfloat)y1 X2:(GLfloat)x2 Y2:(GLfloat)y2;
-(void)append:(int)count Points:(const GLfloat *)newPoints;
-(void)computeVertices;

@end
