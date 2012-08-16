//
//  LGeminiDisplay.m
//  Gemini
//
//  Created by James Norton on 3/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "LGeminiDisplay.h"
#import "Gemini.h"
#import "GemDisplayGroup.h"

#import "GemLine.h"
#import "GemRectangle.h"
#import "GemGLKViewController.h"
#import "LGeminiLuaSupport.h"




///////////// rectangles //////////////////////
static int newRectangle(lua_State *L){
   // NSLog(@"Creating new rectangle");
    GLfloat x = luaL_checknumber(L, 1);
    GLfloat y = luaL_checknumber(L, 2);
    GLfloat width = luaL_checknumber(L, 3);
    GLfloat height = luaL_checknumber(L, 4);

    GemRectangle *rect = [[GemRectangle alloc] initWithLuaState:L X:x Y:y Width:width Height:height];
    [((GemGLKViewController *)([Gemini shared].viewController)).renderer addObject:rect];
    GemRectangle **lRect = (GemRectangle **)lua_newuserdata(L, sizeof(GemRectangle *));
    *lRect = rect;
    
    setupObject(L, GEMINI_RECTANGLE_LUA_KEY, rect);
    
    //rect.x = width / 2.0;
    //rect.y = height / 2.0;
    rect.width = width;
    rect.height = height;
    
    return 1;
}

static int rectangleGC (lua_State *L){
    //NSLog(@"rectangleGC called");
    GemRectangle  **rect = (GemRectangle **)luaL_checkudata(L, 1, GEMINI_RECTANGLE_LUA_KEY);
    [(*rect).parent remove:*rect];
    //[*rect release];
    
    return 0;
}

static int rectangleIndex(lua_State *L){
    int rval = 0;
    GemRectangle  **rect = (GemRectangle **)luaL_checkudata(L, 1, GEMINI_RECTANGLE_LUA_KEY);
    if (rect != NULL) {
        if (lua_isstring(L, -1)) {
            
            
            const char *key = lua_tostring(L, -1);
            if (strcmp("strokeWidth", key) == 0) {
                
                GLfloat w = (*rect).strokeWidth;
                lua_pushnumber(L, w);
                return 1;
            } else {
                rval = genericGeminiDisplayObjectIndex(L, *rect);
            }
        }
        
        
    }
    
    return rval;
}

static int rectangleNewIndex (lua_State *L){
    int rval = 0;
    GemRectangle  **rect = (GemRectangle **)luaL_checkudata(L, 1, GEMINI_RECTANGLE_LUA_KEY);
    
    if (rect != NULL) {
        if (lua_isstring(L, 2)) {
            
            
            const char *key = lua_tostring(L, 2);
            if (strcmp("strokeWidth", key) == 0) {
                GLfloat w = luaL_checknumber(L, 3);
                (*rect).strokeWidth = w;
                rval = 0;
            } else {
                //lua_pushstring(L, key);
                rval = genericGemDisplayObjecNewIndex(L, rect);
            }

        }
        
        
    }
    
    
    return rval;
}

static int rectangleSetFillColor(lua_State *L){
    //NSLog(@"Setting rectangle fill color");
    int numargs = lua_gettop(L);
    
    GemRectangle  **rect = (GemRectangle **)luaL_checkudata(L, 1, GEMINI_RECTANGLE_LUA_KEY);
    
    GLfloat red = luaL_checknumber(L, 2);
    GLfloat green = luaL_checknumber(L, 3);
    GLfloat blue = luaL_checknumber(L, 4);
    GLfloat alpha = 1.0;
    if (numargs == 5) {
        alpha = luaL_checknumber(L, 5);
    }
    
    (*rect).fillColor = GLKVector4Make(red, green, blue, alpha);
    
    
    return 0;
}

static int rectangleSetStrokeColor(lua_State *L){
    //NSLog(@"Setting rectangle stroke color");
    int numargs = lua_gettop(L);
    
    GemRectangle  **rect = (GemRectangle **)luaL_checkudata(L, 1, GEMINI_RECTANGLE_LUA_KEY);
    
    GLfloat red = luaL_checknumber(L, 2);
    GLfloat green = luaL_checknumber(L, 3);
    GLfloat blue = luaL_checknumber(L, 4);
    GLfloat alpha = 1.0;
    if (numargs == 5) {
        alpha = luaL_checknumber(L, 5);
    }
    
    (*rect).strokeColor = GLKVector4Make(red, green, blue, alpha);
    
    
    return 0;
}

