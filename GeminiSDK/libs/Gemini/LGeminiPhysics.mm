//
//  LGeminiPhysics.m
//  Gemini
//
//  Created by James Norton on 5/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "LGeminiPhysics.h"
#import "LGeminiLuaSupport.h"
#import "Gemini.h"
#import "GemPhysicsJoint.h"
#include "Box2D.h"
#import "GemPhysics.h"


//////////// bodies /////////////////

static int addBody(lua_State *L){
    __unsafe_unretained GemDisplayObject **displayObj = (__unsafe_unretained GemDisplayObject **)lua_touserdata(L, 1);
    
    GemLog(@"Adding physics to %@", (*displayObj).name);
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:1];
    NSMutableDictionary *fixtureDefs = [NSMutableDictionary dictionaryWithCapacity:1];
    [params setObject:fixtureDefs forKey:@"fixtures"];
    
    NSString *type = @"static";
    
    int numArgs = lua_gettop(L);
    
    for (int i=1; i<numArgs; i++) {
        if (lua_isstring(L, i+1)) {
            // type attribute
            type = [NSString stringWithUTF8String:lua_tostring(L, i+1)];
            
        } else {
            // argument is a table - iterate over keys/vals to add to configuration for fixtures
            
            NSMutableDictionary *fixtureDef = [[NSMutableDictionary alloc] initWithCapacity:1];
            NSString *fixtureId = @"ANONYMOUS";
            
            lua_pushnil(L);  /* first key */
            while (lua_next(L, i+1) != 0) {
                // 'key' (at index -2) and 'value' (at index -1)
                
                const char *key = lua_tostring(L, -2);
                if (strcmp(key, "shape") == 0) {
                    // value is a table
                    
                    NSMutableArray *shape = [NSMutableArray arrayWithCapacity:1];
                    NSMutableArray *tmpShape = [NSMutableArray arrayWithCapacity:1];
                    [fixtureDef setObject:shape forKey:[NSString stringWithUTF8String:key]];
                    
                    // iterate over the table and copy its values
                    lua_pushnil(L);
                    while (lua_next(L, -2) != 0) {
                        double value = lua_tonumber(L, -1);
                        [tmpShape addObject:[NSNumber numberWithDouble:value]];
                        // removes 'value'; keeps 'key' for next iteration
                        lua_pop(L, 1);
                    }
                    
                    // reverse the order to compensate for difference with Corona
                    for (int i=[tmpShape count]/2 - 1; i>=0; i--) {
                        NSNumber *x = [tmpShape objectAtIndex:i*2];
                        NSNumber *y = [tmpShape objectAtIndex:i*2+1];
                        [shape addObject:x];
                        [shape addObject:y];
                    }
                    
                } else if (strcmp(key, "filter") == 0){
                    // value is a table
                    NSMutableDictionary *filter = [NSMutableDictionary dictionaryWithCapacity:3];
                    [fixtureDef setObject:filter forKey:@"filter"];
                    // iterate over table keys/values
                    lua_pushnil(L);
                    while (lua_next(L, -2) != 0) {
                        const char *filterKey = lua_tostring(L, -2);
                        unsigned int value = lua_tounsigned(L, -1);
                        [filter setObject:[NSNumber numberWithUnsignedInt:value] forKey:[NSString stringWithUTF8String:filterKey]];
                        // remove the value but leave the key for the next iteration
                        lua_pop(L, 1);
                    }
                } else if (strcmp(key, "pe_fixture_id") == 0){
                    const char *fixId = lua_tostring(L, -1);
                    fixtureId = [NSString stringWithUTF8String:fixId];
                } else if (strcmp(key, "position") == 0) {
                    // value is a table
                    
                    NSMutableArray *position = [NSMutableArray arrayWithCapacity:2];
                    [fixtureDef setObject:position forKey:[NSString stringWithUTF8String:key]];
                    
                    // iterate over the table and copy its values
                    lua_pushnil(L);
                    while (lua_next(L, -2) != 0) {
                        double value = lua_tonumber(L, -1);
                        [position addObject:[NSNumber numberWithDouble:value]];
                        // removes 'value'; keeps 'key' for next iteration
                        lua_pop(L, 1);
                    }
                } else if (strcmp(key, "isSensor") == 0){
                    bool isSensor = lua_toboolean(L, -1);
                    [fixtureDef setObject:[NSNumber numberWithBool:isSensor] forKey:@"isSensor"];
                } else {
                    // handle float values like density, friction, etc.
                    double val = lua_tonumber(L, -1);
                    
                    [fixtureDef setObject:[NSNumber numberWithDouble:val] forKey:[NSString stringWithUTF8String:key]];
                    
                }
                
                // removes 'value'; keeps 'key' for next iteration
                lua_pop(L, 1);
            }
            
            [fixtureDefs setObject:fixtureDef forKey:fixtureId];
        }

    }
    
    [params setObject:type forKey:@"type"];
    
    GemDisplayObject *gdo = *displayObj;
    
    [[Gemini shared].physics addBodyForObject:gdo WithParams:params];
    
    
    return 0;
}

