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

@implementation GemDirector
@synthesize renderer;

int render_count = 0;

-(id)initWithLuaState:(lua_State *)luaState {
    self = [super initWithLuaState:luaState];
    
    if (self) {
        renderer = [[GemRenderer alloc] initWithLuaState:L];
        GemScene *defaultScene = [[GemScene alloc] initWithLuaState:L defaultLayerIndex:GEM_DEFAULT_SCENE_DEFAULT_LAYER_INDEX];
        defaultScene.name = @"DEFAULT_SCENE";
        scenes = [[NSMutableDictionary alloc] initWithCapacity:1];
        [scenes setValue:defaultScene forKey:GEM_DEFAULT_SCENE];
        transitions = [[NSMutableDictionary alloc] initWithCapacity:1];
        currentScene = GEM_DEFAULT_SCENE;
        [currentScene retain];
    }
    
    return self;
}


-(void)gotoScene:(NSString *)scene withOptions:(NSDictionary *)options{
    
    // load the scene if it is not already loaded
    if ([scenes objectForKey:scene] == nil) {
        [self loadScene:scene];
    }
    
    GemScene *cScene = [scenes objectForKey:currentScene];
    GemEvent *exitEvent = [[GemEvent alloc] initWithLuaState:L Source:cScene];
    exitEvent.name = GEM_EXIT_SCENE_EVENT;
    [cScene handleEvent:exitEvent];
    
    GemScene *gemScene = [scenes objectForKey:scene];

    GemEvent *event = [[GemEvent alloc] initWithLuaState:L Source:gemScene];
    event.name = GEM_ENTER_SCENE_EVENT;
    
    [gemScene handleEvent:event];
    
   /* currentTransition = (GemSceneTransition *)[transitions objectForKey:(NSString *)[options objectForKey:@"transition"]]; // TODO replace this hard-coded string
    currentTransition.sceneA = [self getCurrentScene];
    currentTransition.sceneA = (GemScene *)[scenes objectForKey:scene];
    */
    
    
    [self setCurrentScene:scene];

}

-(void)loadScene:(NSString *)sceneName {
    
    int err;
    
	lua_settop(L, 0);
    
    NSString *luaFilePath = [[NSBundle mainBundle] pathForResource:sceneName ofType:@"lua"];
    
    err = luaL_loadfile(L, [luaFilePath cStringUsingEncoding:[NSString defaultCStringEncoding]]);
	
	if (0 != err) {
        luaL_error(L, "cannot compile lua file: %s",
                   lua_tostring(L, -1));
		return;
	}
    
	
    err = lua_pcall(L, 0, 1, 0);
	if (0 != err) {
		luaL_error(L, "cannot run lua file: %s",
                   lua_tostring(L, -1));
		return;
	}
    
    // The scene should now be on the top of the stack
    GemScene **lscene = luaL_checkudata(L, -1, GEMINI_SCENE_LUA_KEY);
    GemScene *scene = *lscene;
    scene.name = sceneName;
    [scenes setObject:scene forKey:sceneName];
    
        
    lua_getfield(L, -1, "createScene");
    
    // duplicate the scene on top of th stack since it is the first param of the createScene method
    lua_pushvalue(L, -2);
    lua_pcall(L, 1, 0, 0);
    
    lua_settop(L, 0);
    
}

-(void)destroyScene:(NSString *)scene {
    
}

-(void)setCurrentScene:(NSString *)scene {
    [currentScene release];
    currentScene = scene;
    [currentScene retain];
}

-(GemScene *)getCurrentScene {
    return (GemScene *)[scenes objectForKey:currentScene];
}

-(void)render:(double)timeSinceLastRender {
    /*if (render_count == 300) {
        [self gotoScene:@"scene2" withOptions:nil];
    }*/

    render_count++;
    
    // handle transitions
    if (currentTransition != nil) {
        // let the transitions do the render
        if ([currentTransition transit:timeSinceLastRender]) {
            // transition is over
            currentTransition = nil;
        }
        
    } else {
        GemScene *tempScene = [[GemScene alloc] initWithLuaState:L];
        tempScene.name = @"TEMP_SCENE";
        [tempScene addScene:[scenes objectForKey:GEM_DEFAULT_SCENE]];
        if (![currentScene isEqualToString:GEM_DEFAULT_SCENE]) {
            //NSLog(@"current scene has %d layers", [[scenes objectForKey:currentScene] numLayers]);
            [tempScene addScene:[scenes objectForKey:currentScene]];
        }
        [renderer renderScene:tempScene];
        
        [tempScene release];
    }
}


@end
