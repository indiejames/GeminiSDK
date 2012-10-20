//
//  GemCircle.h
//  GeminiSDK
//
//  Created by James Norton on 10/15/12.
//
//

#import "GemDisplayObject.h"

#define GEMINI_CIRCLE_LUA_KEY "GeminiLib.GEM_CIRCLE_LUA_KEY"

@interface GemCircle : GemDisplayObject

@property GLfloat radius;
@property (readonly) GLfloat *verts;
@property (readonly) GLfloat *vertColor;
@property (readonly) GLushort *vertIndex;
@property (nonatomic) GLKVector4 fillColor;
@property (nonatomic) GLKVector4 *gradient;
@property (nonatomic) GLKVector4 strokeColor;
@property (nonatomic) GLfloat strokeWidth;
@property (readonly) GLuint numTriangles;

-(id) initWithLuaState:(lua_State *)luaState X:(GLfloat)x0 Y:(GLfloat)y0 Radius:(GLfloat)rad;
-(unsigned int)vertexCount;
-(unsigned int)indexCount;

@end
