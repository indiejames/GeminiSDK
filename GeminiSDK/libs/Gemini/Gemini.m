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
#import "GemPhysics.h"



@interface Gemini () {
@private
    lua_State *L;
    NSDictionary *settings;
    GemGLKViewController *viewController;
    int x;
    double initTime;
    GemObject *runtime;
    GemPhysics *physics;
    GemSoundManager *soundManager;
    GemFontManager *fontManager;
}
@end


@implementation Gemini

//@synthesize L;
@synthesize geminiObjects;
@synthesize viewController;
@synthesize initTime;
@synthesize physics;
@synthesize fileNameResolver;
@synthesize settings;
@synthesize soundManager;
@synthesize fontManager;

int setLuaPath(lua_State *L, NSString* path );

// add a global Runtime object
-(void) addRuntimeObject {
    
    runtime = [[GemObject alloc] initWithLuaState:L];
    runtime.name = @"Runtime";
    
    __unsafe_unretained GemObject **lgo = (__unsafe_unretained GemObject **)lua_newuserdata(L, sizeof(GemObject *));
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
    
    // create a table for the event listeners
    lua_newtable(L);
    runtime.eventListenerTableRef = luaL_ref(L, LUA_REGISTRYINDEX);
    
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
    
    // physics draw modes
    lua_pushinteger(L, GEM_PHYSICS_DEBUG);
    lua_setglobal(L, "RENDER_DEBUG");
    lua_pushinteger(L, GEM_PHYSICS_NORMAL);
    lua_setglobal(L, "RENDER_NORMAL");
    lua_pushinteger(L, GEM_PHYSICS_HYBRID);
    lua_setglobal(L, "RENDER_HYBRID");
    
    // keyboard types
    lua_pushinteger(L, UIKeyboardTypeDefault); // Default type for the current input method.
    lua_setglobal(L,"UIKeyboardTypeDefault");
    lua_pushinteger(L, UIKeyboardTypeASCIICapable); // Displays a keyboard which can enter ASCII characters, non-ASCII keyboards remain active
    lua_setglobal(L,"UIKeyboardTypeASCIICapable");
    lua_pushinteger(L, UIKeyboardTypeNumbersAndPunctuation);  // Numbers and assorted punctuation.
    lua_setglobal(L,"UIKeyboardTypeNumbersAndPunctuation");
    lua_pushinteger(L, UIKeyboardTypeURL); // A type optimized for URL entry (shows . / .com prominently).
    lua_setglobal(L, "UIKeyboardTypeURL");
    lua_pushinteger(L, UIKeyboardTypeNumberPad); // A number pad (0-9). Suitable for PIN entry.
    lua_setglobal(L, "UIKeyboardTypeNumberPad");
    lua_pushinteger(L, UIKeyboardTypePhonePad); // A phone pad (1-9, *, 0, #, with letters under the numbers).
    lua_setglobal(L, "UIKeyboardTypePhonePad");
    lua_pushinteger(L, UIKeyboardTypeNamePhonePad); // A type optimized for entering a person's name or phone number.
    lua_setglobal(L, "UIKeyboardTypeNamePhonePad");
    lua_pushinteger(L, UIKeyboardTypeEmailAddress); // A type optimized for multiple email address entry (shows space @ . prominently).
    lua_setglobal(L, "UIKeyboardTypeEmailAddress");
    
    lua_settop(L, 0);
}

// setup the global error function that will print a stack trace on errors
/*-(void)registerErrorFunc {

    luaL_loadbuffer(L, errorFunc, strlen(errorFunc), "errorHandler");
    int err = lua_pcall(L, 0, 0, 0);
    if (err == 0) {
        GemLog(@"Gemini: Global error function set");
    } else {
        GemLog(@"Gemini: error setting up global error function");
    }
    lua_settop(L, 0);
}*/


- (id)init
{    
    self = [super init];
    if (self) {
        initTime = [NSDate timeIntervalSinceReferenceDate];
        float scale = [UIScreen mainScreen].scale;
        CGSize bounds = [[UIScreen mainScreen] bounds].size;
        int w = bounds.width * scale;
        int h = bounds.height * scale;
        
        NSString *localizedPath = [[NSBundle mainBundle] pathForResource:@"gemini" ofType:@"plist"];
        //NSString *myId = [NSString stringWithFormat:@"%dx%d",w,h];
        NSString *myId = [NSString stringWithFormat:@"%dx%d",w,h];
        NSDictionary *plist = [[NSDictionary alloc] initWithContentsOfFile:localizedPath];
        
        settings = [plist objectForKey:myId];
        
        fileNameResolver = [[GemFileNameResolver alloc] initForWidth:bounds.width Height:bounds.height ContentScale:scale Settings:plist];
                
        geminiObjects = [[NSMutableArray alloc] initWithCapacity:1];
        //viewController = [[GeminiGLKViewController alloc] init];
        L = luaL_newstate();
        luaL_openlibs(L);
        viewController = [[GemGLKViewController alloc] initWithLuaState:L];
        physics = [[GemPhysics alloc] init];
        float screenWidth = scale * bounds.width;
        float physScale = 50.0 * screenWidth / 320.0;
        [physics setScale:physScale];
        
        soundManager = [[GemSoundManager alloc] init];
        
        fontManager = [[GemFontManager alloc] init];
        
    }
    
    return self;
}

