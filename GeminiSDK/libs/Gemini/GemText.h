//
//  GemText.h
//  GeminiSDK
//
//  A text display object
//
//  Created by James Norton on 1/3/13.
//
//

#import "GemDisplayObject.h"
#import "GemCharSet.h"

#define GEMINI_TEXT_LUA_KEY "GeminiLib.GEMINI_TEXT_KEY"



@interface GemText : GemDisplayObject

@property (readonly) GemCharSet *charSet;
@property NSString *text;
@property (readonly) GLfloat *verts;
@property (readonly) GLKVector2 *texCoord;

-(id) initWithLuaState:(lua_State *)luaState font:(NSString *)font;
-(void)setFont:(NSString *)font;

@end
