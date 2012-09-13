//
//  GeminiObject.m
//  Gemini
//
//  Created by James Norton on 2/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Gemini.h"
#import "GemObject.h"
#import "GemEvent.h"


@implementation GemObject

@synthesize selfRef;
@synthesize propertyTableRef;
@synthesize eventListenerTableRef;
@synthesize L;
@synthesize name;



-(id) initWithLuaState:(lua_State *)luaState {
    self = [super init];
    if (self) {
        eventHandlers = [[NSMutableDictionary alloc] initWithCapacity:1];
        L = luaState;
        propertyTableRef = -1;
        eventListenerTableRef = -1;
        selfRef = -1;
    }
    
    return self;
}

// NOTE - this initializer will leave the object on the top of the Lua stack  - if this method was not
// invoked (indirectly) by Lua code, then the caller MUST empty the stack to avoid leaking
// memory.  This should only matter for the handful of GemObjects that get created manually.
// This behaviour is not completely desirable, but necessary to avoid a lot of complications.
-(id) initWithLuaState:(lua_State *)luaState LuaKey:(const char *)luaKey {
    self = [super init];
    if (self) {
        L = luaState;
        
        // sizeof(self) should give the size of this objects pointer (I hope)
        __unsafe_unretained GemObject **lgo = (__unsafe_unretained GemObject **)lua_newuserdata(L, sizeof(self));
        *lgo = self;
        
        luaL_getmetatable(L, luaKey);
        lua_setmetatable(L, -2);
        
        // append a lua table to this user data to allow the user to store values in it
        lua_newtable(L);
        lua_pushvalue(L, -1); // make a copy of the table becaue the next line pops the top value
        // store a reference to this table so our object methods can access it
        propertyTableRef = luaL_ref(L, LUA_REGISTRYINDEX);
        
        // set the table as the user value for the Lua object
        lua_setuservalue(L, -2);
        
        // create a table for the event listeners
        lua_newtable(L);
        eventListenerTableRef = luaL_ref(L, LUA_REGISTRYINDEX);
        
        lua_pushvalue(L, -1); // make another copy of the userdata since the next line will pop it off
        selfRef = luaL_ref(L, LUA_REGISTRYINDEX);
        
        // NOTE - at this point the object is on the top of the Lua stack  - if this method was not
        // invoked (indirectly) by Lua code, then the caller MUST empty the stack to avoid leaking
        // memory.  This should only matter for the handful of GemObjects that get created manually.
        // This behaviour is not completely desirable, but necessary to avoid a lot of complications.
        
    }
    
    return self;
}


