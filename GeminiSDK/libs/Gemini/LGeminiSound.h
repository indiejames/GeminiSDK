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

@interface LuaSound : NSObject {
    lua_State *L;
    int callback;
}

-(id) init:(lua_State *)L;

@end
