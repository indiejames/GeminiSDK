//
//  GemPhysics.mm
//  GeminiSDK
//
//  Created by James Norton on 9/9/12.
//
//

#import "GemPhysics.h"
#include "Box2D.h"
#import "GemEvent.h"
#import "GemCollisionEvent.h"
#import "GemCircle.h"
#import "GemRectangle.h"
#import "GemConvexShape.h"
#import "GemPhysicsJoint.h"

// handles collisions between objects
class GemContactListener : public b2ContactListener {
public:
    void BeginContact(b2Contact* contact){
        /* handle begin event */
    }
    void EndContact(b2Contact* contact) {
        /* handle end event */
    }
    void PreSolve(b2Contact* contact, const b2Manifold* oldManifold) {
        /* handle pre-solve event */
        const b2Body* bodyA = contact->GetFixtureA()->GetBody();
        const b2Body* bodyB = contact->GetFixtureB()->GetBody();
        GemDisplayObject *objA = (__bridge GemDisplayObject *)bodyA->GetUserData();
        GemDisplayObject *objB = (__bridge GemDisplayObject *)bodyB->GetUserData();
        
        GemCollisionEvent *event = [[GemCollisionEvent alloc] initWithLuaState:objA.L Target:objA Source:objB];
        event.name = @"collision";
        event.phase = GEM_COLLISION_PRESOLVE;
        [objA handleEvent:event];
        
        event = [[GemCollisionEvent alloc] initWithLuaState:objB.L Target:objB Source:objA];
        event.name = @"collision";
        event.phase = GEM_COLLISION_PRESOLVE;
        [objB handleEvent:event];
        
    }
    
    void PostSolve(b2Contact* contact, const b2ContactImpulse* impulse) {
        /* handle post-solve event */
        const b2Body* bodyA = contact->GetFixtureA()->GetBody();
        const b2Body* bodyB = contact->GetFixtureB()->GetBody();
        GemDisplayObject *objA = (__bridge GemDisplayObject *)bodyA->GetUserData();
        GemDisplayObject *objB = (__bridge GemDisplayObject *)bodyB->GetUserData();
        
        GemCollisionEvent *event = [[GemCollisionEvent alloc] initWithLuaState:objA.L Target:objA Source:objB];
        event.name = @"collision";
        event.phase = GEM_COLLISION_POSTSOLVE;
        [objA handleEvent:event];
        
        event = [[GemCollisionEvent alloc] initWithLuaState:objB.L Target:objB Source:objA];
        event.name = @"collision";
        event.phase = GEM_COLLISION_POSTSOLVE;
        [objB handleEvent:event];
    }
};


@implementation GemPhysics {
    b2World *world;
    BOOL paused;
    float timeStep;
    double accumulator;
}

@synthesize drawMode;

-(id)init {
    self = [super init];
    if (self) {
        b2Vec2 gravity(0.0f, -9.8f);
        bool doSleep = true;
        world = new b2World(gravity);
        world->SetAllowSleeping(doSleep);
        GemContactListener *listener = new GemContactListener();
        world->SetContactListener(listener);
        
        scale = 50.0; // pixels per meter
        timeStep = 1.0 / 60.0; // sec
        accumulator = 0;
        paused = NO;
        
        joints = [[NSMutableArray alloc] initWithCapacity:1];
    }
    
    return self;
    
}