-(void) dealloc {
    // release our property table so it can be GC by Lua
    if (propertyTableRef != -1) {
        luaL_unref(L, LUA_REGISTRYINDEX, propertyTableRef);
    }
    
    // release our event listener/handler table so it can by GC by Lua
    if (eventListenerTableRef != -1) {
        luaL_unref(L, LUA_REGISTRYINDEX, eventListenerTableRef);
    }
    
    
    // release our reference to ourself so we can be GC by Lua
    if (selfRef != -1) {
        luaL_unref(L, LUA_REGISTRYINDEX, selfRef);
    }
    
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
    if ([event.name isEqualToString:@"GEM_TIMER_EVENT"]) {
        GemLog(@"GemObject: handling event %@", event.name);

    }

    
    // get the full event handler table
    lua_rawgeti(L, LUA_REGISTRYINDEX, eventListenerTableRef);
    // get the event handlers for this event
    lua_getfield(L, -1, [event.name UTF8String]);
    // call all the listeners
    if (!lua_isnil(L, -1)) {
        lua_pushnil(L); // start at first key in table
        while(lua_next(L, -2) != 0){
            // key is at -2, value (lua ref) is at -1
            // get the function/table using the ref
            int ref = lua_tointeger(L, -1);
            lua_rawgeti(L, LUA_REGISTRYINDEX, ref);
            
            if (lua_isfunction(L, -1)) {
                //NSLog(@"Event handler is a function");
                // load the stacktrace printer for our error function
                int base = lua_gettop(L);  /* function index */
                lua_pushcfunction(L, traceback);  /* push traceback function */
                lua_insert(L, base);  /* put it under chunk and args */
                
                // push the event object onto the top of the stack as the argument to the event handler
                lua_rawgeti(L, LUA_REGISTRYINDEX, event.selfRef);
                int err = lua_pcall(L, 1, 0, -3);
                if (err != 0) {
                    const char *msg = lua_tostring(L, -1);
                    GemLog(@"Error executing event handler: %s", msg);
                }
                
                // leave the key on the stack for the next iteration
                lua_pop(L, 2);
                
            } else { // table or user data
                BOOL userData = NO;
                if (lua_isuserdata(L, -1)) {
                    // methods on a userdata expect the userdata to be the first argument
                    userData = YES;
                }
                
                const char *ename = [event.name UTF8String];
                
                int top = lua_gettop(L);
                                
                int base = lua_gettop(L);  /* table index */
                lua_pushcfunction(L, traceback);  /* push traceback function */
                lua_insert(L, base);  /* put it under handler */
                
                lua_getfield(L, -1, ename);
                
                if (userData) {
                    // need to push the userdata on the stack since the function will expect it as
                    // the first argument
                    lua_pushvalue(L, -2);
                }
                
                //lua_insert(L, -2); // move callback below 1st parameter
                lua_rawgeti(L, LUA_REGISTRYINDEX, event.selfRef); // add the event as the second param
                
                int err = 0;
                if (userData) {
                    err = lua_pcall(L, 2, 0, -5);
                } else {
                    err = lua_pcall(L, 1, 0, -4);
                }
                
                if (err != 0) {
                    const char *msg = lua_tostring(L, -1);
                    GemLog(@"Error executing event handler: %s", msg);
                }
                
                int pop = lua_gettop(L) - top + 2;
                
                lua_pop(L, pop);
            }
            
            
        }

    }
        
    
    /*NSArray *callbacks = (NSMutableArray *)[eventHandlers objectForKey:event.name];
        
    if ([callbacks count] > 0) {
        for (int i=0; i<[callbacks count]; i++) {
            
            NSNumber *callback = (NSNumber *)[callbacks objectAtIndex:i];
            int registryKey = [callback intValue];
            lua_rawgeti(L, LUA_REGISTRYINDEX, registryKey);
            
            if (lua_isfunction(L, -1)) {
                //NSLog(@"Event handler is a function");
                // load the stacktrace printer for our error function
                lua_getglobal(L, "gemini_stacktrace_printer");
                if (lua_isnil(L, -1)) {
                    NSLog(@"Error loading stacktrace_printer function");
                    
                }
               
    
                // copy our pointer to our function to top of stack
                lua_copy(L, -2, -1);
                // push the event object onto the top of the stack as the argument to the event handler
                lua_rawgeti(L, LUA_REGISTRYINDEX, event.selfRef);
                int err = lua_pcall(L, 1, 0, 0);
                if (err != 0) {
                    const char *msg = lua_tostring(L, -1);
                    NSLog(@"Error executing event handler: %s", msg);
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
    } */
    
    return NO;
}

// add an event listener to this object
/*-(void)addEventListener:(int)callback forEvent:(NSString *)event {
    NSLog(@"GemObject adding event listener for %@", event);
    
    
    // get the event handler table
    lua_rawgeti(L, LUA_REGISTRYINDEX, eventListenerTableRef);
    // get the event handlers for this event
    lua_getfield(L, -1, [event UTF8String]);

    if (lua_istable(L, -1)) {
        //int index = lua_objlen(L, -1);
        //lua_pushinteger(L, index);
        lua_len(L, -1);
        lua_pushvalue(L, -4);
        lua_settable(L, -4);
    } else {
        lua_pushstring(L,[event UTF8String]);
        lua_newtable(L);
        lua_settable(L, -4);
        lua_getfield(L, -2, [event UTF8String]);
        lua_pushinteger(L, 1);
        lua_pushvalue(L, 3);
    }
}*/

// remove an event listener for this object
/*-(void)removeEventListener:(int)callback forEvent:(NSString *)event {
    GemLog(@"GemObject: removing event listener for %@", event);
    GemLog(@"GemObject: registered handlers:");
    
    NSMutableArray *handler = (NSMutableArray *)[eventHandlers objectForKey:event];
    if (handler != nil) {
        for (int i=0; i<[handler count]; i++) {
            NSNumber *h = [handler objectAtIndex:i];
            GemLog(@"\t\t%d",[h intValue]);
        }
        [handler removeObject:[NSNumber numberWithInt:callback]];
    }
}*/


@end