static int rectangleSetStrokeWidth(lua_State *L){
    //NSLog(@"Setting rectangle stroke width");
   
    GemRectangle  **rect = (GemRectangle **)luaL_checkudata(L, 1, GEMINI_RECTANGLE_LUA_KEY);
    
    GLfloat w = luaL_checknumber(L, 2);
        
    (*rect).strokeWidth = w;
    
    
    return 0;
}


///////////// lines ///////////////////////////
static int newLine(lua_State *L){
    //NSLog(@"Creating new line...");
    GLfloat x1 = luaL_checknumber(L, 1);
    GLfloat y1 = luaL_checknumber(L, 2);
    GLfloat x2 = luaL_checknumber(L, 3);
    GLfloat y2 = luaL_checknumber(L, 4);
    
    GemLine *line = [[GemLine alloc] initWithLuaState:L X1:x1 Y1:y1 X2:x2 Y2:y2];
    [((GemGLKViewController *)([Gemini shared].viewController)).renderer addObject:line];
    GemLine **lLine = (GemLine **)lua_newuserdata(L, sizeof(GemLine *)); 
    *lLine = line;
    
    setupObject(L, GEMINI_LINE_LUA_KEY, line);
    
    line.xOrigin = x1;
    line.yOrigin = y1;

    
    return 1;
}

static int lineGC (lua_State *L){
    //NSLog(@"lineGC called");
    GemLine  **line = (GemLine **)luaL_checkudata(L, 1, GEMINI_LINE_LUA_KEY);
    [(*line).parent remove:*line];
    //[*line release];
    
    return 0;
}


static int lineIndex(lua_State *L){
    int rval = 0;
    GemLine  **line = (GemLine **)luaL_checkudata(L, 1, GEMINI_LINE_LUA_KEY);
    if (line != NULL) {
        
        rval = genericGeminiDisplayObjectIndex(L, *line);
        
    }
    
    return rval;
}

static int lineNewIndex (lua_State *L){
    GemLine  **line = (GemLine **)luaL_checkudata(L, 1, GEMINI_LINE_LUA_KEY);
    return genericGemDisplayObjecNewIndex(L, line);
}

static int lineSetColor(lua_State *L){
    //NSLog(@"Setting line color");
    int numargs = lua_gettop(L);
    
    GemLine  **line = (GemLine **)luaL_checkudata(L, 1, GEMINI_LINE_LUA_KEY);
    
    GLfloat red = luaL_checknumber(L, 2);
    GLfloat green = luaL_checknumber(L, 3);
    GLfloat blue = luaL_checknumber(L, 4);
    GLfloat alpha = 1.0;
    if (numargs == 5) {
        alpha = luaL_checknumber(L, 5);
    }
    (*line).color = GLKVector4Make(red, green, blue, alpha);
    
    return 0;
}

static int lineAppendPoints(lua_State *L){
    //NSLog(@"Appending points to line");
    int numargs = lua_gettop(L);
    
    GemLine  **line = (GemLine **)luaL_checkudata(L, 1, GEMINI_LINE_LUA_KEY);
    
    GLfloat *newPoints = (GLfloat *)malloc((numargs - 1)*sizeof(GLfloat));
    
    for (int i=0; i<(numargs - 1)/2; i++) {
        *(newPoints + i*2) = luaL_checknumber(L, i*2 + 2);
        *(newPoints + i*2 + 1) = luaL_checknumber(L, i*2 + 3);
    }
    
    [*line append:(numargs - 1)/2 Points:newPoints];
    
    free(newPoints);
    
    return 0;
}

///////////// layers //////////////////
static int newLayer(lua_State *L){
    int index = luaL_checkinteger(L, 1);
    
    GemLayer *layer = [[GemLayer alloc] initWithLuaState:L];
    layer.index = index;
    GemLayer **lLayer = (GemLayer **)lua_newuserdata(L, sizeof(GemLayer *));
    *lLayer = layer;
    GemRenderer *renderer = ((GemGLKViewController *)([Gemini shared].viewController)).renderer;
    [renderer addLayer:layer];

    setupObject(L, GEMINI_LAYER_LUA_KEY, layer);
    
    return 1;
}

