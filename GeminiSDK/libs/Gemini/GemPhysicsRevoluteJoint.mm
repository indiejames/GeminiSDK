//
//  GemPhysicsRevoluteJoint.m
//  GeminiSDK
//
//  Created by James Norton on 11/14/12.
//
//

#import "GemPhysicsRevoluteJoint.h"



@implementation GemPhysicsRevoluteJoint

-(id)initWithLuaState:(lua_State *)luaState withObjectA:(GemDisplayObject *)objA objectB:(GemDisplayObject *)objB anchorPoint:(b2Vec2) anchorPoint {
    self = [super initWithLuaState:luaState LuaKey:GEMINI_PHYSICS_REVOLUTE_JOINT_LUA_KEY];
    
    
    return self;
}

@end
