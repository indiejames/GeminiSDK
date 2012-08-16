//
//  LGeminiSound.m
//  Gemini
//
//  Created by James Norton on 2/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "LGeminiSound.h"
#import "ObjectAL.h"

int luaopen_soundlib (lua_State *L);
NSTimer *timer;

typedef struct SoundEffect {
    NSString *name;
    int callback;
} SoundEffect;

SoundEffect gse;

static int newSoundEffect(lua_State *L){
    const char *name = luaL_checkstring(L, 1);
    NSString *sname = [NSString stringWithFormat:@"%s",name];
    [[OALSimpleAudio sharedInstance] preloadEffect:[NSString stringWithFormat:@"%s",name]];
    SoundEffect *se = (SoundEffect *)lua_newuserdata(L, sizeof(SoundEffect));
    se->name = [sname retain];
    
    luaL_getmetatable(L, "Gemini.sound_effect");
    lua_setmetatable(L, -2);
    
    return 1;
    
}

static int sound_effect_gc (lua_State *L){
    SoundEffect *se = (SoundEffect *)luaL_checkudata(L, 1, "Gemini.sound_effect");
    [[OALSimpleAudio sharedInstance] unloadEffect:se->name];
    NSLog(@"SoundEffect %@ released", se->name);
    [se->name release];
    
    return 0;
}

static int playSoundEffect(lua_State *L){
    SoundEffect *se = (SoundEffect *)luaL_checkudata(L, 1, "Gemini.sound_effect");
    [[OALSimpleAudio sharedInstance] playEffect:se->name];
    
    return 0;
}

static int setCallback(lua_State *L){
    SoundEffect *se = (SoundEffect *)luaL_checkudata(L, 1, "Gemini.sound_effect");
    se->callback = luaL_ref(L, LUA_REGISTRYINDEX);
    gse = *se;
    
    return 0;
}

static int fireCallback(lua_State *L){
    lua_rawgeti(L, LUA_REGISTRYINDEX, gse.callback);
    lua_pcall(L, 0, 0, 0);
    
    return 0;
}

static const struct luaL_Reg soundlib_f [] = {
    {"new", newSoundEffect},
    {NULL, NULL}
};

static const struct luaL_Reg soundlib_m [] = {
    {"play", playSoundEffect},
    {"set_callback", setCallback},
    {NULL, NULL}
};

int luaopen_soundlib (lua_State *L){
    luaL_newmetatable(L, "Gemini.sound_effect");
    
    lua_pushvalue(L, -1); // duplicates the metatable
    
    lua_setfield(L, -2, "__index");
    luaL_setfuncs(L, soundlib_m, 0);
    
    lua_pushstring(L,"__gc");
    lua_pushcfunction(L, sound_effect_gc);
    lua_settable(L, -3);
    
    luaL_newlib(L, soundlib_f);
    
    return 1;
}


@implementation LuaSound

-(void)runLoop:(id) sender {
    fireCallback(L);
}

-(id) init:(lua_State *)ls {
    
    self = [super init];
    if(self){
        // Object AL init
        // We don't want ipod music to keep playing since
        // we have our own bg music.
        [OALSimpleAudio sharedInstance].allowIpod = NO;
        
        // Mute all audio if the silent switch is turned on.
        [OALSimpleAudio sharedInstance].honorSilentSwitch = YES;
        
        L = ls;
        
        timer = [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(runLoop:) userInfo:nil repeats:YES];
        
    }
    
    return self;
}

-(void)dealloc {
    // Stop all music and sound effects.
    [[OALSimpleAudio sharedInstance] stopEverything];   
    
    // Unload all sound effects and bg music so that it doesn't fill
    // memory unnecessarily.
    [[OALSimpleAudio sharedInstance] unloadAllEffects];
    
    [super dealloc];
}

@end
