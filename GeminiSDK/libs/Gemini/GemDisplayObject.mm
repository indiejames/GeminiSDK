//
//  GeminiDisplayObject.m
//  Gemini
//
//  Created by James Norton on 3/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GemDisplayObject.h"
#import "GemDisplayGroup.h"
#include "Box2D.h"
#import "GemPhysics.h"
#import "Gemini.h"


@implementation GemDisplayObject


@synthesize parent;
@synthesize layer;
@synthesize mask;
@synthesize alpha;
@synthesize needsUpdate;
@synthesize needsTransformUpdate;
@synthesize isVisible;
@synthesize physicsBody;
@synthesize cumulativeTransform;
@synthesize isFlippedHorizontally;
@synthesize isFlippedVertically;

/*-(id)initWithLuaState:(lua_State *)luaState {
    self = [super initWithLuaState:luaState];
    
    if (self) {
        xScale = 1.0;
        yScale = 1.0;
        alpha = 1.0;
        xReference = 0;
        yReference = 0;
        needsUpdate = YES;
        needsTransformUpdate = YES;
        isVisible = YES;
    }
    
    return self;
}*/

-(id) initWithLuaState:(lua_State *)luaState LuaKey:(const char *)luaKey {
    self = [super initWithLuaState:luaState LuaKey:luaKey];
    
    if (self) {
        xScale = 1.0;
        yScale = 1.0;
        alpha = 1.0;
        xReference = 0;
        yReference = 0;
        needsUpdate = YES;
        needsTransformUpdate = YES;
        isVisible = YES;
    }
    
    return self;
}

-(GLfloat)height {
    return height;
}

-(void)setHeight:(GLfloat)ht {
    //[super setDouble:ht forKey:"height"];
    height = ht;
}

-(GLfloat) width {
    //return [super getDoubleForKey:"width" withDefault:1.0];
    return width;
}

-(void)setWidth:(GLfloat)w {
    needsUpdate = YES;
    needsTransformUpdate = YES;
    width = w;
}



-(GLfloat)xScale {
    return xScale;
}

-(void)setXScale:(GLfloat)xs {
    xScale = xs;
    needsTransformUpdate = YES;
}

-(GLfloat)yScale {
    return yScale;
}

-(void)setYScale:(GLfloat)ys {
    yScale = ys;
    needsTransformUpdate = YES;
}
-(GLfloat)rotation {
    //return [super getDoubleForKey:"rotation" withDefault:0];
    return rotation;
}

-(void)setRotation:(GLfloat)rot {
    //[super setDouble:rotation forKey:"rotation"];
    rotation = rot;
    needsTransformUpdate = YES;
}

-(void) setPhysicsTransform:(GLKVector3)trans {
    if (physicsBody) {
        float scale = [[Gemini shared].physics getScale];
        
        b2Vec2 pos = b2Vec2(trans.x / scale, trans.y / scale);
        ((b2Body *)physicsBody)->SetTransform(pos, toRad(trans.z));
        
    }      

}

-(GLfloat)x {
    //return [super getDoubleForKey:"x" withDefault:0];
    return xOrigin + xReference;
}

-(void)setX:(GLfloat)x {
    //[super setDouble:x forKey:"x"];
    
    // must bypass property setter to avoid infinite recursion
    xOrigin = x - self.xReference;
    needsTransformUpdate = YES;
}

-(GLfloat)y {
    //return [super getDoubleForKey:"y" withDefault:0];
    return yOrigin + yReference;
}

-(void)setY:(GLfloat)y {
    //[super setDouble:y forKey:"y"];
    //GLfloat yRef = self.yReference;
    
    // must bypass property setter to avoid infinite recursion
    yOrigin = y - self.yReference;
    needsTransformUpdate = YES;
}

-(GLfloat)xOrigin {
    return xOrigin;
}

-(void)setXOrigin:(GLfloat)xOrig {
    xOrigin = xOrig;
    needsTransformUpdate = YES;
}

-(GLfloat)yOrigin {
    return yOrigin;
}

-(void)setYOrigin:(GLfloat)yOrig {
    yOrigin = yOrig;
    needsTransformUpdate = YES;
}

-(GLfloat)xReference {
    //return [super getDoubleForKey:"xReference" withDefault:0];
    return xReference;
}

-(void)setXReference:(GLfloat)xRef{
    xReference = xRef;
    needsTransformUpdate = YES;
}

-(GLfloat)yReference {
    return yReference;
}

