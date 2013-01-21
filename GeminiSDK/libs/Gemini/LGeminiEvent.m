//
//  LGeminiEvent.m
//  Gemini
//
//  Created by James Norton on 7/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "LGeminiEvent.h"
#import "GemEvent.h"
#import "GemCollisionEvent.h"
#import "GemEventManager.h"
#import "GemGLKViewController.h"
#import "Gemini.h"
#import "GemTouchEvent.h"
#import "LGeminiLuaSupport.h"

int luaopen_event_lib(lua_State *L);

static int eventIndex(lua_State *L){
    int rval = 0;
    __unsafe_unretained GemEvent  **event = (__unsafe_unretained GemEvent **)lua_touserdata(L, 1);
    if (event != NULL) {
        if (lua_isstring(L, -1)) {
            
            
            const char *key = lua_tostring(L, -1);
            if (strcmp("name", key) == 0) {
                NSString *name = (*event).name;
                lua_pushstring(L, [name UTF8String]);
                
                rval = 1;
            } else if(strcmp("target", key) == 0) {
                GemObject *target = (*event).target;
                lua_rawgeti(L, LUA_REGISTRYINDEX, target.selfRef);
                
                rval = 1;
            } else {
                rval = genericIndex(L);
            }
        } else {
            rval = genericIndex(L);
        }
        
        
    } else {
        GemLog(@"Event is null");
    }
    
    return rval;
}

static int setFocus(lua_State *L){
    __unsafe_unretained GemEvent  **event = (__unsafe_unretained GemEvent **)luaL_checkudata(L, 1, GEMINI_EVENT_LUA_KEY);
    __unsafe_unretained GemDisplayObject **displayObj = (__unsafe_unretained GemDisplayObject **)lua_touserdata(L, 2);
    
    GemEventManager *eventManager = ((GemGLKViewController *)([Gemini shared].viewController)).eventManager;
    [eventManager setTouchFocus:*displayObj forEvent:*event];

    
    return 0;
}

static int removeFocus(lua_State *L){
    __unsafe_unretained GemEvent  **event = (__unsafe_unretained GemEvent **)luaL_checkudata(L, 1, GEMINI_EVENT_LUA_KEY);
     GemEventManager *eventManager = ((GemGLKViewController *)([Gemini shared].viewController)).eventManager;
    [eventManager removeTouchFocus:*event];
    
    return 0;
}

// collision events

static int collisionEventIndex(lua_State *L){
    int rval = 0;
    __unsafe_unretained GemCollisionEvent  **event = (__unsafe_unretained GemCollisionEvent **)luaL_checkudata(L, 1, GEM_COLLISION_EVENT_LUA_KEY);
    if (event != NULL) {
        if (lua_isstring(L, -1)) {
            
            
            const char *key = lua_tostring(L, -1);
            if (strcmp("phase", key) == 0) {
               
                char *phaseStr = "";
                
                GemCollisionPhase phase = (*event).phase;
                switch (phase) {
                    case GEM_COLLISION_PRESOLVE:
                        phaseStr = "presolve";
                        break;
                    case GEM_COLLISION_POSTSOLVE:
                        phaseStr = "postsolve";
                        break;
                    
                    default:
                        break;
                }
                
                lua_pushstring(L, phaseStr);
                
                rval = 1;
                
            } else if(strcmp("source", key) == 0) {
                GemObject *source = (*event).source;
                lua_rawgeti(L, LUA_REGISTRYINDEX, (*event).source.selfRef);
                
                rval = 1;
            } else {
                rval = eventIndex(L);
            }
        } else {
            rval = genericIndex(L);
        }
        
        
    }
    
    return rval;

}

// touch events
static int touchEventIndex(lua_State *L){
    int rval = 0;
    __unsafe_unretained GemTouchEvent  **event = (__unsafe_unretained GemTouchEvent **)luaL_checkudata(L, 1, GEM_TOUCH_EVENT_LUA_KEY);
    if (event != NULL) {
        if (lua_isstring(L, -1)) {
            
            const char *key = lua_tostring(L, -1);
            if (strcmp("phase", key) == 0) {
                
                char *phaseStr = "";
                
                GemTouchPhase phase = ((GemTouchEvent *)(*event)).phase;
                switch (phase) {
                    case GEM_TOUCH_BEGAN:
                        phaseStr = "began";
                        break;
                    case GEM_TOUCH_ENDED:
                        phaseStr = "ended";
                        break;
                    case GEM_TOUCH_MOVED:
                        phaseStr = "moved";
                        break;
                    case GEM_TOUCH_CANCELLED:
                        phaseStr = "cancelled";
                        break;
                    default:
                        break;
                }
                
                lua_pushstring(L, phaseStr);
                
                rval = 1;
                
            } else if (strcmp("x", key) == 0) {
                
                float x = (*event).x;
                
                lua_pushnumber(L, x);
                
                rval = 1;
                
            } else if (strcmp("y", key) == 0) {
                
                float y = (*event).y;
                
                lua_pushnumber(L, y);
                
                rval = 1;
                
            } else {
                rval = eventIndex(L);
            }
        } else {
            rval = genericIndex(L);
        }
        
        
    }
    
    return rval;
    
}


// mappings for the event methods
static const struct luaL_Reg event_m [] = {
    {"__index", eventIndex},
    {"setFocus", setFocus},
    {"removeFocus", removeFocus},
    {NULL, NULL}
};

// mappings for collision event methods
static const struct luaL_Reg collision_event_m [] = {
    {"__index", collisionEventIndex},
    {NULL, NULL}
};

// mappings for touch event methods
static const struct luaL_Reg touch_event_m [] = {
    {"__index", touchEventIndex},
    {NULL, NULL}
};


int luaopen_event_lib (lua_State *L){
    // create meta table for our generic event type
    createMetatable(L, GEMINI_EVENT_LUA_KEY, event_m);
    
    // collision events
    createMetatable(L, GEM_COLLISION_EVENT_LUA_KEY, collision_event_m);
    
    // touch events
    createMetatable(L, GEM_TOUCH_EVENT_LUA_KEY, touch_event_m);
    
    return 0;
}