static int layerGC (lua_State *L){
    GemLayer  **layer = (GemLayer **)luaL_checkudata(L, 1, GEMINI_LAYER_LUA_KEY);
    
    [*layer release];
    
    return 0;
}

GemLayer *createLayerZero(lua_State *L) {
    GemLayer *layer = [[GemLayer alloc] initWithLuaState:L];
    layer.index = 0;
    GemLayer **lLayer = (GemLayer **)lua_newuserdata(L, sizeof(GemLayer *));
    *lLayer = layer;
    
    //GeminiRenderer *renderer = ((GeminiGLKViewController *)([Gemini shared].viewController)).renderer;
    //[renderer addLayer:layer];

    setupObject(L, GEMINI_LAYER_LUA_KEY, layer);
    
    // add layer zero to the global vars for Lua
    lua_setglobal(L, "GEMINI_LAYER0");
    
    return layer;
}

static int layerNewIndex (lua_State *L){
    GemLayer  **layer = (GemLayer **)luaL_checkudata(L, 1, GEMINI_LAYER_LUA_KEY);
    return genericGemDisplayObjecNewIndex(L, layer);
}


static int layerInsert(lua_State *L){
    //NSLog(@"Calling layerInsert()");
    GemLayer  **layer = (GemLayer **)luaL_checkudata(L, 1, GEMINI_LAYER_LUA_KEY); 
    GemDisplayObject **displayObj = (GemDisplayObject **)lua_touserdata(L, 2);
    [*layer insert:*displayObj];
    
    return 0;
}

static int layerSetBlendFunc(lua_State *L){
    //NSLog(@"Calling layerSetBlendFunc()");
    GemLayer  **layer = (GemLayer **)luaL_checkudata(L, 1, GEMINI_LAYER_LUA_KEY); 
    GLenum srcBlend = luaL_checkinteger(L, 2);
    GLenum destBlend = luaL_checkinteger(L, 3);
    [*layer setBlendFuncSource:srcBlend Dest:destBlend];
    
    return 0;
}

///////////// display groups //////////////////
static int newDisplayGroup(lua_State *L){
    GemDisplayGroup *group = [[GemDisplayGroup alloc] initWithLuaState:L];
    GemDisplayGroup **lGroup = (GemDisplayGroup **)lua_newuserdata(L, sizeof(GemDisplayGroup *));
    *lGroup = group;
   [((GemGLKViewController *)([Gemini shared].viewController)).renderer addObject:group];

    setupObject(L, GEMINI_DISPLAY_GROUP_LUA_KEY, group);
    
    return 1;
}

static int displayGroupGC (lua_State *L){
    GemDisplayGroup  **group = (GemDisplayGroup **)luaL_checkudata(L, 1, GEMINI_DISPLAY_GROUP_LUA_KEY);
    
    [*group release];
    
    return 0;
}

static int displayGroupIndex(lua_State *L){
    GemDisplayGroup  **dgp = (GemDisplayGroup **)luaL_checkudata(L, 1, GEMINI_DISPLAY_GROUP_LUA_KEY);
    GemDisplayGroup *dg = *dgp;
    if (lua_isnumber(L, -1)) {
        // groups can be indexed using bracket [] notation to get contained display objects
        int index = lua_tointeger(L, -1) - 1;
        
        if (dg == nil) {
            NSLog(@"Disply group is nil");
        }
        
       // NSLog(@"Retrieving object at index %d from display group %@", index, dg.name);
        if (index < 0 || index >= [dg.objects count]) {
            // index outside of allowable range returns nil instead of throwing exception
            lua_pushnil(L);
        } else {
            GemDisplayObject *obj = (GemDisplayObject *)[dg.objects objectAtIndex:index];
            
            int ref = obj.selfRef;
            lua_rawgeti(L, LUA_REGISTRYINDEX, ref);
        }
        
        return 1;
    } else if (lua_isstring(L, -1)) {
        const char *key = lua_tostring(L, -1);
        //NSLog(@"key = %s", key);
        if (strcmp("numChildren", key) == 0) {
            
            unsigned int numChildren = dg.numChildren;
            lua_pushinteger(L, numChildren);
            return 1;
        } else {
            return genericGeminiDisplayObjectIndex(L, dg);
        }
    } 
    
    return 0;
    
}


