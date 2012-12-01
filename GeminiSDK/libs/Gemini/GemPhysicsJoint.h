//
//  GemPhysicsJoint.h
//  GeminiSDK
//
//  Created by James Norton on 11/14/12.
//
//

#import <Foundation/Foundation.h>
#import "GemObject.h"
#import "Box2D.h"

#define GEMINI_PHYSICS_JOINT_LUA_KEY "GeminiLib.GEMNI_PHYSICS_JOINT_LUA_KEY"

@interface GemPhysicsJoint : GemObject

@property b2Joint *joint;

@end