+(Gemini *)shared {
    static Gemini *singleton = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        singleton = [[Gemini alloc] init];
        [singleton addRuntimeObject];
        [singleton setupGlobalConstants];
    });
        
    return singleton;
}


-(void)fireTimer {
    //GeminiEvent *event = [[GeminiEvent alloc] init];
    //event.name = @"timer";
    // TODO - finish this
    
}

-(void)execute:(NSString *)filename {
    int err;
    
	lua_settop(L, 0);
    
    lua_pushcfunction(L, traceback);
    
    NSString *resolvedFileName = [fileNameResolver resolveNameForFile:filename ofType:@"lua"];
    
    NSString *luaFilePath = [[NSBundle mainBundle] pathForResource:resolvedFileName ofType:@"lua"];
  
    setLuaPath(L, [luaFilePath stringByDeletingLastPathComponent]);
    
    err = luaL_loadfile(L, [luaFilePath cStringUsingEncoding:[NSString defaultCStringEncoding]]);
	
	if (0 != err) {
        luaL_error(L, "cannot compile lua file: %s",
                   lua_tostring(L, -1));
		return;
	}
    
	
    err = lua_pcall(L, 0, 0, 1);
	if (0 != err) {
		luaL_error(L, "cannot run lua file: %s",
                   lua_tostring(L, -1));
		return;
	}
    
   /* NSTimer *timer = [NSTimer timerWithTimeInterval:2 target:self selector:@selector(fireTimer) userInfo:nil repeats:YES];
    [timer retain];*/
}

/*-(BOOL)handleEvent:(NSString *)event {
    GemLog(@"Gemini handling event %@", event);
    GemEvent *ge = [[GemEvent alloc] initWithLuaState:L Target:nil Event:nil];
    ge.name = event;
    
    for (id gemObj in geminiObjects) {
        if ([(GemObject *)gemObj handleEvent:ge]) {
            
            return YES;
        }
    }
    
    
    return NO;
}*/

-(void)handleEvent:(GemEvent *)event {
    [runtime handleEvent:event];
}

-(void)applicationWillExit {
    GemEvent *exitEvent = [[GemEvent alloc] initWithLuaState:L Target:runtime];
    exitEvent.name = @"applicationWillExit";
    [runtime handleEvent:exitEvent];
}

-(void)applicationWillResignActive {
    
    GemEvent *exitEvent = [[GemEvent alloc] initWithLuaState:L Target:runtime];
    exitEvent.name = @"applicationWillResignActive";
    [runtime handleEvent:exitEvent];
}

- (void)applicationDidBecomeActive {
    GemEvent *exitEvent = [[GemEvent alloc] initWithLuaState:L Target:runtime];
    exitEvent.name = @"applicationDidBecomeActive";
    [runtime handleEvent:exitEvent];
}

-(void)applicationDidEnterBackground {
    GemEvent *exitEvent = [[GemEvent alloc] initWithLuaState:L Target:runtime];
    exitEvent.name = @"applicationDidEnterBackground";
    [runtime handleEvent:exitEvent];
}

-(void)applicationWillEnterForeground {
    GemEvent *exitEvent = [[GemEvent alloc] initWithLuaState:L Target:runtime];
    exitEvent.name = @"applicationWillEnterForeground";
    [runtime handleEvent:exitEvent];
}

// the global update method - called from the GeminiGLKViewController update method
// deltaT - time in seconds since last update
-(void) update:(double)deltaT {
    
    // do physics
    [physics update:deltaT];
    
    // update transitions
    [[GemTransitionManager shared] processTransitions:deltaT];
    
    GemEvent *enterFrameEvent = [[GemEvent alloc] initWithLuaState:L Target:runtime];
    enterFrameEvent.name = @"enterFrame";
    [runtime handleEvent:enterFrameEvent];
    
#ifdef GEM_DEBUG
    static int callCount = 0;
    
    if (callCount % 120 == 0) {
        callCount = 0;
        int kByteCount = lua_gc(L, LUA_GCCOUNT, 0);
        GemLog(@"Gemini: Lua is using %d Kb", kByteCount);
        lua_gc(L, LUA_GCCOLLECT, 0);
        lua_settop(L, 0);
    }
    
    callCount++;
#endif
    
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

// global error function for Lua scripts
int traceback (lua_State *L) {
    if (!lua_isstring(L, 1))  /* 'message' not a string? */
        return 1;  /* keep it intact */
    lua_getglobal(L, "debug");
    if (!lua_istable(L, -1)) {
        lua_pop(L, 1);
        return 1;
    }
    lua_getfield(L, -1, "traceback");
    if (!lua_isfunction(L, -1)) {
        lua_pop(L, 2);
        return 1;
    }
    lua_pushvalue(L, 1);  /* pass error message */
    lua_pushinteger(L, 2);  /* skip this function and traceback */
    lua_call(L, 2, 1);  /* call debug.traceback */
    return 1;
}
