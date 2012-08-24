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

static int newScene(lua_State *L){
    NSLog(@"Creating new scene");
    
    GemScene *scene = [[GemScene alloc] initWithLuaState:L defaultLayerIndex:0];
    
    GemScene **lscene = (GemScene **)lua_newuserdata(L, sizeof(GemScene *));
    *lscene = scene;
    
    setupObject(L, GEMINI_SCENE_LUA_KEY, scene);
    
    return 1;
}

static int sceneGC (lua_State *L){
    //NSLog(@"lineGC called");
    GemScene  **scene = (GemScene **)luaL_checkudata(L, 1, GEMINI_SCENE_LUA_KEY);
    //[(*line).parent remove:*line];
   
    
    return 0;
}


static int sceneIndex(lua_State *L){
    int rval = 0;
    GemScene  **scene = (GemScene **)luaL_checkudata(L, 1, GEMINI_SCENE_LUA_KEY);
    if (scene != NULL) {
        
        rval = genericGeminiDisplayObjectIndex(L, *scene);
        
    }
    
    return rval;
}

static int sceneNewIndex (lua_State *L){
    GemScene  **scene = (GemScene **)luaL_checkudata(L, 1, GEMINI_SCENE_LUA_KEY);
    return genericGemDisplayObjecNewIndex(L, scene);
}

static int addLayerToScene(lua_State *L){
    NSLog(@"Adding layer to scene");
    GemScene  **scene = (GemScene **)luaL_checkudata(L, 1, GEMINI_SCENE_LUA_KEY);
    GemLayer **layer = (GemLayer **)luaL_checkudata(L, 2, GEMINI_LAYER_LUA_KEY);
    [*scene addLayer:*layer];
}

static int directorLoadScene(lua_State *L){
    NSLog(@"Loading scene");
    const char *sceneName = luaL_checkstring(L, 1);
    NSString *sceneNameStr = [NSString stringWithUTF8String:sceneName];
    [((GemGLKViewController *)[Gemini shared].viewController).director loadScene:sceneNameStr];
    
    return 0;
}

static int directorGotoScene(lua_State *L){
    NSLog(@"Going to scene");
    const char *sceneName = luaL_checkstring(L, 1);
    NSString *sceneNameStr = [NSString stringWithUTF8String:sceneName];
    [((GemGLKViewController *)[Gemini shared].viewController).director gotoScene:sceneNameStr withOptions:nil];
    
    return 0;
}

// the mappings for the library functions
static const struct luaL_Reg directorLib_f [] = {
    {"newScene", newScene},
    {"loadScene", directorLoadScene},
    {"gotoScene", directorGotoScene},
    {NULL, NULL}
};

// mappings for the scene methods
static const struct luaL_Reg scene_m [] = {
    {"__gc", sceneGC},
    {"__index", sceneIndex},
    {"__newindex", sceneNewIndex},
    {"addLayer", addLayerToScene},
    {"addEventListener", addEventListener},
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