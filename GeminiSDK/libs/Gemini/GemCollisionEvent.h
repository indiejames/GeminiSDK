//
//  GemCollisionEvent.h
//  GeminiSDK
//
//  Created by James Norton on 11/29/12.
//
//

#import "GemEvent.h"
#import "GemDisplayObject.h"

#define GEM_COLLISION_EVENT_LUA_KEY "Gemini.GemCollisionEventLuaKey"

typedef enum GemCollisionPhase {
    GEM_COLLISION_PRESOLVE,
    GEM_COLLISION_POSTSOLVE
} GemCollisionPhase;

@interface GemCollisionEvent : GemEvent

@property (nonatomic, strong) GemDisplayObject *source;
@property (nonatomic) GemCollisionPhase phase;

-(id) initWithLuaState:(lua_State *)luaState Target:(GemDisplayObject *)trgt Source:(GemDisplayObject *)src;

@end
