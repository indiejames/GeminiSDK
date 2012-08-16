//
//  LGeminiSystem.m
//  Gemini
//
//  Created by James Norton on 3/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "LGeminiSystem.h"
#import "Gemini.h"

// prototype for library loading function
int luaopen_system_lib (lua_State *L);

static int getTimer(lua_State *L){
    double time = [NSDate timeIntervalSinceReferenceDate];
    time = 1000.0 * (time - [Gemini shared].initTime);
    lua_pushnumber(L, time);
    return 1;
}

static int getResourceDirectory(lua_State *L){
    NSString * resourcePath = [[NSBundle mainBundle] resourcePath];
    lua_pushstring(L, [resourcePath UTF8String]);
    
    return 1;
}

static int systemIndex(lua_State *L){
    int rval = 0;
    if (lua_isstring(L, -1)) {
            
        const char *key = lua_tostring(L, -1);
        if (strcmp("ResourceDirectory", key) == 0) {
                
            rval = getResourceDirectory(L);
        } 
    }
    
    return rval;
}

static int getPathForFile(lua_State *L){
    const char *fileNameCStr = lua_tostring(L, 1);
    const char *dirCStr = lua_tostring(L, 2);
    
    NSString *fileNameStr = [NSString stringWithUTF8String:fileNameCStr];
    NSString *dirStr = [[NSBundle mainBundle] resourcePath];
    if (dirCStr) {
        dirStr = [NSString stringWithUTF8String:dirCStr];
        
    } 
    
    NSString *baseName = [fileNameStr stringByDeletingPathExtension];
    NSString *extension = [fileNameStr pathExtension];
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:baseName ofType:extension];
    
    lua_pushstring(L, [filePath UTF8String]);
    
    return 1;
}

static const struct luaL_Reg system_f [] = {
    {"getTimer", getTimer},
    {"pathForFile", getPathForFile},
    {"__index", systemIndex},
    {NULL, NULL}
};


static const struct luaL_Reg system_m [] = {
    {NULL, NULL}
};


int luaopen_system_lib (lua_State *L){
    
    luaL_newmetatable(L, GEMINI_SYSTEM_LUA_KEY);
    
    lua_pushvalue(L, -1); // duplicates the metatable
    
    //lua_setfield(L, -2, "__index"); // make the metatable use itself for __index
    
    luaL_setfuncs(L, system_m, 0);
     
    /////// finished with metatable ///////////
    
    // create the table for this library
    luaL_newlib(L, system_f);
    
    return 1;
}