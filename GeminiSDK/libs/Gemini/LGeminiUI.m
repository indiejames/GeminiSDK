//
//  LGeminiUI.m
//  GeminiSDK
//
//  Created by James Norton on 1/10/13.
//
//

#import "LGeminiUI.h"
#import "LGeminiLuaSupport.h"
#import "LGeminiObject.h"
#import "Gemini.h"
#import "GemGLKViewController.h"
#import "GemNativeTextField.h"

static int newNativeTextField(lua_State *L){
    
    GLfloat x = luaL_checknumber(L, -4);
    GLfloat y = luaL_checknumber(L, -3);
    GLfloat width = luaL_checknumber(L, -2);
    GLfloat height = luaL_checknumber(L, -1);
    
    CGRect frame = CGRectMake(x, y, width, height);
    GemNativeTextField *textField = [[GemNativeTextField alloc] initWithLuaState:L Frame:frame];
    [[Gemini shared].viewController.view addSubview:textField.textField];
    [((GemGLKViewController *)[Gemini shared].viewController).displayObjectManager addObject:textField];
   // [[((GemGLKViewController *)([Gemini shared].viewController)).director getDefaultScene] addObject:textField];
    
    return 1;
}

static int textFieldNewIndex(lua_State *L){
    
    int rval = 0;
    
    __unsafe_unretained GemNativeTextField **textField = (__unsafe_unretained GemNativeTextField **)luaL_checkudata(L, 1, GEMINI_NATIVE_TEXT_FIELD_LUA_KEY);
    
    if (textField != NULL) {
        if (lua_isstring(L, 2)) {
            
            const char *key = lua_tostring(L, 2);
            if (strcmp("text", key) == 0) {
                const char *txt = luaL_checkstring(L, 3);
                (*textField).textField.text = [NSString stringWithUTF8String:txt];
                rval = 0;
            } else {
                
                rval = genericNewIndex(L);
            }
            
        }
        
        
    }
    
    return rval;
}


static const struct luaL_Reg UILib_f [] = {
    
    {"newTextField", newNativeTextField},
    {NULL, NULL}
};

// mappings for the text field methods
static const struct luaL_Reg native_text_field_m [] = {
    {"__gc", genericGC},
    {"__index", genericIndex},
    {"__newindex", textFieldNewIndex},
    {"removeSelf", removeSelf},
    {"delete", genericDelete},
    {"addEventListener", addEventListener},
    {"removeEventListener", removeEventListener},
    {NULL, NULL}
};


int luaopen_UI_lib (lua_State *L) {
    // create meta tables for our various types /////////
    
    // text fields
    createMetatable(L, GEMINI_NATIVE_TEXT_FIELD_LUA_KEY, native_text_field_m);
       
    /////// finished with metatables ///////////
    
    // create the table for this library and popuplate it with our functions
    luaL_newlib(L, UILib_f);
    
    return 1;
}