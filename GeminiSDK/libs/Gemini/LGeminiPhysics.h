//
//  LGeminiPhysics.h
//  Gemini
//
//  Created by James Norton on 5/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//


#define GEMINI_PHYSICS_LUA_KEY "GeminiLib.GEMINI_PHYSICS_LUA_KEY"

#ifdef __cplusplus
extern "C" {
#endif
    
#include "lua.h"
#include "lualib.h"
#include "lauxlib.h"

    
    int applyForce(lua_State *L);
    int applyLinearImpulse(lua_State *L);
    int setLinearVelocity(lua_State *L);

#ifdef __cplusplus
}
#endif