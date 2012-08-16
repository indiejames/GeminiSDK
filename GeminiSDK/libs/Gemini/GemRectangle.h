//
//  GeminiRectangle.h
//  Gemini
//
//  Created by James Norton on 5/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GemDisplayObject.h"
#import "GemLine.h"

@interface GemRectangle : GemDisplayObject {
    GLfloat *verts;
    GLfloat *vertColor;
    GLushort *vertIndex;
    GLKVector2 *points;
    GLKVector4 fillColor;
    GLKVector4 *gradient;
    GLKVector4 strokeColor;
    GemLine *border;
    GLfloat strokeWidth;
}

@property (readonly) GLfloat *verts;
@property (readonly) GLfloat *vertColor;
@property (readonly) GLushort *vertIndex;
@property (nonatomic) GLKVector4 fillColor;
@property (nonatomic) GLKVector4 *gradient;
@property (nonatomic) GLKVector4 strokeColor;
@property (nonatomic) GLfloat strokeWidth;
@property (readonly) GLuint numTriangles;


-(id) initWithLuaState:(lua_State *)luaState X:(GLfloat)x Y:(GLfloat)y Width:(GLfloat)width Height:(GLfloat)height;


@end
