//
//  GemScene.h
//  GeminiSDK
//
//  Created by James Norton on 8/17/12.
//
//

#import <Foundation/Foundation.h>
#import "GemObject.h"
#import "GemLayer.h"

// event names
#define GEM_ENTER_SCENE_EVENT @"enterScene"
#define GEM_EXIT_SCENE_EVENT @"exitScene"

@interface GemScene : GemDisplayObject {
    NSMutableDictionary *layers;
    NSNumber *defaultLayerIndex;
    GLfloat zoom;
}

@property (readonly) NSMutableDictionary *layers;
@property (nonatomic) GLfloat zoom;

-(id)initWithLuaState:(lua_State *)_L;
-(id)initWithLuaState:(lua_State *)_L defaultLayerIndex:(int)index;
-(void)addLayer:(GemLayer *)layer;
-(void)addObject:(GemDisplayObject *)obj;
-(void)addObject:(GemDisplayObject *)obj toLayer:(int)layer;
-(void)addCallback:(void (*)(void))callback forLayer:(int)layer;
-(void)addScene:(GemScene *)scene;
-(int)numLayers;

@end
