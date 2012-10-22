//
//  GemCircle.h
//  GeminiSDK
//
//  Created by James Norton on 10/15/12.
//
//

#import "GemShape.h"

#define GEMINI_CIRCLE_LUA_KEY "GeminiLib.GEM_CIRCLE_LUA_KEY"

@interface GemCircle : GemShape

@property GLfloat radius;

-(id) initWithLuaState:(lua_State *)luaState X:(GLfloat)x0 Y:(GLfloat)y0 Radius:(GLfloat)rad;


@end
