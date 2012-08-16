//
//  LGeminiObject.h
//  Gemini
//
//  Created by James Norton on 2/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#include "lua.h"
#include "lualib.h"
#include "lauxlib.h"

#define GEMINI_OBJECT_LUA_KEY "GeminiLib.GEMINI_OBJECT_LUA_KEY"

int luaopen_geminiObjectLib (lua_State *L);

