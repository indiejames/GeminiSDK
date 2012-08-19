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

@interface GemScene : GemObject {
    NSMutableDictionary *layers;
}

@property (readonly) NSMutableDictionary *layers;

-(void)addLayer:(GemLayer *)layer;
-(void)addObject:(GemDisplayObject *)obj;
-(void)addObject:(GemDisplayObject *)obj toLayer:(int)layer;
-(void)addCallback:(void (*)(void))callback forLayer:(int)layer;

@end