int applyForce(lua_State *L){
    double scale = [[Gemini shared].physics getScale];
    __unsafe_unretained GemDisplayObject **displayObj = (__unsafe_unretained GemDisplayObject **)lua_touserdata(L, 1);
    float fx = luaL_checknumber(L, 2);
    float fy = luaL_checknumber(L, 3);
    
    
    b2Body *body =  (b2Body *)(*displayObj).physicsBody;
    if (body == NULL) {
        lua_pushstring(L, "LUA ERROR: Object does not have a physics body attached");
        lua_error(L);
    } else {
        // use the coordinates for the point of application if they have been supplied
        if (lua_gettop(L) == 5) {
            float x = luaL_checknumber(L, 4) / scale;
            float y = luaL_checknumber(L, 5) / scale;
            body->ApplyForce(b2Vec2(fx,fy), b2Vec2(x,y));
        } else {
            body->ApplyForceToCenter(b2Vec2(fx,fy));
        }
        
    }
    
    return 0;
}

int applyLinearImpulse(lua_State *L){
    double scale = [[Gemini shared].physics getScale];
    __unsafe_unretained GemDisplayObject **displayObj = (__unsafe_unretained GemDisplayObject **)lua_touserdata(L, 1);
    float fx = luaL_checknumber(L, 2);
    float fy = luaL_checknumber(L, 3);
    
    
    b2Body *body =  (b2Body *)(*displayObj).physicsBody;
    if (body == NULL) {
        lua_pushstring(L, "LUA ERROR: Object does not have a physics body attached");
        lua_error(L);
    } else {
        // use the coordinates for the point of application if they have been supplied
        if (lua_gettop(L) == 5) {
            float x = luaL_checknumber(L, 4) / scale;
            float y = luaL_checknumber(L, 5) / scale;
            body->ApplyLinearImpulse(b2Vec2(fx, fy), b2Vec2(x, y));
        } else {
            body->ApplyForceToCenter(b2Vec2(fx,fy));
            body->ApplyLinearImpulse(b2Vec2(fx, fy), body->GetWorldCenter());
        }
        
    }

    
    return 0;
}

int setLinearVelocity(lua_State *L){
    __unsafe_unretained GemDisplayObject **displayObj = (__unsafe_unretained GemDisplayObject **)lua_touserdata(L, 1);
    float vx = luaL_checknumber(L, 2);
    float vy = luaL_checknumber(L, 3);
    
    
    b2Body *body =  (b2Body *)(*displayObj).physicsBody;
    if (body == NULL) {
        lua_pushstring(L, "LUA ERROR: Object does not have a physics body attaced");
        lua_error(L);
    } else {
        b2Vec2 vel = b2Vec2(vx, vy);
        body->SetLinearVelocity(vel);
    }

    
    return 0;
}

/////////// joints ///////////

static int newJoint(lua_State *L){
    double scale = [[Gemini shared].physics getScale];
    const char *type = lua_tostring(L, 1);
    if (strcmp(type, "revolute") == 0) {
        __unsafe_unretained GemDisplayObject **objA = (__unsafe_unretained GemDisplayObject **)lua_touserdata(L, 2);
        __unsafe_unretained GemDisplayObject **objB = (__unsafe_unretained GemDisplayObject **)lua_touserdata(L, 3);
        b2RevoluteJointDef jointDef;
        
        float x = luaL_checknumber(L, 4) / scale;
        float y = luaL_checknumber(L, 5) / scale;
        
        b2Vec2 anchor(x,y);
        
        jointDef.Initialize((b2Body *)(*objA).physicsBody, (b2Body *)(*objB).physicsBody, anchor);
    
        [[Gemini shared].physics addJoint:&jointDef forLuaState:L];
        
        // joint is now on Lua stack
    }
    
    return 1;
}

