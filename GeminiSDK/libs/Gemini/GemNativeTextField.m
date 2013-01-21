//
//  GemNativeTextField.m
//  GeminiSDK
//
//  Created by James Norton on 1/10/13.
//
//

#import "GemNativeTextField.h"
#import "GemEvent.h"
#import "GLUtils.h"

@implementation GemNativeTextField {
    UITextField *textField;
}

@synthesize textField;

-(id)initWithLuaState:(lua_State *)luaState Frame:(CGRect)frame {
    self = [super initWithLuaState:luaState LuaKey:GEMINI_NATIVE_TEXT_FIELD_LUA_KEY];
    
    if (self) {
        
        frame = frameToDeviceFrame(frame);
        
        textField = [[UITextField alloc] initWithFrame:frame];
        textField.delegate = self;
        self.nativeObject = textField;
    }
    
    return self;
}

-(BOOL)textFieldShouldReturn:(UITextField *)tField {
    [tField resignFirstResponder];
    GemEvent *event = [[GemEvent alloc] initWithLuaState:L Target:self];
    event.name = @"enterPressed";
    [self handleEvent:event];
    
    GemLog(@"Text field has text: %@", textField.text);
    
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    GemEvent *event = [[GemEvent alloc] initWithLuaState:L Target:self];
    event.name = @"didEndEditing";
    [self handleEvent:event];
    
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    
    return YES;
}

-(void)setFont:(NSString *)fontName {
    UIFont *font  = textField.font;
    CGFloat size = font.pointSize;
    font = [UIFont fontWithName:fontName size:size];
    textField.font = font;
    
}

-(void)setKeyboardType:(int)type {
    [textField setKeyboardType:type];
}

-(void)setFontSize:(CGFloat)size {
    UIFont *font = textField.font;
    NSString *fontName = font.fontName;
    font = [UIFont fontWithName:fontName size:size];
    textField.font = font;
}

// TODO - implement this functionality so people can move text fields after they have
// been created
-(void)setX:(GLfloat)x {
    /*CGRect frame = textField.frame;
    frame.origin.x = x;
    textField.frame = frame;*/
    [super setX:x];
}

-(void)setY:(GLfloat)y {
    /*CGRect frame = textField.frame;
    frame.origin.y = y;
    textField.frame = frame;*/
    [super setY:y];
}

-(void)setFontColor:(GLKVector4)color {
    UIColor *clr = [UIColor colorWithRed:color.r green:color.g blue:color.b alpha:color.a];
    textField.textColor = clr;
}

-(void)setBackgroundColor:(GLKVector4)color {
    UIColor *clr = [UIColor colorWithRed:color.r green:color.g blue:color.b alpha:color.a];
    textField.backgroundColor = clr;
}

-(BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    return YES;
}




@end
