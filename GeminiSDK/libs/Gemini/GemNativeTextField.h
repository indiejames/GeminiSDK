//
//  GemNativeTextField.h
//  GeminiSDK
//
//  Created by James Norton on 1/10/13.
//
//

#import "GemNativeObject.h"
#define GEMINI_NATIVE_TEXT_FIELD_LUA_KEY "GeminiLib.GEMINI_NATIVE_TEXT_FIELD_LUA_KEY"

@interface GemNativeTextField : GemNativeObject <UITextFieldDelegate>
@property (readonly) UITextField *textField;

-(id)initWithLuaState:(lua_State *)luaState Frame:(CGRect)frame;
-(void)setFont:(NSString *)fontName;
-(void)setFontSize:(CGFloat)size;
-(void)setKeyboardType:(int)type;
-(void)setFontColor:(GLKVector4)color;
-(void)setBackgroundColor:(GLKVector4)color;

@end
