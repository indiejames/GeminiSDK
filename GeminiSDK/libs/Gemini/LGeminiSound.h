//
//  LGeminiSound.h
//  Gemini
//
//  Created by James Norton on 2/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "lua.h"
#include "lualib.h"
#include "lauxlib.h"

#define GEMINI_SOUND_EFFECT_LUA_KEY "GeminiLib.GEMINI_SOUND_EFFECT_KEY"

@interface LuaSound : NSObject {
    lua_State *L;
    NSMutableArray *soundEffects;
}

-(id) init:(lua_State *)L;

@end
