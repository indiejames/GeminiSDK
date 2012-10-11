//
//  GemDirector.m
//  GeminiSDK
//
//  Created by James Norton on 8/17/12.
//
//

#import "GemDirector.h"
#import "Gemini.h"
#import "LGeminiDirector.h"
#import "GemEvent.h"
#import "LGeminiLuaSupport.h"
#import "Gemini.h"
#import "GemGLKViewController.h"
#import "GemFileNameResolver.h"
#import "GemFadeSceneTransition.h"
#import "GemSlideSceneTransition.h"
#import "GemPageTurnSceneTransition.h"

@implementation GemDirector
@synthesize renderer;

int render_count = 0;

-(id)initWithLuaState:(lua_State *)luaState {
    self = [super initWithLuaState:luaState];
    
    if (self) {
        renderer = [[GemRenderer alloc] initWithLuaState:L];
        GemScene *defaultScene = createDefaultScene(L);
        scenes = [[NSMutableDictionary alloc] initWithCapacity:1];
        [scenes setValue:defaultScene forKey:GEM_DEFAULT_SCENE];
        allScenes = [[NSMutableArray alloc] initWithCapacity:1];
        transitions = [[NSMutableDictionary alloc] initWithCapacity:1];
        currentScene = GEM_DEFAULT_SCENE;
        GemSceneTransition *transition = [[GemSlideSceneTransition alloc] initWithParams:nil];
        
        [transitions setObject:transition forKey:@"GEM_SLIDE_SCENE_TRANSITION"];
        
        GemSceneTransition *curl = [[GemPageTurnSceneTransition alloc] initWithParams:nil];
        [transitions setObject:curl forKey:@"GEM_PAGE_TURN_SCENE_TRANSITION"];
    }
    
    return self;
}

static GemScene * createDefaultScene(lua_State *L){
    GemScene *defaultScene = [[GemScene alloc] initWithLuaState:L defaultLayerIndex:GEM_DEFAULT_SCENE_DEFAULT_LAYER_INDEX];
    defaultScene.name = GEM_DEFAULT_SCENE;
    
    //__unsafe_unretained GemScene **lScene = (__unsafe_unretained GemScene **)lua_newuserdata(L, sizeof(GemScene *));
    //*lScene = defaultScene;
    
    //setupObject(L, GEMINI_SCENE_LUA_KEY, defaultScene);
    
    return defaultScene;
}

-(void)addScene:(GemScene *)scene {
    [allScenes addObject:scene];
}

-(void)gotoScene:(NSString *)scene withOptions:(NSDictionary *)options{
    
    // load the scene if it is not already loaded
    if ([scenes objectForKey:scene] == nil) {
        [self loadScene:scene];
    }
    
    GemScene *cScene = [scenes objectForKey:currentScene];
    
    if (cScene != nil && ![cScene.name isEqualToString:GEM_DEFAULT_SCENE]) {
        GemEvent *exitEvent = [[GemEvent alloc] initWithLuaState:L Target:cScene];
        exitEvent.name = GEM_EXIT_SCENE_EVENT;
        [cScene handleEvent:exitEvent];
        
        
        NSString *transitionStr = [options objectForKey:@"transition"];
        if (transitionStr == nil) {
            transitionStr = @"GEM_DEFAULT_TRANSITION";
        }
        
        GemLog(@"Going to scene %@ with transition %@", scene, transitionStr);
        
        
        GemSceneTransition *transition = [transitions objectForKey:transitionStr];
        if (transition == nil) {
            if ([transitionStr isEqualToString:@"GEM_SLIDE_SCENE_TRANSITION"]) {
                transition = [[GemSlideSceneTransition alloc] initWithParams:options];
            } else if ([transitionStr isEqualToString:@"GEM_PAGE_TURN_SCENE_TRANSITION"]){
                transition = [[GemPageTurnSceneTransition alloc] initWithParams:options];
                transition.duration = 3.0;
            } else {
                transition = [[GemSlideSceneTransition alloc] initWithParams:options];
                transition.duration = 3.0;
                
            }
            
            [transitions setObject:transition forKey:transitionStr];
        } else {
            transition.params = options;
            [transition reset];
        }
        
        
        transition.sceneA = cScene;
        transition.sceneB = [scenes objectForKey:scene];
        currentTransition = transition;

    } else {
        [self setCurrentScene:scene];
        
        GemScene *gemScene = [scenes objectForKey:scene];
        
        GemEvent *event = [[GemEvent alloc] initWithLuaState:L Target:gemScene];
        event.name = GEM_ENTER_SCENE_EVENT;
        
        [gemScene handleEvent:event];
    }

}

