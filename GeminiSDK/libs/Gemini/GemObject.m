//
//  GeminiObject.m
//  Gemini
//
//  Created by James Norton on 2/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GemObject.h"
#import "GemEvent.h"

@implementation GemObject

@synthesize selfRef;
@synthesize propertyTableRef;
@synthesize L;
@synthesize name;

-(id) initWithLuaState:(lua_State *)luaState {
    self = [super init];
    if (self) {
        eventHandlers = [[NSMutableDictionary alloc] initWithCapacity:1];
        L = luaState;
    }
    
    return self;
}

-(void) dealloc {
   /* NSArray *keys = [eventHandlers allKeys];
    for (NSString *key in keys) {
        NSArray *callbacks = (NSArray *)[eventHandlers objectForKey:key];
        [callbacks release];
    }*/
    // release our property table
    luaL_unref(L, LUA_REGISTRYINDEX, propertyTableRef);
    [eventHandlers release];
    
    [super dealloc];
}

// methods to support storing attributes in Lau table

-(BOOL)getBooleanForKey:(const char*) key withDefault:(BOOL)dflt {
    BOOL rval = dflt;
    lua_rawgeti(L, LUA_REGISTRYINDEX, propertyTableRef);
    lua_getfield(L, -1, key);
    if (!lua_isnil(L, -1)) {
        rval = lua_toboolean(L, -1);
    }
    
    lua_pop(L, 2);
    
    return lua_toboolean(L, -1);
}

-(double)getDoubleForKey:(const char*) key withDefault:(double)dflt {
    double rval = dflt;
    lua_rawgeti(L, LUA_REGISTRYINDEX, propertyTableRef);
    lua_getfield(L, -1, key);
    if (!lua_isnil(L, -1)) {
        rval = lua_tonumber(L, -1);
    }
    
    lua_pop(L, 2);
    
    return rval;
}

-(int)getIntForKey:(const char*) key withDefault:(int)dflt{
    int rval = dflt;
    lua_rawgeti(L, LUA_REGISTRYINDEX, propertyTableRef);
    lua_getfield(L, -1, key);
    if (!lua_isnil(L, -1)) {
        rval = lua_tointeger(L, -1);
    }
    
    lua_pop(L, 2);
    
    return rval;
}

-(NSString *)getStringForKey:(const char*) key withDefault:(NSString *)dflt{
    NSString *rval = dflt;
    
    lua_rawgeti(L, LUA_REGISTRYINDEX, propertyTableRef);
    lua_getfield(L, -1, key);
    if (!lua_isnil(L, -1)) {
        rval = [NSString stringWithFormat:@"%s",lua_tostring(L, -1)];
    }
    
    return rval;
}

-(void)setBOOL:(BOOL)val forKey:(const char*) key {
    lua_rawgeti(L, LUA_REGISTRYINDEX, propertyTableRef);
    lua_pushstring(L, key);
    lua_pushboolean(L, val);
    lua_settable(L, -3);
    lua_pop(L, 1);
}

-(void)setDouble:(double)val forKey:(const char*) key {
    lua_rawgeti(L, LUA_REGISTRYINDEX, propertyTableRef);
    lua_pushstring(L, key);
    lua_pushnumber(L, val);
    lua_settable(L, -3);
    lua_pop(L, 1);
}

-(void)setInt:(int)val forKey:(const char*) key {
    lua_rawgeti(L, LUA_REGISTRYINDEX, propertyTableRef);
    lua_pushstring(L, key);
    lua_pushinteger(L, val);
    lua_settable(L, -3);
    lua_pop(L, 1);
}

-(void)setString:(NSString *)val forKey:(const char*) key {
    lua_rawgeti(L, LUA_REGISTRYINDEX, propertyTableRef);
    lua_pushstring(L, key);
    const char *sval = [val cStringUsingEncoding:[NSString defaultCStringEncoding]];
    lua_pushstring(L, sval);
    lua_settable(L, -3);
    lua_pop(L, 1);
}


-(BOOL)handleEvent:(GemEvent *)event {
    
    //NSLog(@"GemObject: handling event %@", event.name);
    NSArray *callbacks = (NSMutableArray *)[eventHandlers objectForKey:event.name];
        
    if ([callbacks count] > 0) {
        for (int i=0; i<[callbacks count]; i++) {
            
            NSNumber *callback = (NSNumber *)[callbacks objectAtIndex:i];
            int registryKey = [callback intValue];
            lua_rawgeti(L, LUA_REGISTRYINDEX, registryKey);
            
            if (lua_isfunction(L, -1)) {
                //NSLog(@"Event handler is a function");
                lua_rawgeti(L, LUA_REGISTRYINDEX, event.selfRef);
                int err = lua_pcall(L, 1, 0, 0);
                if (err != 0) {
                    NSLog(@"Error executing event handler");
                }
                
                
            } else { // table or user data
                const char *ename = [event.name UTF8String];
                //NSLog(@"Event handler is a table");
                lua_getfield(L, -1, ename);
                if(lua_isnil(L, -1)){
                    //NSLog(@"lua_getfield for %s returned nil", ename);
                }
                lua_insert(L, -2);
                lua_rawgeti(L, LUA_REGISTRYINDEX, event.selfRef);
                lua_pcall(L, 2, 0, 0);
            }
            
            // empty the stack
            lua_pop(L, lua_gettop(L));
            
        }
        //NSLog(@"GemniObject handled event %@", event.name);
        return YES;
    }
    
    return NO;
}

// add an event listener to this object
-(void)addEventListener:(int)callback forEvent:(NSString *)event {
    NSLog(@"GeminiObject adding event listener for %@", event);
    NSMutableArray *handler = (NSMutableArray *)[eventHandlers objectForKey:event];
    if (handler == nil) {
        handler = [[[NSMutableArray alloc] initWithCapacity:1] autorelease];
        [eventHandlers setObject:handler forKey:event];
    }
    
    [handler addObject:[NSNumber numberWithInt:callback]];
}

// remove an event listener for this object
-(void)removeEventListener:(int)callback forEvent:(NSString *)event {
    NSMutableArray *handler = (NSMutableArray *)[eventHandlers objectForKey:event];
    if (handler != nil) {
        [handler removeObjectIdenticalTo:[NSNumber numberWithInt:callback]];
    }
}


@end