static int displayGroupNewIndex (lua_State *L){
    GemDisplayGroup  **dg = (GemDisplayGroup **)luaL_checkudata(L, 1, GEMINI_DISPLAY_GROUP_LUA_KEY);
    return genericGemDisplayObjecNewIndex(L, dg);
}

static int displayGroupInsert(lua_State *L){
     //NSLog(@"Calling displayGroupInsert()");
    int stackSize = lua_gettop(L);
    
    if (stackSize > 2) {
        
        GemDisplayGroup  **group = (GemDisplayGroup **)luaL_checkudata(L, 1, GEMINI_DISPLAY_GROUP_LUA_KEY); 
        int insertionIndex = luaL_checkint(L, 2) - 1;
        GemDisplayObject **displayObj = (GemDisplayObject **)lua_touserdata(L, 3);
        [*group insert:*displayObj atIndex:insertionIndex];
        
    } else {
        GemDisplayGroup  **group = (GemDisplayGroup **)luaL_checkudata(L, 1, GEMINI_DISPLAY_GROUP_LUA_KEY); 
        GemDisplayObject **displayObj = (GemDisplayObject **)lua_touserdata(L, 2);
        [*group insert:*displayObj];
        
    }
    
    
    return 0;
}

static int displayGroupRemove(lua_State *L){
    
    GemDisplayGroup  **group = (GemDisplayGroup **)luaL_checkudata(L, 1, GEMINI_DISPLAY_GROUP_LUA_KEY); 
    
    GemDisplayObject **displayObj = (GemDisplayObject **)lua_touserdata(L, 2);
    [*group remove:*displayObj];
    
    return 0;
}


// the mappings for the library functions
static const struct luaL_Reg displayLib_f [] = {
    {"newLayer", newLayer},
    {"newGroup", newDisplayGroup},
    {"newLine", newLine},
    {"newRect", newRectangle},
    {NULL, NULL}
};

// mappings for the layer methods
static const struct luaL_Reg layer_m [] = {
    {"insert", layerInsert},
    {"setBlendFunc", layerSetBlendFunc},
    {"__gc", layerGC},
    {"__index", genericIndex},
    {"__newindex", layerNewIndex},
    // TODO - add remove self for layers (can't call generic method)
    {NULL, NULL}
};

// mappings for the display group methods
static const struct luaL_Reg displayGroup_m [] = {
    {"insert", displayGroupInsert},
    {"remove", displayGroupRemove},
    {"removeSelf", removeSelf},
    {"__gc", displayGroupGC},
    {"__index", displayGroupIndex},
    {"__newindex", displayGroupNewIndex},
    {NULL, NULL}
};

// mappings for the line methods
static const struct luaL_Reg line_m [] = {
    {"__gc", lineGC},
    {"__index", lineIndex},
    {"__newindex", lineNewIndex},
    {"removeSelf", removeSelf},
    {"setColor", lineSetColor},
    {"append", lineAppendPoints},
    {NULL, NULL}
};

// mappings for the rectangle methods
static const struct luaL_Reg rectangle_m [] = {
    {"__gc", rectangleGC},
    {"__index", rectangleIndex},
    {"__newindex", rectangleNewIndex},
    {"setFillColor", rectangleSetFillColor},
    {"setStrokeColor", rectangleSetStrokeColor},
    {"setStrokeWidth", rectangleSetStrokeWidth},
    {"removeSelf", removeSelf},
    {NULL, NULL}
};


int luaopen_display_lib (lua_State *L){
    // create meta tables for our various types /////////
    
    // layers
    createMetatable(L, GEMINI_LAYER_LUA_KEY, layer_m);
    
    // display groups
    createMetatable(L, GEMINI_DISPLAY_GROUP_LUA_KEY, displayGroup_m);
   
    
    // lines
    createMetatable(L, GEMINI_LINE_LUA_KEY, line_m);
   
    // rectangles
    createMetatable(L, GEMINI_RECTANGLE_LUA_KEY, rectangle_m);
    
    /////// finished with metatables ///////////
    
    // create the table for this library and popuplate it with our functions
    luaL_newlib(L, displayLib_f);
    
    return 1;
}