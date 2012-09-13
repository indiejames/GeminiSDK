//
//  GemPhysics.m
//  GeminiSDK
//
//  Created by James Norton on 9/9/12.
//
//

#import "GemPhysics.h"
#include "Box2D.h"
#import "GemEvent.h"

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
        
        GemEvent *event = [[GemEvent alloc] initWithLuaState:objA.L Source:objA];
        event.name = @"collision:presolve";
        [objA handleEvent:event];
        
        event = [[GemEvent alloc] initWithLuaState:objB.L Source:objB];
        event.name = @"collision:presolve";
        [objB handleEvent:event];
        
    }
    
    void PostSolve(b2Contact* contact, const b2ContactImpulse* impulse) {
        /* handle post-solve event */
        const b2Body* bodyA = contact->GetFixtureA()->GetBody();
        const b2Body* bodyB = contact->GetFixtureB()->GetBody();
        GemDisplayObject *objA = (__bridge GemDisplayObject *)bodyA->GetUserData();
        GemDisplayObject *objB = (__bridge GemDisplayObject *)bodyB->GetUserData();
        
        GemEvent *event = [[GemEvent alloc] initWithLuaState:objA.L Source:objA];
        event.name = @"collision:postsolve";
        [objA handleEvent:event];
        
        event = [[GemEvent alloc] initWithLuaState:objB.L Source:objB];
        event.name = @"collision:postsolve";
        [objB handleEvent:event];
    }
};


@implementation GemPhysics {
    b2World *world;
    BOOL paused;
    float timeStep;
    double accumulator;
}

-(id)init {
    self = [super init];
    if (self) {
        b2Vec2 gravity(0.0f, -9.8f);
        bool doSleep = true;
        world = new b2World(gravity);
        world->SetAllowSleeping(doSleep);
        GemContactListener *listener = new GemContactListener();
        world->SetContactListener(listener);
        
        scale = 30.0; // meters per pixel
        timeStep = 1.0 / 60.0; // sec
        accumulator = 0;
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
    b2FixtureDef fixtureDef;
    b2PolygonShape polyShape;
    b2CircleShape circle;
    
    if ([params objectForKey:@"shape"] != nil) {
        // use a polygon shape
        NSArray *points = (NSArray *)[params objectForKey:@"shape"];
        b2Vec2 *verts = (b2Vec2 *)malloc([points count]/ 2 * sizeof(b2Vec2));
        for (int i=0; i<[points count]/2; i++) {
            float x = [(NSNumber *)[points objectAtIndex:i*2] floatValue];
            float y = [(NSNumber *)[points objectAtIndex:i*2+1] floatValue];
            verts[i].Set(x, y);
        }
        
        polyShape.Set(verts, [points count]/2);
        fixtureDef.shape = &polyShape;
    } else if ([params objectForKey:@"radius"] != nil){
        // use a circle shape
        float radius = [(NSNumber *)[params objectForKey:@"radius"] floatValue];
        
        circle.m_p.Set(pp.x, pp.y);
        circle.m_radius = radius;
        fixtureDef.shape = &circle;
        
    } else {
        // use the default box shape
        float hWidth = obj.width / scale / 2.0;
        float hHeight = obj.height / scale / 2.0;
        
        polyShape.SetAsBox(hWidth, hHeight);
        fixtureDef.shape = &polyShape;
    }
    
    float density = 1.0;
    if ([params objectForKey:@"density"] != nil) {
        density = [(NSNumber *)[params objectForKey:@"density"] floatValue];
    }
    
    float friction = 1.0;
    if ([params objectForKey:@"friction"] != nil) {
        friction = [(NSNumber *)[params objectForKey:@"friction"] floatValue];
    }
    
    float restitution = 0;
    if ([params objectForKey:@"restitution"] != nil) {
        restitution = [(NSNumber *)[params objectForKey:@"restitution"] floatValue];
    }
    
    fixtureDef.density = density;
    fixtureDef.friction = friction;
    fixtureDef.restitution = restitution;
    
    body->CreateFixture(&fixtureDef);
    body->SetUserData((__bridge void*)obj);
    obj.physicsBody = body;
}

-(void)update:(double)deltaT {
    
    int velocityIterations = 8;
    int positionIterations = 3;
    

    if (deltaT > 0.25) {
        deltaT = 0.25;// note: max frame time to avoid spiral of death
    }
    
    accumulator += deltaT;
    
    while ( accumulator >= timeStep ) {
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

        world->Step(timeStep, velocityIterations, positionIterations);
        
            
        accumulator -= timeStep;
    }
    
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

-(void)setScale:(double)s {
    scale = s;
}

-(void)setDrawMode:(GemPhysicsDrawMode)mode {
    drawMode = mode;
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

