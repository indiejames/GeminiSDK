//
//  LGeminiParticleSystem.m
//
//  Created by James Norton on 12/6/12.
//
//

#import "GemParticleSystem.h"
#import "GemGLKViewController.h"
#import "Gemini.h"
#import "GemSpriteSheet.h"
#import "LGeminiLuaSupport.h"

// particle emitters
static int newParticleEmmiter(lua_State *L){
    
    const char *filename = luaL_checkstring(L, 1);
    __unsafe_unretained GemSpriteSheet  **sps = (__unsafe_unretained GemSpriteSheet **)luaL_checkudata(L, 2, GEMINI_SPRITE_SHEET_LUA_KEY);
    
    GemParticleSystem *ps = [[GemParticleSystem alloc] initWithLuaState:L File:[NSString stringWithUTF8String:filename] SpriteSheet:*sps];
    
    [[((GemGLKViewController *)([Gemini shared].viewController)).director getDefaultScene] addObject:ps];
    
    [((GemGLKViewController *)([Gemini shared].viewController)).particleSystemManager addEmitter:ps];
    
    return 1;
}

static int emitterIndex( lua_State* L ) {
    
    __unsafe_unretained GemParticleSystem  **ps = (__unsafe_unretained GemParticleSystem **)luaL_checkudata(L, 1, GEM_PARTICLE_SYSTEM_LUA_KEY);
    return genericGeminiDisplayObjectIndex(L, *ps);
        
}

static int emitterStart(lua_State *L){
    __unsafe_unretained GemParticleSystem  **gps = (__unsafe_unretained GemParticleSystem **)luaL_checkudata(L, 1, GEM_PARTICLE_SYSTEM_LUA_KEY);
    [*gps start:((GemGLKViewController *)([Gemini shared].viewController)).updateTime];
    
    return 0;
}

static int emitterPause(lua_State *L){
    __unsafe_unretained GemParticleSystem  **gps = (__unsafe_unretained GemParticleSystem **)luaL_checkudata(L, 1, GEM_PARTICLE_SYSTEM_LUA_KEY);
    [*gps pause:((GemGLKViewController *)([Gemini shared].viewController)).updateTime];
    
    return 0;
}

// the mappings for the library functions
static const struct luaL_Reg particle_system_lib_f [] = {
    {"newEmitter", newParticleEmmiter},
    {NULL, NULL}
};

// the mappings for the particle emitter methods
static const struct luaL_Reg emitter_m [] = {
    {"start", emitterStart},
    {"pause", emitterPause},
    {"__index", emitterIndex},
    {NULL, NULL}
};


int luaopen_particle_system_lib (lua_State *L){
    // create meta tables for our various types /////////
    
    // particle emitters
    createMetatable(L, GEM_PARTICLE_SYSTEM_LUA_KEY, emitter_m);

    /////// finished with metatables ///////////
    
    // create the table for this library and popuplate it with our functions
    luaL_newlib(L, particle_system_lib_f);
    
    return 1;
}