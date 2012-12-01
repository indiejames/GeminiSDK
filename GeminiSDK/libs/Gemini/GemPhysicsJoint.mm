//
//  GemPhysicsJoint.m
//  GeminiSDK
//
//  Created by James Norton on 11/14/12.
//
//

#import "GemPhysicsJoint.h"
#import "GemDisplayObject.h"
#import "Box2D.h"

@implementation GemPhysicsJoint

@synthesize joint;

-(id)initWithLuaState:(lua_State *)luaState {
    self = [super initWithLuaState:luaState LuaKey:GEMINI_PHYSICS_JOINT_LUA_KEY];
    
    return self;
}

@end
