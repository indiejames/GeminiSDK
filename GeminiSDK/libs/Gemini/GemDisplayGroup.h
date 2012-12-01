//
//  GeminiDisplayGroup.h
//  Gemini
//
//  Created by James Norton on 3/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GemDisplayObject.h"

#define GEMINI_DISPLAY_GROUP_LUA_KEY "GeminiLib.GEMINI_DISPLAY_GROUP_LUA_KEY"

@interface GemDisplayGroup : GemDisplayObject {
    NSMutableArray *objects;
}

@property (readonly) NSArray *objects;
@property (readonly) unsigned int numChildren;

-(id)initWithLuaState:(lua_State *)luaState;
-(id)initWithLuaState:(lua_State *)luaState LuaKey:(const char *)luaKey;
-(void)remove:(GemDisplayObject *) obj;
-(void)recomputeWidthHeight;
-(void)insert:(GemDisplayObject *) obj;
-(void)insert:(GemDisplayObject *)obj atIndex:(int)indx;

@end
