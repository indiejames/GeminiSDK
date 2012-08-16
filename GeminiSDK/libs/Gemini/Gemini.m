//
//  Gemini.m
//  Gemini
//
//  Created by James Norton on 2/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Gemini.h"


#import "ObjectAL.h"
#import "GemEvent.h"
#import "GemObject.h"
#import "GemGLKViewController.h"
#import "GemDisplayObject.h"
#import "LGeminiObject.h"
#import "LGeminiDisplay.h"
#import "GemTransitionManager.h"

Gemini *singleton = nil;

@interface Gemini () {
@private
    lua_State *L;
    NSDictionary *config;
    GemGLKViewController *viewController;
    int x;
    double initTime;
    GemObject *runtime;
}
@end


@implementation Gemini

//@synthesize L;
@synthesize geminiObjects;
@synthesize viewController;
@synthesize initTime;

int setLuaPath(lua_State *L, NSString* path );

// add a global Runtime object
-(void) addRuntimeObject {
    
    runtime = [[GemObject alloc] initWithLuaState:L];
    
    GemObject **lgo = (GemObject **)lua_newuserdata(L, sizeof(GemObject *));
    *lgo = runtime;
    
    luaL_getmetatable(L, GEMINI_OBJECT_LUA_KEY);
    lua_setmetatable(L, -2);
    
    lua_newtable(L);
    lua_pushvalue(L, -1); // make a copy of the table becaue the next line pops the top value
    // store a reference to this table so our sprite methods can access it
    runtime.propertyTableRef = luaL_ref(L, LUA_REGISTRYINDEX);
    lua_setuservalue(L, -2);
    
    lua_pushvalue(L, -1); // make another copy of the userdata since the next line will pop it off
    runtime.selfRef = luaL_ref(L, LUA_REGISTRYINDEX);
    
    // create an entry in the global table
    lua_setglobal(L, "Runtime");
    
    // empty the stack
    lua_pop(L, lua_gettop(L));
    
}

// setup global constants related to rendering
-(void) setupGlobalConstants {
    // GL blending constants
    lua_pushinteger(L, GL_SRC_ALPHA);
    lua_setglobal(L, "GL_SRC_ALPHA");
    lua_pushinteger(L, GL_ONE_MINUS_SRC_ALPHA);
    lua_setglobal(L, "GL_ONE_MINUS_SRC_ALPHA");
    lua_pushinteger(L, GL_ONE);
    lua_setglobal(L, "GL_ONE");
    lua_pushinteger(L, GL_ZERO);
    lua_setglobal(L, "GL_ZERO");
}


- (id)init
{
    
   /* GeminiDisplayObject *dob = [[GeminiDisplayObject alloc] init];
    dob.x = 10.0;
    dob.y = 10.0;
    dob.rotation = M_PI / 2.0;
    GLKVector4 vec = GLKVector4Make(dob.x, dob.y, 0, 1.0);
    GLKVector4 vec2 = GLKMatrix4MultiplyVector4(dob.transform, vec);
    NSLog(@"vec2 = (%f,%f,%f)", vec2.x,vec2.y,vec2.z);*/
    
    self = [super init];
    if (self) {
        initTime = [NSDate timeIntervalSinceReferenceDate];
        config = [self readPlist:@"gemini"];
        geminiObjects = [[NSMutableArray alloc] initWithCapacity:1];
        //viewController = [[GeminiGLKViewController alloc] init];
        L = luaL_newstate();
        luaL_openlibs(L);
        viewController = [[GemGLKViewController alloc] initWithLuaState:L];
        
    }
    
    return self;
}

+(Gemini *)shared {
    
    if (singleton == nil) {
        singleton = [[Gemini alloc] init];
        [singleton addRuntimeObject];
        [singleton setupGlobalConstants];
        
    }
    
    return singleton;
}


- (id)readPlist:(NSString *)fileName {  
    NSData *plistData;  
    NSString *error;  
    NSPropertyListFormat format;  
    NSDictionary *plist;  
    
    NSString *localizedPath = [[NSBundle mainBundle] pathForResource:fileName ofType:@"plist"];  
    plistData = [NSData dataWithContentsOfFile:localizedPath];   
    
    plist = [NSPropertyListSerialization propertyListFromData:plistData mutabilityOption:NSPropertyListImmutable format:&format errorDescription:&error];  
    if (!plist) {  
        NSLog(@"Error reading plist from file '%s', error = '%s'", [localizedPath UTF8String], [error UTF8String]);  
        [error release];  
    }  
    
    return plist;  
}  


-(void)fireTimer {
    //GeminiEvent *event = [[GeminiEvent alloc] init];
    //event.name = @"timer";
    // TODO - finish this
    
}

-(void)execute:(NSString *)filename {
    int err;
    
	lua_settop(L, 0);
    
    NSString *luaFilePath = [[NSBundle mainBundle] pathForResource:filename ofType:@"lua"];
  
    setLuaPath(L, [luaFilePath stringByDeletingLastPathComponent]);
    
    err = luaL_loadfile(L, [luaFilePath cStringUsingEncoding:[NSString defaultCStringEncoding]]);
	
	if (0 != err) {
        luaL_error(L, "cannot compile lua file: %s",
                   lua_tostring(L, -1));
		return;
	}
    
	
    err = lua_pcall(L, 0, 0, 0);
	if (0 != err) {
		luaL_error(L, "cannot run lua file: %s",
                   lua_tostring(L, -1));
		return;
	}
    
   /* NSTimer *timer = [NSTimer timerWithTimeInterval:2 target:self selector:@selector(fireTimer) userInfo:nil repeats:YES];
    [timer retain];*/
}

-(BOOL)handleEvent:(NSString *)event {
    NSLog(@"Gemini handling event %@", event);
    GemEvent *ge = [[GemEvent alloc] initWithLuaState:L Source:nil];
    ge.name = event;
    
    for (id gemObj in geminiObjects) {
        if ([(GemObject *)gemObj handleEvent:ge]) {
            [ge release];
            return YES;
        }
    }
    
    [ge release];
    
    return NO;
}

// the global update method - called from the GeminiGLKViewController update method
// deltaT - time in seconds since last update
-(void) update:(double)deltaT {
    
    // update transitions
    [[GemTransitionManager shared] processTransitions:deltaT];
    
    GemEvent *enterFrameEvent = [[GemEvent alloc] initWithLuaState:L Source:nil];
    enterFrameEvent.name = @"enterFrame";
    [runtime handleEvent:enterFrameEvent];
    [enterFrameEvent release];
    
}

// makes it possible for Lua to load files on iOS
int setLuaPath(lua_State *L, NSString* path )  
{
    lua_getglobal( L, "package" );
    lua_getfield( L, -1, "path" ); // get field "path" from table at top of stack (-1)
    NSString * cur_path = [NSString stringWithUTF8String:lua_tostring( L, -1 )]; // grab path string from top of stack
    cur_path = [cur_path stringByAppendingString:@";"]; // do your path magic here
    cur_path = [cur_path stringByAppendingString:path];
    cur_path = [cur_path stringByAppendingString:@"/?.lua"];
    cur_path = [cur_path stringByAppendingString:@";"];
    cur_path = [cur_path stringByAppendingString:path];
    cur_path = [cur_path stringByAppendingString:@"/?"];
    lua_pop( L, 1 ); // get rid of the string on the stack we just pushed on line 5
    lua_pushstring( L, [cur_path UTF8String]); // push the new one
    lua_setfield( L, -2, "path" ); // set the field "path" in table at -2 with value at top of stack
    lua_pop( L, 1 ); // get rid of package table from top of stack
    return 0; // all done!
}



@end
