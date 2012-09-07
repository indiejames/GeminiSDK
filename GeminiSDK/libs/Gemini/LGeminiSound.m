//
//  LGeminiSound.m
//  Gemini
//
//  Created by James Norton on 2/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "LGeminiSound.h"
#import "ObjectAL.h"
#import "GemSoundEffect.h"

int luaopen_soundlib (lua_State *L);
NSTimer *timer;


static int newSoundEffect(lua_State *L){
    const char *name = luaL_checkstring(L, 1);
    NSString *sname = [NSString stringWithFormat:@"%s",name];
    [[OALSimpleAudio sharedInstance] preloadEffect:[NSString stringWithFormat:@"%s",name]];
    __unsafe_unretained GemSoundEffect **lse = (__unsafe_unretained GemSoundEffect **)lua_newuserdata(L, sizeof(GemSoundEffect *));
    luaL_getmetatable(L, GEMINI_SOUND_EFFECT_LUA_KEY);
    lua_setmetatable(L, -2);
    GemSoundEffect *se = [[GemSoundEffect alloc] init];
    se.name = sname;
    *lse = se;
    
    return 1;
    
}

static int sound_effect_gc (lua_State *L){
   /* SoundEffect *se = (SoundEffect *)luaL_checkudata(L, 1, "Gemini.sound_effect");
    [[OALSimpleAudio sharedInstance] unloadEffect:se->name];
    NSLog(@"SoundEffect %@ released", se->name);
    [se->name release];*/
    
    return 0;
}

static int playSoundEffect(lua_State *L){
    __unsafe_unretained GemSoundEffect **se = (__unsafe_unretained GemSoundEffect **)luaL_checkudata(L, 1, GEMINI_SOUND_EFFECT_LUA_KEY);
    [[OALSimpleAudio sharedInstance] playEffect:(*se).name];
    
    return 0;
}

static int setCallback(lua_State *L){
    __unsafe_unretained GemSoundEffect **se = (__unsafe_unretained GemSoundEffect **)luaL_checkudata(L, 1, GEMINI_SOUND_EFFECT_LUA_KEY);
    (*se).callback = luaL_ref(L, LUA_REGISTRYINDEX);
    
    return 0;
}

static int fireCallback(lua_State *L){
    /*lua_rawgeti(L, LUA_REGISTRYINDEX, gse.callback);
    lua_pcall(L, 0, 0, 0);*/
    
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
    luaL_newmetatable(L, GEMINI_SOUND_EFFECT_LUA_KEY);
    
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
        
        soundEffects = [[NSMutableArray alloc] initWithCapacity:1];
        
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
    
}

@end