-(void)addBodyForObject:(GemDisplayObject *)obj WithParams:(NSDictionary *)params {
    b2BodyDef bodyDef;
    GemPoint p = {obj.x, obj.y};
    GemPoint pp = [self toPhysicsCoord:p];
    bodyDef.position.Set(pp.x, pp.y);
    bodyDef.angle = toRad(obj.rotation);
    
    b2BodyType type = b2_staticBody;
    
    if ([params objectForKey:@"type"] != nil) {
        NSString *typeStr = [params objectForKey:@"type"];
        if ([typeStr isEqualToString:@"dynamic"]) {
            type = b2_dynamicBody;
        } else if ([typeStr isEqualToString:@"kinematic"]){
            type = b2_kinematicBody;
        }
    }
    
    bodyDef.type = type;
    
    bodyDef.linearDamping = 0;
    bodyDef.angularDamping = 0.1;
    
    b2Body* body = world->CreateBody(&bodyDef);
    
    NSDictionary *fixtures = [params objectForKey:@"fixtures"];
    [fixtures enumerateKeysAndObjectsUsingBlock:^(id key, id value, BOOL *stop) {
        
        NSDictionary *fixtureParams = value;
        
        b2FixtureDef fixtureDef;
        b2PolygonShape polyShape;
        b2CircleShape circle;
        
        if ([fixtureParams objectForKey:@"shape"] != nil) {
            // use a polygon shape
            NSArray *points = (NSArray *)[fixtureParams objectForKey:@"shape"];
            b2Vec2 *verts = (b2Vec2 *)malloc([points count]/ 2 * sizeof(b2Vec2));
            for (int i=0; i<[points count]/2; i++) {
                float x = [(NSNumber *)[points objectAtIndex:i*2] floatValue] / scale;
                float y = -[(NSNumber *)[points objectAtIndex:i*2+1] floatValue] / scale;
                verts[i].Set(x, y);
            }
            
            polyShape.Set(verts, [points count]/2);
            fixtureDef.shape = &polyShape;
            free(verts);
        } else if ([fixtureParams objectForKey:@"radius"] != nil){
            // use a circle shape
            float radius = [(NSNumber *)[fixtureParams objectForKey:@"radius"] floatValue] / scale;
            
            NSArray *posArray = (NSArray *)[fixtureParams objectForKey:@"position"];
            float x = [(NSNumber *)[posArray objectAtIndex:0] floatValue] / scale;
            float y = -[(NSNumber *)[posArray objectAtIndex:1] floatValue] / scale;
            
            circle.m_p.Set(x, y);
            circle.m_radius = radius;
            fixtureDef.shape = &circle;
            
        } else if ([fixtureParams objectForKey:@"width"] != nil) {
            // use box shape
            float width = [(NSNumber *)[fixtureParams objectForKey:@"width"] floatValue] / scale;
            float height = [(NSNumber *)[fixtureParams objectForKey:@"height"] floatValue] / scale;
            
            polyShape.SetAsBox(width / 2.0, height / 2.0);
            fixtureDef.shape = &polyShape;
            
        } else {
            
            if (obj.class == GemCircle.class) {
                circle.m_radius = (((GemCircle *)obj).radius) / scale - RENDER_PADDING;
                fixtureDef.shape = &circle;
            } else if (obj.class == GemRectangle.class){
                // us a box shape and account for the border on the rectange
                GemRectangle *rect = (GemRectangle *)obj;
                float width = (rect.width) / scale - 2*RENDER_PADDING;
                float height = (rect.height) / scale - 2*RENDER_PADDING;
                
                polyShape.SetAsBox(width / 2.0, height / 2.0);
                fixtureDef.shape = &polyShape;
                
            } else {
                // use box shape for everything else
                float width = (obj.width) / scale - 2*RENDER_PADDING;
                float height = (obj.height) / scale - 2*RENDER_PADDING;
                
                polyShape.SetAsBox(width / 2.0, height / 2.0);
                fixtureDef.shape = &polyShape;
            }
            
        }
        
        float density = 1.0;
        if ([fixtureParams objectForKey:@"density"] != nil) {
            density = [(NSNumber *)[fixtureParams objectForKey:@"density"] floatValue];
        }
        
        float friction = 1.0;
        if ([fixtureParams objectForKey:@"friction"] != nil) {
            friction = [(NSNumber *)[fixtureParams objectForKey:@"friction"] floatValue];
        }
        
        float restitution = 0;
        // support "bounce" or "restitution" keyword
        if ([fixtureParams objectForKey:@"bounce"] != nil) {
            restitution = [(NSNumber *)[fixtureParams objectForKey:@"bounce"] floatValue];
        }
        if ([fixtureParams objectForKey:@"restitution"] != nil) {
            restitution = [(NSNumber *)[fixtureParams objectForKey:@"restitution"] floatValue];
        }
        
        bool isSensor = false;
        if ([fixtureParams objectForKey:@"isSensor"] != nil) {
            isSensor = [(NSNumber *)[fixtureParams objectForKey:@"isSensor"] boolValue];
        }
        
        fixtureDef.density = density;
        fixtureDef.friction = friction;
        fixtureDef.restitution = restitution;
        fixtureDef.isSensor = isSensor;
        
        body->CreateFixture(&fixtureDef);
    }];
    
    // create a default fixture if none are supplied
    if (fixtures == nil || [fixtures count] == 0) {
        b2FixtureDef fixtureDef;
        b2CircleShape circleShape;
        b2PolygonShape polyShape;
        
        if (obj.class == GemCircle.class) {
            circleShape.m_radius = ((GemCircle *)obj).radius / scale;
            fixtureDef.shape = &circleShape;
        } else {
            // use box shape for everything else
            float width = obj.width / scale;
            float height = obj.height / scale;
            
            polyShape.SetAsBox(width / 2.0, height / 2.0);
            fixtureDef.shape = &polyShape;
        }
        
        body->CreateFixture(&fixtureDef);

    }
    
    if (obj.fixedRotation) {
        body->SetFixedRotation(true);
    }
    
    body->SetUserData((__bridge void*)obj);
    obj.physicsBody = body;
}

