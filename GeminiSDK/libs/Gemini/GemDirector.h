//
//  GemDirector.h
//  GeminiSDK
//
//  Created by James Norton on 8/17/12.
//
//  This class manages GemScenes 
//

#import <Foundation/Foundation.h>
#import "GemScene.h"
#import "GemSceneTransition.h"

#define GEM_DEFAULT_SCENE @"GEM_DEFAULT_SCENE"


@interface GemDirector : GemObject {
    NSMutableDictionary *scenes;
    NSString *currentScene;
    NSMutableDictionary *transitions;
    GemSceneTransition *currentTransition;
}

-(void)gotoScene:(NSString *)scene withOptions:(NSDictionary *)options;
-(void)destroyScene:(NSString *)scene;
-(GemScene *)getCurrentScene;
-(void)setCurrentScene:(NSString *)scene;


@end
