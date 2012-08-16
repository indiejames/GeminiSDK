//
//  LGeminiPhysics.m
//  Gemini
//
//  Created by James Norton on 5/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "LGeminiPhysics.h"

int luaopen_physics_lib(lua_State *L);

static b2World *world;


static int addBody(lua_State *L){
    GemDisplayObject **displayObj = (GemDisplayObject **)lua_touserdata(L, 1);
    
    b2BodyDef bodyDef;
    
     NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:1];
    NSString *type = @"dynamic";
    
    int numArgs = lua_gettop(L);
    
    for (int i=1; i<numArgs; i++) {
        if (luaL_checkstring(L, i+1)) {
            // type attribute
            type = [NSString stringWithUTF8String:lua_tostring(L, i+1)];
            
        } else {
            // argument is a table - need body element for it
            
            
            lua_pushnil(L);  /* first key */
            while (lua_next(L, 2) != 0) {
                // uses 'key' (at index -2) and 'value' (at index -1)
                
                const char *key = lua_tostring(L, -2);
                if (strcmp(key, "shape") == 0) {
                    // value is a table
                    
                    int ref = luaL_ref(L, LUA_REGISTRYINDEX);
                    [params setObject:[NSNumber numberWithInt:ref] forKey:[NSString stringWithUTF8String:key]];
                } else {
                    
                    double val = lua_tonumber(L, -1);
                    
                    [params setObject:[NSNumber numberWithDouble:val] forKey:[NSString stringWithUTF8String:key]];
                    
                }
                
                /* removes 'value'; keeps 'key' for next iteration */
                lua_pop(L, 1);
            }
            
            
        }

    }
    
        
    
    return 1;
}

static int newIndex(lua_State *L){
    //return genericNewIndex(L);
    return 0;
}

// the mappings for the library functions
static const struct luaL_Reg physicsLib_f [] = {
    {"addBody", addBody},
    {NULL, NULL}
};

// mappings for the body methods
static const struct luaL_Reg physics_m [] = {
    {"__index", genericIndex},
    {"__newindex", newIndex},
    {NULL, NULL}
};


int luaopen_physics_lib (lua_State *L){
    // create meta table for our physics type
    createMetatable(L, GEMINI_PHYSICS_LUA_KEY, physics_m);
       
    // create the table for this library and popuplate it with our functions
    luaL_newlib(L, physicsLib_f);
    
    b2Vec2 gravity(0.0f, -9.8f); 
    bool doSleep = true;
    world = new b2World(gravity);
    world->SetAllowSleeping(doSleep);
    
    b2BodyDef groundBodyDef; 
    groundBodyDef.position.Set(0.0f, -10.0f);
    
    b2Body* groundBody = world->CreateBody(&groundBodyDef);
    
    b2PolygonShape groundBox; 
    groundBox.SetAsBox(50.0f, 10.0f);
    
    groundBody->CreateFixture(&groundBox, 0.0f);
    
    return 1;
}

