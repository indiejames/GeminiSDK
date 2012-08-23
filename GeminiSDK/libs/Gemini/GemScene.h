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

@interface GemScene : GemDisplayObject {
    NSMutableDictionary *layers;
    NSNumber *defaultLayerIndex;
}

@property (readonly) NSMutableDictionary *layers;

-(id)initWithLuaState:(lua_State *)_L;
-(id)initWithLuaState:(lua_State *)_L defaultLayerIndex:(int)index;
-(void)addLayer:(GemLayer *)layer;
-(void)addObject:(GemDisplayObject *)obj;
-(void)addObject:(GemDisplayObject *)obj toLayer:(int)layer;
-(void)addCallback:(void (*)(void))callback forLayer:(int)layer;
-(void)addScene:(GemScene *)scene;
-(int)numLayers;

@end
