//
//  GemTouchEvent.h
//  GeminiSDK
//
//  Created by James Norton on 10/9/12.
//
//

#import "GemEvent.h"

#define GEM_TOUCH_EVENT_LUA_KEY "Gemini.TouchEventLuaKey"

typedef enum GemTouchPhase {
    GEM_TOUCH_BEGAN,
    GEM_TOUCH_MOVED,
    GEM_TOUCH_ENDED,
    GEM_TOUCH_CANCELLED
} GemTouchPhase;

@interface GemTouchEvent : GemEvent

@property (nonatomic) GemTouchPhase phase;
@property (nonatomic) float x;
@property (nonatomic) float y;
@property (nonatomic) float startX;
@property (nonatomic) float startY;

-(id)initWithLuaState:(lua_State *)luaState Target:trgt Event:(UIEvent *)evt;

@end


