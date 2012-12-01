//
//  LGeminiLuaSupport.h
//  Gemini
//
//  Created by James Norton on 5/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#ifdef __cplusplus
extern "C" {
#endif

#include "lua.h"
#include "lualib.h"
#include "lauxlib.h"
#import "GemObject.h"
#import "GemDisplayObject.h"
#import "GemDisplayGroup.h"

void callLuaMethodForDisplayObject(lua_State *L, int methodRef, GemDisplayObject *obj);
void createMetatable(lua_State *L, const char *key, const struct luaL_Reg *funcs);
int genericIndex(lua_State *L);
int genericNewIndex(lua_State *L);
int genericGeminiDisplayObjectIndex(lua_State *L, GemDisplayObject *obj);
int genericGemDisplayGroupIndex(lua_State *L, GemDisplayGroup *obj);
int genericGemDisplayObjecNewIndex(lua_State *L, GemDisplayObject __unsafe_unretained **obj);
int removeSelf(lua_State *L);
int genericDelete(lua_State *L);
int genericGC(lua_State *L);
int isObjectTouching(lua_State *L);
void setDefaultValues(lua_State *L);
void setupObject(lua_State *L, const char *luaKey, GemObject *obj);

void lockLuaLock();
void unlockLuaLock();

#ifdef __cplusplus
}
#endif