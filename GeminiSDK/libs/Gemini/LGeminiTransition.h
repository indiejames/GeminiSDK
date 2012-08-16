//
//  LGeminiTransition.h
//  Gemini
//
//  Created by James Norton on 5/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#include "LGeminiLuaSupport.h"

#define GEMINI_TRANSITION_LUA_KEY "GeminiLib.GEMINI_TRANSITION_LUA_KEY"

void callOnStartForDisplayObject(lua_State *L, int methodRef, GemDisplayObject *obj);
void callOnCompleteForDisplayObject(lua_State *L, int methodRef, GemDisplayObject *obj);