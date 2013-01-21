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

static int textFieldIndex(lua_State *L){
    
    int rval = 0;
    
    __unsafe_unretained GemNativeTextField **textField = (__unsafe_unretained GemNativeTextField **)luaL_checkudata(L, 1, GEMINI_NATIVE_TEXT_FIELD_LUA_KEY);
    
    if (textField != NULL) {
        if (lua_isstring(L, 2)) {
            
            const char *key = lua_tostring(L, 2);
            if (strcmp("text", key) == 0) {
                const char *txt = [[(*textField).textField text] UTF8String];
                lua_pushstring(L, txt);
                rval = 1;
            } else if (strcmp("font", key) == 0) {
                NSString *fnt = (*textField).textField.font.fontName;
                lua_pushstring(L, [fnt UTF8String]);
                rval = 1;
            } else if (strcmp("fontSize", key) == 0) {
                GLfloat size = (*textField).textField.font.pointSize;
                lua_pushnumber(L, size);
                rval = 1;
            } else if (strcmp("keyboardType", key) == 0) {
                int type = (*textField).textField.keyboardType;
                lua_pushinteger(L, type);
                rval = 1;
            } else if (strcmp("placeholder", key) == 0) {
                const char *placeholder = [(*textField).textField.placeholder UTF8String];
                lua_pushstring(L, placeholder);
                rval = 1;
            } else if (strcmp("name", key) == 0){
                
                const char *name = [(*textField).name UTF8String];
                lua_pushstring(L, name);
                rval = 1;
            } else {
                
                rval = genericIndex(L);
            }
            
        }
        
        
    }
    
    return rval;
}

static GLKVector4 getColorVector(lua_State *L, int index) {
    GLfloat r = luaL_checknumber(L, index);
    GLfloat g = luaL_checknumber(L, index+1);
    GLfloat b = luaL_checknumber(L, index+2);
    GLfloat a = luaL_checknumber(L, index+3);
    
    return GLKVector4Make(r, g, b, a);
}

static int textFieldSetBackgroundColor(lua_State *L){
    __unsafe_unretained GemNativeTextField **textField = (__unsafe_unretained GemNativeTextField **)luaL_checkudata(L, 1, GEMINI_NATIVE_TEXT_FIELD_LUA_KEY);
    
    GLKVector4 color = getColorVector(L, 2);
    [*textField setBackgroundColor:color];
    
    return 0;
}

static int textFieldSetFontColor(lua_State *L){
    __unsafe_unretained GemNativeTextField **textField = (__unsafe_unretained GemNativeTextField **)luaL_checkudata(L, 1, GEMINI_NATIVE_TEXT_FIELD_LUA_KEY);
    
    GLKVector4 color = getColorVector(L, 2);
    
    [*textField setFontColor:color];
    
    return 0;
}

static int takeFocus(lua_State *L){
    __unsafe_unretained GemNativeTextField **textField = (__unsafe_unretained GemNativeTextField **)luaL_checkudata(L, 1, GEMINI_NATIVE_TEXT_FIELD_LUA_KEY);
    [(*textField).textField becomeFirstResponder];
    
    return 0;
                                                          
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
            } else if (strcmp("font", key) == 0) {
                const char *fnt = luaL_checkstring(L, 3);
                [*textField setFont:[NSString stringWithUTF8String:fnt]];
            } else if (strcmp("fontSize", key) == 0) {
                GLfloat size = luaL_checknumber(L, 3);
                [*textField setFontSize:size];
            } else if (strcmp("keyboardType", key) == 0) {
                int type = luaL_checkint(L, 3);
                [*textField setKeyboardType:type];
            } else if (strcmp("placeholder", key) == 0){
                const char *pholder = luaL_checkstring(L, 3);
                NSString *placeholder = [NSString stringWithUTF8String:pholder];
                (*textField).textField.placeholder = placeholder;
            } else if (strcmp("name", key) == 0){
                
                const char *valCStr = lua_tostring(L, 3);
                (*textField).name = [NSString stringWithUTF8String:valCStr];
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
    {"__index", textFieldIndex},
    {"__newindex", textFieldNewIndex},
    {"removeSelf", removeSelf},
    {"delete", genericDelete},
    {"addEventListener", addEventListener},
    {"removeEventListener", removeEventListener},
    {"setFontColor", textFieldSetFontColor},
    {"setBackgroundColor", textFieldSetBackgroundColor},
    {"takeFocus", takeFocus},
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