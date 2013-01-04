//
//  GemImage.h
//  GeminiSDK
//
//  This is a specialization of the GemSprite class that does not
//  do animation.  It just makes it simpler to create backgrounds and
//  other static imagery.
//
//  Created by James Norton on 1/3/13.
//
//

#import "GemSprite.h"

#define GEMINI_IMAGE_LUA_KEY "GeminiLib.GEMINI_IMAGE_KEY"

@interface GemImage : GemSprite

@property NSString *imageName;

-(id) initWithLuaState:(lua_State *)luaState SpriteSheet:(GemSpriteSheet *)ss ForImageName:(NSString *)name;

@end
