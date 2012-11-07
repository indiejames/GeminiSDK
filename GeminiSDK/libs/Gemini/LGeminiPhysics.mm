//
//  LGeminiPhysics.m
//  Gemini
//
//  Created by James Norton on 5/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "LGeminiPhysics.h"
#import "Gemini.h"



static int addBody(lua_State *L){
    __unsafe_unretained GemDisplayObject **displayObj = (__unsafe_unretained GemDisplayObject **)lua_touserdata(L, 1);
    
    GemLog(@"Adding physics to %@", (*displayObj).name);
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:1];
    NSMutableDictionary *fixtureDefs = [NSMutableDictionary dictionaryWithCapacity:1];
    [params setObject:fixtureDefs forKey:@"fixtures"];
    
    NSString *type = @"static";
    
    int numArgs = lua_gettop(L);
    
    for (int i=1; i<numArgs; i++) {
        if (lua_isstring(L, i+1)) {
            // type attribute
            type = [NSString stringWithUTF8String:lua_tostring(L, i+1)];
            
        } else {
            // argument is a table - iterate over keys/vals to add to configuration for fixtures
            
            NSMutableDictionary *fixtureDef = [[NSMutableDictionary alloc] initWithCapacity:1];
            NSString *fixtureId = @"ANONYMOUS";
            
            lua_pushnil(L);  /* first key */
            while (lua_next(L, i+1) != 0) {
                // 'key' (at index -2) and 'value' (at index -1)
                
                const char *key = lua_tostring(L, -2);
                if (strcmp(key, "shape") == 0) {
                    // value is a table
                    
                    NSMutableArray *shape = [NSMutableArray arrayWithCapacity:1];
                    [fixtureDef setObject:shape forKey:[NSString stringWithUTF8String:key]];
                    
                    // iterate over the table and copy its values
                    lua_pushnil(L);
                    while (lua_next(L, -2) != 0) {
                        double value = lua_tonumber(L, -1);
                        [shape addObject:[NSNumber numberWithDouble:value]];
                        // removes 'value'; keeps 'key' for next iteration
                        lua_pop(L, 1);
                    }
                } else if (strcmp(key, "filter") == 0){
                    // value is a table
                    NSMutableDictionary *filter = [NSMutableDictionary dictionaryWithCapacity:3];
                    [fixtureDef setObject:filter forKey:@"filter"];
                    // iterate over table keys/values
                    lua_pushnil(L);
                    while (lua_next(L, -2) != 0) {
                        const char *filterKey = lua_tostring(L, -2);
                        unsigned int value = lua_tounsigned(L, -1);
                        [filter setObject:[NSNumber numberWithUnsignedInt:value] forKey:[NSString stringWithUTF8String:filterKey]];
                        // remove the value but leave the key for the next iteration
                        lua_pop(L, 1);
                    }
                } else if (strcmp(key, "pe_fixture_id") == 0){
                    const char *fixId = lua_tostring(L, -1);
                    fixtureId = [NSString stringWithUTF8String:fixId];
                } else if (strcmp(key, "position") == 0) {
                    // value is a table
                    
                    NSMutableArray *position = [NSMutableArray arrayWithCapacity:2];
                    [fixtureDef setObject:position forKey:[NSString stringWithUTF8String:key]];
                    
                    // iterate over the table and copy its values
                    lua_pushnil(L);
                    while (lua_next(L, -2) != 0) {
                        double value = lua_tonumber(L, -1);
                        [position addObject:[NSNumber numberWithDouble:value]];
                        // removes 'value'; keeps 'key' for next iteration
                        lua_pop(L, 1);
                    }
                } else if (strcmp(key, "isSensor") == 0){
                    bool isSensor = lua_toboolean(L, -1);
                    [fixtureDef setObject:[NSNumber numberWithBool:isSensor] forKey:@"isSensor"];
                } else {
                    // handle float values like density, friction, etc.
                    double val = lua_tonumber(L, -1);
                    
                    [fixtureDef setObject:[NSNumber numberWithDouble:val] forKey:[NSString stringWithUTF8String:key]];
                    
                }
                
                // removes 'value'; keeps 'key' for next iteration
                lua_pop(L, 1);
            }
            
            [fixtureDefs setObject:fixtureDef forKey:fixtureId];
        }

    }
    
    [params setObject:type forKey:@"type"];
    
    GemDisplayObject *gdo = *displayObj;
    
    [[Gemini shared].physics addBodyForObject:gdo WithParams:params];
    
    
    return 0;
}

static int setScale(lua_State *L){
    double scale = lua_tonumber(L, 1);
    [[Gemini shared].physics setScale:scale];
    
    return 0;
}

static int setDrawMode(lua_State *L){
    int mode = lua_tointeger(L, 1);
    [[Gemini shared].physics setDrawMode:(GemPhysicsDrawMode)mode];
    
    return 0;
}

static int setContinuous(lua_State *L){
    bool cont = lua_toboolean(L, 1);
    [[Gemini shared].physics setContinous:cont];
    
    return 0;
}

static int pause(lua_State *L){
    [[Gemini shared].physics pause];
    
    return 0;
}

static int start(lua_State *L){
    [[Gemini shared].physics start];
    
    return 0;
}

static int setGravity(lua_State *L){
    
    float gx = lua_tonumber(L, 1);
    float gy = lua_tonumber(L, 2);
    [[Gemini shared].physics setGravityGx:gx Gy:gy];
    
    return 0;
}


static int newIndex(lua_State *L){
    //return genericNewIndex(L);
    return 0;
}

// the mappings for the library functions
static const struct luaL_Reg physicsLib_f [] = {
    {"addBody", addBody},
    {"setScale", setScale},
    {"setContinuous", setContinuous},
    {"setDrawMode", setDrawMode},
    {"setGravity", setGravity},
    {"pause", pause},
    {"start", start},
    {NULL, NULL}
};

// mappings for the body methods
static const struct luaL_Reg physics_m [] = {
    {"__index", genericIndex},
    {"__newindex", newIndex},
    {NULL, NULL}
};


extern "C" int luaopen_physics_lib (lua_State *L){
    // create meta table for our physics type
    //createMetatable(L, GEMINI_PHYSICS_LUA_KEY, physics_m);
       
    // create the table for this library and popuplate it with our functions
    luaL_newlib(L, physicsLib_f);
    
    
    return 1;
}