-(void)loadScene:(NSString *)sceneName {
    // don't load the scene if it is already in our cache
    if ([scenes objectForKey:sceneName] == nil) {
        int err;
        
        lua_settop(L, 0);
        
        // set our error handler function
        lua_pushcfunction(L, traceback);
        
        GemFileNameResolver *resolver = [Gemini shared].fileNameResolver;
        
        NSString *resolvedFileName = [resolver resolveNameForFile:sceneName ofType:@"lua"];
        
        NSString *luaFilePath = [[NSBundle mainBundle] pathForResource:resolvedFileName ofType:@"lua"];
        
        err = luaL_loadfile(L, [luaFilePath cStringUsingEncoding:[NSString defaultCStringEncoding]]);
        
        if (0 != err) {
            luaL_error(L, "cannot compile lua file: %s",
                       lua_tostring(L, -1));
            return;
        }
        
        
        err = lua_pcall(L, 0, 1, 1);
        if (0 != err) {
            luaL_error(L, "cannot run lua file: %s",
                       lua_tostring(L, -1));
            return;
        }
        
        // The scene should now be on the top of the stack
        __unsafe_unretained GemScene **lscene = (__unsafe_unretained GemScene **)luaL_checkudata(L, -1, GEMINI_SCENE_LUA_KEY);
        GemScene *scene = *lscene;
        scene.name = sceneName;
        [scenes setObject:scene forKey:sceneName];
        
        // this gets a pointer to the "createScene" method on the new scene
        lua_getfield(L, -1, "createScene");
        
        // duplicate the scene on top of th stack since it is the first param of the createScene method
        lua_pushvalue(L, -2);
        lua_pcall(L, 1, 0, 0);
        
        lua_settop(L, 0);
    }
    
}

-(void)destroyScene:(NSString *)sceneName {
    GemScene *scene = [scenes objectForKey:sceneName];
    [allScenes removeObject:scene];
    
}

-(void)setCurrentScene:(NSString *)scene {
    
    currentScene = scene;
  
}

-(GemScene *)getCurrentScene {
    return (GemScene *)[scenes objectForKey:currentScene];
}

-(GemScene *)getDefaultScene {
    return (GemScene *)[scenes objectForKey:GEM_DEFAULT_SCENE];
}

-(void)render:(double)timeSinceLastRender {
    /*if (render_count == 300) {
        [self gotoScene:@"scene2" withOptions:nil];
    }*/
    
    
    if (render_count % 300 == 0) {
        NSLog(@"Current scene is %@", ((GemScene *)[scenes objectForKey:currentScene]).name);
        render_count = 0;
        //lua_gc(L, LUA_GCCOLLECT, 0);
    }
    
    render_count++;
    
    // handle transitions
    if (currentTransition != nil) {
        // let the transitions do the render
        if ([currentTransition transit:timeSinceLastRender]) {
            // transition is over
            GemLog(@"Scene is over!");
            currentScene = currentTransition.sceneB.name;
            GemScene *gemScene = [scenes objectForKey:currentScene];
            
            GemEvent *event = [[GemEvent alloc] initWithLuaState:L Target:gemScene];
            event.name = GEM_ENTER_SCENE_EVENT;
            
            [gemScene handleEvent:event];
            
            currentTransition = nil;

        }
        
    } else {
        GemScene *tempScene = [[GemScene alloc] initWithLuaState:L];
        tempScene.name = @"TEMP_SCENE";
        [tempScene addScene:[scenes objectForKey:GEM_DEFAULT_SCENE]];
        if (![currentScene isEqualToString:GEM_DEFAULT_SCENE]) {
                        
            [tempScene addScene:[scenes objectForKey:currentScene]];
        }
        [renderer renderScene:tempScene];
        
    }
}

// choose the best file based on name and device type
NSString *resolveFileName(NSString *fileName){
    NSArray *fileSuffixArray = [fileName componentsSeparatedByString:@"."];
    NSString *base = [fileSuffixArray objectAtIndex:0];
    NSString *suffix = [fileSuffixArray objectAtIndex:1];
    
    NSString *rval = nil;
    
    switch (((GemGLKViewController *)([Gemini shared].viewController)).displayType) {
        case GEM_IPHONE:
            rval = fileName;
            break;
        case GEM_IPHONE_RETINA:
            rval = [[base stringByAppendingString:@"@retina"] stringByAppendingString:suffix];
            break;
        case GEM_IPHONE_5:
            break;
        case GEM_IPAD:
            break;
        case GEM_IPAD_RETINA:
            break;
        default:
            rval = fileName;
            break;
    }
    
    
    return rval;
}

@end
