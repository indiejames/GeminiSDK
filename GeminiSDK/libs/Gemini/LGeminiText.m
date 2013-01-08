//
//  LGeminiText.m
//  GeminiSDK
//
//  Created by James Norton on 1/4/13.
//
//

#import "LGeminiText.h"
#import "GemCharSet.h"
#import "GemText.h"
#import "LGeminiLuaSupport.h"
#import "LGeminiObject.h"
#import "Gemini.h"
#import "GemGLKViewController.h"

static int newCharSet(lua_State *L){
    
    const char *name = luaL_checkstring(L, -2);
    const char *filename = luaL_checkstring(L, -1);
    
    int err;
    
    GemLog(@"Gem: Loading font %s", filename);
    
    // set our error handler function
    lua_pushcfunction(L, traceback);
    
    GemFileNameResolver *resolver = [Gemini shared].fileNameResolver;
    
    NSString *resolvedFileName = [resolver resolveNameForFile:[NSString stringWithUTF8String:filename] ofType:@"lua"];
    
    NSString *luaFilePath = [[NSBundle mainBundle] pathForResource:resolvedFileName ofType:@"lua"];
    
    err = luaL_loadfile(L, [luaFilePath cStringUsingEncoding:[NSString defaultCStringEncoding]]);
    
    if (0 != err) {
        luaL_error(L, "LUA ERROR: cannot load lua file: %s",
                   lua_tostring(L, -1));
        return -1;
    }
    
    
    err = lua_pcall(L, 0, 1, 1);
    if (0 != err) {
        luaL_error(L, "LUA ERROR: cannot run lua file: %s",
                   lua_tostring(L, -1));
        return -1;
    }
    
    // the table for the charset should be on the top of the stack
    NSDictionary *fontParams = tableToDictionary(L, -1);
    GemCharSet *charSet = [[GemCharSet alloc] initWithLuaState:L fontInfo:fontParams];
    [[Gemini shared].fontManager addFont:[NSString stringWithUTF8String:name] withCharset:charSet];
    
    return 1;
}

static int charSetNewIndex(lua_State *L){
    
    int rval = 0;
    
    __unsafe_unretained GemCharSet **charSet = (__unsafe_unretained GemCharSet **)luaL_checkudata(L, 1, GEMINI_CHARSET_LUA_KEY);
    
    if (charSet != NULL) {
        if (lua_isstring(L, 2)) {
            
            const char *key = lua_tostring(L, 2);
            if (strcmp("scale", key) == 0) {
                GLfloat scale = luaL_checknumber(L, 3);
                (*charSet).scale = scale;
                rval = 0;
            } else {
                
                rval = genericNewIndex(L);
            }
            
        }
        
        
    }
    
    return rval;
}


///// text objects

static int newText(lua_State *L){
    const char *fontName = luaL_checkstring(L, -2);
    const char *content = luaL_checkstring(L, -1);
    GemText *text = [[GemText alloc] initWithLuaState:L font:[NSString stringWithUTF8String:fontName]];
    [[((GemGLKViewController *)([Gemini shared].viewController)).director getDefaultScene] addObject:text];
    text.text = [NSString stringWithUTF8String:content];
    
    return 1;
}

static int textIndex(lua_State *L){
    int rval = 0;
    __unsafe_unretained GemText  **text = (__unsafe_unretained GemText **)luaL_checkudata(L, 1, GEMINI_TEXT_LUA_KEY);
    if (text != NULL) {
        if (lua_isstring(L, -1)) {
            
            
            const char *key = lua_tostring(L, -1);
            if (strcmp("text", key) == 0) {
                
                const char *txt = [(*text).text UTF8String];
                lua_pushstring(L, txt);
                return 1;
            } else {
                rval = genericGeminiDisplayObjectIndex(L, *text);
            }
        }
        
        
    }
    
    return rval;
}

static int textNewIndex (lua_State *L){
    int rval = 0;
    __unsafe_unretained GemText  **text = (__unsafe_unretained GemText **)luaL_checkudata(L, 1, GEMINI_TEXT_LUA_KEY);
    
    if (text != NULL) {
        if (lua_isstring(L, 2)) {
            
            const char *key = lua_tostring(L, 2);
            if (strcmp("text", key) == 0) {
                const char *txt = luaL_checkstring(L, 3);
                (*text).text = [NSString stringWithUTF8String:txt];
                rval = 0;
            } else {
                
                rval = genericGemDisplayObjecNewIndex(L, text);
            }
            
        }
        
        
    }
    
    
    return rval;
}


static const struct luaL_Reg textLib_f [] = {
    {"newCharset", newCharSet},
    {"newText", newText},
    {NULL, NULL}
};

// mappings for the character set methods
static const struct luaL_Reg charset_m [] = {
    {"__gc", genericGC},
    {"__index", genericIndex},
    {"__newindex", charSetNewIndex},
    {"removeSelf", removeSelf},
    {"delete", genericDelete},
    {"addEventListener", addEventListener},
    {"removeEventListener", removeEventListener},
    {NULL, NULL}
};

// mappings for the text object methods
static const struct luaL_Reg textobject_m [] = {
    {"__gc", genericGC},
    {"__index", textIndex},
    {"__newindex", textNewIndex},
    {"removeSelf", removeSelf}, // TODO - these two need to be implemented to handle scaling, etc.
    {"delete", genericDelete},
    {"addEventListener", addEventListener},
    {"removeEventListener", removeEventListener},
    {NULL, NULL}
};

int luaopen_text_lib (lua_State *L) {
    // create meta tables for our various types /////////
    
    // character sets
    createMetatable(L, GEMINI_CHARSET_LUA_KEY, charset_m);
    
    // text objects
    createMetatable(L, GEMINI_TEXT_LUA_KEY, textobject_m);
    
    /////// finished with metatables ///////////
    
    // create the table for this library and popuplate it with our functions
    luaL_newlib(L, textLib_f);
    
    return 1;
}