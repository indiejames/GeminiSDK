//
//  GemConvexShape.h
//  GeminiSDK
//
//  Created by James Norton on 11/7/12.
//
//

#import "GemShape.h"

#define GEMINI_CONVEX_SHAPE_LUA_KEY "GEMINI_CONVEX_SHAPE"

@interface GemConvexShape : GemShape

-(id) initWithLuaState:(lua_State *)luaState Points:(GLfloat *)points NumPoints:(unsigned int)numPoints;
@end
