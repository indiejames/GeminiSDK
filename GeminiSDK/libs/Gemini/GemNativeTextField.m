//
//  GemNativeTextField.m
//  GeminiSDK
//
//  Created by James Norton on 1/10/13.
//
//

#import "GemNativeTextField.h"

@implementation GemNativeTextField {
    UITextField *textField;
}

@synthesize textField;

-(id)initWithLuaState:(lua_State *)luaState Frame:(CGRect)frame {
    self = [super initWithLuaState:luaState LuaKey:GEMINI_NATIVE_TEXT_FIELD_LUA_KEY];
    
    if (self) {
        textField = [[UITextField alloc] initWithFrame:frame];
        textField.backgroundColor = [UIColor redColor];
        textField.delegate = self;
        self.nativeObject = textField;
    }
    
    return self;
}



@end
