//
//  LGeminiSystem.m
//  Gemini
//
//  Created by James Norton on 3/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "LGeminiSystem.h"
#import "Gemini.h"

// prototype for library loading function
int luaopen_system_lib (lua_State *L);

static int getTimer(lua_State *L){
    double time = [NSDate timeIntervalSinceReferenceDate];
    time = 1000.0 * (time - [Gemini shared].initTime);
    lua_pushnumber(L, time);
    return 1;
}

static int getResourceDirectory(lua_State *L){
    NSString * resourcePath = [[NSBundle mainBundle] resourcePath];
    lua_pushstring(L, [resourcePath UTF8String]);
    
    return 1;
}

static int systemIndex(lua_State *L){
    int rval = 0;
    if (lua_isstring(L, -1)) {
            
        const char *key = lua_tostring(L, -1);
        if (strcmp("ResourceDirectory", key) == 0) {
                
            rval = getResourceDirectory(L);
        } 
    }
    
    return rval;
}

static int getPathForFile(lua_State *L){
    const char *fileNameCStr = lua_tostring(L, 1);
    const char *dirCStr = lua_tostring(L, 2);
    
    NSString *fileNameStr = [NSString stringWithUTF8String:fileNameCStr];
    NSString *dirStr = [[NSBundle mainBundle] resourcePath];
    if (dirCStr) {
        dirStr = [NSString stringWithUTF8String:dirCStr];
        
    } 
    
    NSString *baseName = [fileNameStr stringByDeletingPathExtension];
    NSString *extension = [fileNameStr pathExtension];
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:baseName ofType:extension];
    
    lua_pushstring(L, [filePath UTF8String]);
    
    return 1;
}

static int screenshot(lua_State *L){
    GLKViewController *viewController = [Gemini shared].viewController;
    GLKView *view = (GLKView *)viewController.view;
    
    UIImage *image = [view snapshot];
    NSString *pngPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/screenshot.png"];
    [UIImagePNGRepresentation(image) writeToFile:pngPath atomically:YES];
    
    return 0;
}

static int listSystemFonts(lua_State *L){
    NSArray *familyNames = [UIFont familyNames];
    
    // create a table to hold the output
    // the list of familty names are the keys and the font names for each
    // family name will be the values (sub tables)
    lua_newtable(L);
    
    for (int i=0; i<[familyNames count]; i++) {
        NSString *familyName = [familyNames objectAtIndex:i];
        
        // this will be the key for the main table
        lua_pushstring(L, [familyName UTF8String]);
        
        NSArray *fontNames = [UIFont fontNamesForFamilyName:familyName];
        lua_newtable(L);
        for (int j=0; j<[fontNames count]; j++) {
            NSString *fontName = [fontNames objectAtIndex:j];
            // add the font name as a value in the table
            lua_pushstring(L, [fontName UTF8String]);
            lua_rawseti(L, -2, j+1);
        }
        
        // add the sub table to the main table
        lua_rawset(L, -3);

    }
    
    return 1;
}

static const struct luaL_Reg system_f [] = {
    {"getTimer", getTimer},
    {"pathForFile", getPathForFile},
    {"screenshot", screenshot},
    {"listSystemFonts", listSystemFonts},
    {"__index", systemIndex},
    {NULL, NULL}
};


static const struct luaL_Reg system_m [] = {
    {NULL, NULL}
};


int luaopen_system_lib (lua_State *L){
    
    luaL_newmetatable(L, GEMINI_SYSTEM_LUA_KEY);
    
    lua_pushvalue(L, -1); // duplicates the metatable
    
    //lua_setfield(L, -2, "__index"); // make the metatable use itself for __index
    
    luaL_setfuncs(L, system_m, 0);
     
    /////// finished with metatable ///////////
    
    // create the table for this library
    luaL_newlib(L, system_f);
    
    return 1;
}