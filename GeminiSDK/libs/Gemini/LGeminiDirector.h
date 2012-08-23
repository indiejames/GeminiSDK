//
//  LGeminiDirector.h
//  GeminiSDK
//
//  Created by James Norton on 8/22/12.
//
//

#include "lua.h"
#include "lualib.h"
#include "lauxlib.h"

#define GEMINI_DIRECTOR_LUA_KEY "GeminiLib.GEMINI_DIRECTOR_LUA_KEY"
#define GEMINI_SCENE_LUA_KEY "GeminiLib.GEMINI_SCENE_LUA_KEY"

int luaopen_director_lib (lua_State *L);