static bool validateRevoluteJoint(lua_State *L, GemPhysicsJoint *joint){
    bool rval = true;
    
    if (joint.joint->GetType() != e_revoluteJoint) {
        lua_pushstring(L, "LUA ERROR: Expected revolute joint");
        lua_error(L);
        rval = false;
    }
    
    return rval;
}

static int jointNewIndex(lua_State *L){
    __unsafe_unretained GemPhysicsJoint **lJoint = (__unsafe_unretained GemPhysicsJoint **)luaL_checkudata(L, 1, GEMINI_PHYSICS_JOINT_LUA_KEY);
    GemPhysicsJoint *joint = *lJoint;
    
    
    
    if (lua_isstring(L, 2)) {
        
        const char *key = lua_tostring(L, 2);
        if (strcmp("isMotorEnabled", key) == 0) {
            if (!validateRevoluteJoint(L, joint)) {
                return 0;
            }
            
            bool enabled = lua_toboolean(L, 3);
            ((b2RevoluteJoint *)joint.joint)->EnableMotor(enabled);
            
           
        } else if (strcmp("motorSpeed", key) == 0) {
            if (!validateRevoluteJoint(L, joint)) {
                return 0;
            }
            float speed = luaL_checknumber(L, 3);
            ((b2RevoluteJoint *)joint.joint)->SetMotorSpeed(speed);
    
        } else {
            return genericNewIndex(L);
        }
        
    }
    
    
    
    return 0;
    
}

/////////// general physics stuff //////////////

static int setScale(lua_State *L){
    double scale = lua_tonumber(L, 1);
    [[Gemini shared].physics setScale:scale];
    
    return 0;
}

static int setDrawMode(lua_State *L){
    const char *mode = lua_tostring(L, -1);
    GemPhysicsDrawMode drawMode = GEM_PHYSICS_NORMAL;
    if (strcmp(mode, "debug") == 0) {
        drawMode = GEM_PHYSICS_DEBUG;
    } else if (strcmp(mode, "hybrid") == 0){
        drawMode = GEM_PHYSICS_HYBRID;
    }
    
    [[Gemini shared].physics setDrawMode:drawMode];
    
    return 0;
}

static int setContinuous(lua_State *L){
    bool cont = lua_toboolean(L, 1);
    [[Gemini shared].physics setContinous:cont];
    
    return 0;
}

static int pause(lua_State *L){
    [[Gemini shared].physics pause];
    
    return 0;
}

static int start(lua_State *L){
    [[Gemini shared].physics start];
    
    return 0;
}

static int setGravity(lua_State *L){
    
    float gx = lua_tonumber(L, 1);
    float gy = lua_tonumber(L, 2);
    [[Gemini shared].physics setGravityGx:gx Gy:gy];
    
    return 0;
}


static int newIndex(lua_State *L){
    //return genericNewIndex(L);
    return 0;
}

// the mappings for the library functions
static const struct luaL_Reg physicsLib_f [] = {
    {"addBody", addBody},
    {"newJoint", newJoint},
    {"setScale", setScale},
    {"setContinuous", setContinuous},
    {"setDrawMode", setDrawMode},
    {"setGravity", setGravity},
    {"pause", pause},
    {"start", start},
    {NULL, NULL}
};

// mappings for the body methods
static const struct luaL_Reg physicsBody_m [] = {
    {"__index", genericIndex},
    {"__newindex", newIndex},
    {NULL, NULL}
};

// mappings for the joint methods
static const struct luaL_Reg physicsJoint_m [] = {
    {"__index", genericIndex},
    {"__newindex", jointNewIndex},
    {NULL, NULL}
};


extern "C" int luaopen_physics_lib (lua_State *L){
    // create meta table for our physics types
    createMetatable(L, GEMINI_PHYSICS_JOINT_LUA_KEY, physicsJoint_m);
       
    // create the table for this library and popuplate it with our functions
    luaL_newlib(L, physicsLib_f);
    
    
    return 1;
}