// this method creates a Box2D joint and then returns it wrapped in a GemPhysicsJoint
-(id)addJoint:(void *)jDef forLuaState:(lua_State *)L{
    
    b2JointDef *jointDef = (b2JointDef *)jDef;
    
    b2Joint *joint =  world->CreateJoint(jointDef);
    
    // TEST
    ((b2RevoluteJoint *)joint)->SetMaxMotorTorque(100000);
    GemPhysicsJoint *gemJoint = [[GemPhysicsJoint alloc] initWithLuaState:L];
    
    gemJoint.joint = joint;
    
    [joints addObject:gemJoint];
    
    return gemJoint;
}

-(void)update:(double)deltaT {
    
    if (paused) {
        return;
    }
    
    int velocityIterations = 8;
    int positionIterations = 3;
    

    if (deltaT > 0.25) {
        deltaT = 0.25;// note: max frame time to avoid spiral of death
    }
    
    accumulator += deltaT;
    
    while ( accumulator >= timeStep ) {
        if (accumulator < timeStep * 2.0) {
            // only update if on last simulation loop
            for (b2Body* b = world->GetBodyList(); b; b = b->GetNext()) {
                //b->SetAwake(true);
                b2Vec2 position = b->GetPosition();
                GemPoint pPoint = {position.x, position.y};
                GemPoint point = [self fromPhysicsCoord:pPoint];
                float32 angle = b->GetAngle();
                
                GemDisplayObject *gdo = (__bridge GemDisplayObject *)b->GetUserData();
                gdo.rotation = toDeg(angle);
                gdo.x = point.x;
                gdo.y = point.y;
                
                //GemLog(@"(x,y,theta) = (%4.2f, %4.2f, %4.2f)\n", position.x, position.y, angle);
            }
        }
        

        world->Step(timeStep, velocityIterations, positionIterations);
        
            
        accumulator -= timeStep;
    }
    
    // interpolate remainder of update
    const double alpha = accumulator / timeStep;
    
    for (b2Body* b = world->GetBodyList(); b; b = b->GetNext()) {
        
        b2Vec2 position = b->GetPosition();
        GemPoint pPoint = {position.x, position.y};
        GemPoint point = [self fromPhysicsCoord:pPoint];
        float32 angle = b->GetAngle();
        
        GemDisplayObject *gdo = (__bridge GemDisplayObject *)b->GetUserData();
        gdo.rotation = alpha * toDeg(angle) + (1.0-alpha)*gdo.rotation;
        gdo.x = alpha * point.x + (1.0 - alpha)*gdo.x;
        gdo.y = alpha * point.y + (1.0-alpha)*gdo.y;
        
    }
       
}

-(bool)isActiveBody:(void *)body {
    b2Body *physBody = (b2Body *)body;
    return physBody->IsActive();
}

-(void)setBody:(void *)body isActive:(bool)active {
    b2Body *physBody = (b2Body *)body;
    physBody->SetActive(active);
}

-(BOOL)doesBody:(void *)body ContainPoint:(GLKVector2)point {
    b2Body *physicsBody = (b2Body *)body;
    
    b2Vec2 p;
    p.x = point.x / scale;
    p.y = point.y / scale;
    
    b2Fixture* fixture = ((b2Body *)physicsBody)->GetFixtureList();
    while(fixture != NULL) {
        if (fixture->TestPoint(p)) {
            return YES;
        }
        
        fixture = fixture->GetNext();
    }
    
    return NO;

}

-(void)setScale:(double)s {
    scale = s;
}

-(float)getScale {
    return scale;
}

-(void)setContinous:(bool) cont{
    world->SetContinuousPhysics(cont);
}

-(void)setGravityGx:(float)gx Gy:(float)gy {
    b2Vec2 g(gx,gy);
    
    world->SetGravity(g);
}

-(void)pause {
    paused = YES;
}

-(void)start {
    paused = NO;
}

-(GemPoint)toPhysicsCoord:(GemPoint)point {
    GemPoint rval;
    rval.x = point.x / scale;
    rval.y = point.y / scale;
    
    return rval;
}

-(GemPoint)fromPhysicsCoord:(GemPoint)point {
    GemPoint rval;
    rval.x = point.x * scale;
    rval.y = point.y * scale;
    
    return rval;
}

float toRad(float deg){
    return deg  * M_PI / 180.0;
}

float toDeg(float rad){
    return rad * 180.0 / M_PI;
}

@end

