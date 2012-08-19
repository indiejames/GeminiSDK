//
//  GemDirector.m
//  GeminiSDK
//
//  Created by James Norton on 8/17/12.
//
//

#import "GemDirector.h"

@implementation GemDirector

-(id)initWithLuaState:(lua_State *)luaState {
    self = [super initWithLuaState:luaState];
    
    if (self) {
        GemScene *defaultScene = [[GemScene alloc] initWithLuaState:L];
        scenes = [[NSMutableDictionary alloc] initWithCapacity:1];
        [scenes setValue:defaultScene forKey:GEM_DEFAULT_SCENE];
        transitions = [[NSMutableDictionary alloc] initWithCapacity:1];
        currentScene = GEM_DEFAULT_SCENE;
        [currentScene retain];
    }
    
    return self;
}

-(void)gotoScene:(NSString *)scene withOptions:(NSDictionary *)options{
    currentTransition = (GemSceneTransition *)[transitions objectForKey:(NSString *)[options objectForKey:@"transition"]]; // TODO replace this hard-coded string
    currentTransition.sceneA = [self getCurrentScene];
    currentTransition.sceneA = (GemScene *)[scenes objectForKey:scene];
    
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


@end
