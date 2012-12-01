//
//  GeminiRectangle.h
//  Gemini
//
//  Created by James Norton on 5/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GemDisplayObject.h"
#import "GemShape.h"
#import "GemLine.h"

#define GEMINI_RECTANGLE_LUA_KEY "GeminiLib.GEMINI_RECTANGLE_LUA_KEY"

@interface GemRectangle : GemShape {
    
}




-(id) initWithLuaState:(lua_State *)luaState X:(GLfloat)x Y:(GLfloat)y Width:(GLfloat)width Height:(GLfloat)height;


@end