-(void)setYReference:(GLfloat)yRef {
    yReference = yRef;
    needsTransformUpdate = YES;
}

-(NSArray *)getTouchingObjects {
    NSMutableArray *rval = [[NSMutableArray alloc] initWithCapacity:1];
    if (physicsBody) {
        b2Body *body = (b2Body *)physicsBody;
        for (b2ContactEdge *ce = body->GetContactList(); ce; ce = ce->next) {
            b2Contact *contact = ce->contact;
            if (contact->IsTouching()) {
                // add the object containing the first fixture to our list unless the
                // first fixture belongs to this object, in which case we use the
                // object belonging to the second fixture
                b2Fixture *fixtureA = contact->GetFixtureA();
                b2Body *bodyA = fixtureA->GetBody();
                
                GemDisplayObject *obj = (__bridge GemDisplayObject *)(bodyA->GetUserData());
                
                if (obj != self) {
                    [rval addObject:obj];
                } else {
                    // use fixbure B
                    b2Fixture *fixtureB = contact->GetFixtureB();
                    b2Body *bodyB = fixtureB->GetBody();
                    
                    obj = (__bridge GemDisplayObject *)(bodyB->GetUserData());
                    [rval addObject:obj];
                }
                
                
            }
            
        }
    }
    
    return rval;
}

-(void)setIsActive:(bool)active {
    if (physicsBody) {
        [[Gemini shared].physics setBody:physicsBody isActive:active];
    }
    
    if (!active) {
        GemLog(@"Deactivating physics for %@", self.name);
    }
}

-(bool)isActive {
    if (physicsBody) {
        return [[Gemini shared].physics isActiveBody:physicsBody];
    }
    
    return false;
}

-(void)setFixedRotation:(BOOL)fixed {
    fixedRotation = fixed;
    if (fixed) {
        if (physicsBody != NULL) {
            ((b2Body *)physicsBody)->SetFixedRotation(fixedRotation);
        }
    }
}

-(BOOL)fixedRotation {
    return fixedRotation;
    
}

-(GLKVector2)linearVelocity {
    GLfloat vx = 0;
    GLfloat vy = 0;
    
    if (physicsBody != NULL) {
        b2Vec2 vel = ((b2Body *)physicsBody)->GetLinearVelocity();
        vx = vel.x;
        vy = vel.y;
    }
    
    return GLKVector2Make(vx, vy);
    
}

-(GLKMatrix3) transform {
    if (needsTransformUpdate) {
        // NOTE - The order of operations may seem reversed, but this is correct for the way the
        // transform matrix is used
        
        // translate to (xOrigin,yOrigin)
        if (xReference != 0 || yReference != 0) {
            // combine two translations into one
            transform = GLKMatrix3Make(1.0, 0.0, 0, 0, 1, 0, xOrigin + xReference, yOrigin + yReference, 1.0);
            
        } else {
            
            transform = GLKMatrix3Make(1.0, 0, 0, 0, 1, 0, xOrigin, yOrigin, 1.0);
        }
        
        if (xScale != 1.0 || yScale != 1.0) {
            transform = GLKMatrix3Scale(transform, xScale, yScale, 1);
        }
        
        if (rotation != 0) {
            transform = GLKMatrix3RotateZ(transform, GLKMathDegreesToRadians(rotation));
        }
        
        // need to translate reference point to origin for proper rotation scaling about it
        if (xReference != 0 || yReference != 0) {
            transform = GLKMatrix3Multiply(transform, GLKMatrix3Make(1.0, 0, 0, 0, 1, 0, -xReference, -yReference, 1));
            
        }
        
        needsTransformUpdate = NO;

    }
    
    
    return transform;
}

// NOTE - this method must be overriden by subclasses if they are to support touch events and
// don't want to depend on an attached physics body
-(BOOL)doesContainPoint:(GLKVector2) point {
    
    // use the physics body attached if available
    if (physicsBody && [[Gemini shared].physics isActiveBody:physicsBody]) {
        GemLog(@"Using physics body to test point for %@", name);
        return [[Gemini shared].physics doesBody:physicsBody ContainPoint:point];
    }
    
    return NO;
}

// remove this display object and any child objects it may have
/*-(void)deleteObject {
    GemDisplayObject  **obj = (GemDisplayObject **)lua_touserdata(L, -1);
    NSLog(@"LGeminiSupport: deleting display object %@", (*obj).name);
    [(*obj).parent remove:*obj];
    [*obj release];
    
    return 0;
}*/


@end
