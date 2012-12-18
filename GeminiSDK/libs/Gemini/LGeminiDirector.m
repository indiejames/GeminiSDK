//
//  LGeminiDirector.m
//  GeminiSDK
//
//  Created by James Norton on 8/22/12.
//
//

#import "LGeminiDirector.h"
#import "Gemini.h"
#import "GemGLKViewController.h"
#import "GemScene.h"
#import "LGeminiLuaSupport.h"
#import "LGeminiDisplay.h"
#import "LGeminiObject.h"
#import "GLUtils.h"


static int newScene(lua_State *L){
    NSLog(@"Creating new scene");
    
    GemScene *scene = [[GemScene alloc] initWithLuaState:L defaultLayerIndex:0];
    [((GemGLKViewController *)[Gemini shared].viewController).director addScene:scene];
    //__unsafe_unretained GemScene **lscene = (__unsafe_unretained GemScene **)lua_newuserdata(L, sizeof(GemScene *));
    //*lscene = scene;
    
    //setupObject(L, GEMINI_SCENE_LUA_KEY, scene);
    
    return 1;
}

static int sceneGC (lua_State *L){
    //NSLog(@"lineGC called");
   // __unsafe_unretained GemScene  **scene = (__unsafe_unretained GemScene **)luaL_checkudata(L, 1, GEMINI_SCENE_LUA_KEY);
    //[(*line).parent remove:*line];
   
    
    return 0;
}


static int sceneIndex(lua_State *L){
    int rval = 0;
    __unsafe_unretained GemScene  **scene = (__unsafe_unretained GemScene **)luaL_checkudata(L, 1, GEMINI_SCENE_LUA_KEY);
    if (scene != NULL) {
        if (lua_isstring(L, 2)) {
            
            const char *key = lua_tostring(L, 2);
            if (strcmp("zoom", key) == 0) {
                lua_pushnumber(L, (*scene).zoom);
                rval = 1;
            } else {
                rval = genericGeminiDisplayObjectIndex(L, *scene);
            }
            
        } else {
            rval = genericGeminiDisplayObjectIndex(L, *scene);
        }
        
        
    }
    
    return rval;
}

static int sceneNewIndex (lua_State *L){
    int rval = 0;
    __unsafe_unretained GemScene  **scene = (__unsafe_unretained GemScene **)luaL_checkudata(L, 1, GEMINI_SCENE_LUA_KEY);
    if (scene != NULL) {
        if (lua_isstring(L, 2)) {
            
            const char *key = lua_tostring(L, 2);
            if (strcmp("zoom", key) == 0) {
                GLfloat zoom = luaL_checknumber(L, 3);
                if (zoom <= 0) {
                    luaL_error(L, "Lua: ERROR - zoom must be greater than zero");
                } else {
                    (*scene).zoom = zoom;
                }
                rval = 0;
            } else {
                rval = genericGemDisplayObjecNewIndex(L, scene);
            }
            
        } else {
            rval = genericGemDisplayObjecNewIndex(L, scene);
        }


    }
    
    return rval;
}

static int addLayerToScene(lua_State *L){
    __unsafe_unretained GemScene  **scene = (__unsafe_unretained GemScene **)luaL_checkudata(L, 1, GEMINI_SCENE_LUA_KEY);
    __unsafe_unretained GemLayer **layer = (__unsafe_unretained GemLayer **)luaL_checkudata(L, 2, GEMINI_LAYER_LUA_KEY);
    NSLog(@"LGeminiDirector Adding layer %d to scene %@", (*layer).index, (*scene).name);
    [*scene addLayer:*layer];
    
    return 0;
}

static int setSceneZoom(lua_State *L){
    __unsafe_unretained GemScene  **scene = (__unsafe_unretained GemScene **)luaL_checkudata(L, 1, GEMINI_SCENE_LUA_KEY);
    GLfloat zoom = luaL_checknumber(L, -1);
    if (zoom <= 0) {
        luaL_error(L, "Lua: ERROR - zoom must be greater than zero");
    } else {
        (*scene).zoom = zoom;
    }
    
    return 0;
    
}

static int directorLoadScene(lua_State *L){
    
    const char *sceneName = luaL_checkstring(L, 1);
    NSString *sceneNameStr = [NSString stringWithUTF8String:sceneName];
    NSLog(@"Loading scene");
    [((GemGLKViewController *)[Gemini shared].viewController).director loadScene:sceneNameStr];
    
    return 0;
}

static int directorGotoScene(lua_State *L){
    
    const char *sceneName = luaL_checkstring(L, 1);
    NSString *sceneNameStr = [NSString stringWithUTF8String:sceneName];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:1];
    
    if (lua_istable(L, 2)) {
        lua_pushnil(L);  /* first key */
        while (lua_next(L, 2) != 0) {
            /* uses 'key' (at index -2) and 'value' (at index -1) */
            printf("%s - %s\n",
                   lua_typename(L, lua_type(L, -2)),
                   lua_typename(L, lua_type(L, -1)));
            const char *key = lua_tostring(L, -2);
            const char *value = lua_tostring(L, -1);
            [params setObject:[NSString stringWithUTF8String:value] forKey:[NSString stringWithUTF8String:key]];
                        
            /* removes 'value'; keeps 'key' for next iteration */
            lua_pop(L, 1);
        }
    }
    
    [((GemGLKViewController *)[Gemini shared].viewController).director gotoScene:sceneNameStr withOptions:params];
    
    return 0;
}

static int deleteScene(lua_State *L){
    const char *sceneName = luaL_checkstring(L, 1);
    NSString *sceneNameStr = [NSString stringWithUTF8String:sceneName];
    NSLog(@"LGeminiDirector deleting scene %@", sceneNameStr);
    [((GemGLKViewController *)[Gemini shared].viewController).director destroyScene:sceneNameStr];
    
    return 0;
    
}

// the mappings for the library functions
static const struct luaL_Reg directorLib_f [] = {
    {"newScene", newScene},
    {"loadScene", directorLoadScene},
    {"gotoScene", directorGotoScene},
    {"destroyScene", deleteScene},
    {NULL, NULL}
};

// mappings for the scene methods
static const struct luaL_Reg scene_m [] = {
    {"__gc", sceneGC},
    {"__index", sceneIndex},
    {"__newindex", sceneNewIndex},
    {"addLayer", addLayerToScene},
    {"addEventListener", addEventListener},
    {"setZoom", setSceneZoom},
    {NULL, NULL}
};

// the registration function
int luaopen_director_lib (lua_State *L){
    // create meta tables for our various types /////////
    
    // scene
    createMetatable(L, GEMINI_SCENE_LUA_KEY, scene_m);
       
    /////// finished with metatables ///////////
    
    // create the table for this library and popuplate it with our functions
    luaL_newlib(L, directorLib_f);
    
    return 1;
}