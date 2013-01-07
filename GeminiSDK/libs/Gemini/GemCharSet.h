//
//  GemCharSet.h
//  GeminiSDK
//
//  Created by James Norton on 1/3/13.
//
//

#import "GemObject.h"
#import <GLKit/GLKit.h>

#define GEMINI_CHARSET_LUA_KEY "GeminiLib.GEMINI_CHARSET_KEY"

typedef struct {
    GLKVector4 texCoord;
    GLKVector2 dimensions;
    GLKVector2 offsets;
    GLfloat xAdvance;
    
} GemCharRenderInfo;


@interface GemCharSet : GemObject

@property GLfloat scale;
@property (readonly) GLfloat lineHeight;
@property (readonly) GLfloat base;

-(id) initWithLuaState:(lua_State *)luaState fontInfo:(NSDictionary *)fontInfo;
-(GLKTextureInfo *)textureInfo;
-(GemCharRenderInfo)renderInfoForChar:(unichar)c;
-(NSNumber *)kerningForFirst:(unichar)first second:(unichar)second;

@end
