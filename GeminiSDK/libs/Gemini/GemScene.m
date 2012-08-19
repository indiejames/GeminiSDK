//
//  GemScene.m
//  GeminiSDK
//
//  Created by James Norton on 8/17/12.
//
//

#import "GemScene.h"

@implementation GemScene
@synthesize layers;

-(id)initWithLuaState:(lua_State *)_L {
    self = [super initWithLuaState:_L];
    if (self) {
        layers = [[NSMutableDictionary alloc] initWithCapacity:1];
        // create a default layer 0
        GemLayer *zero = [[GemLayer alloc] initWithLuaState:_L];
        [layers setObject:zero forKey:[NSNumber numberWithInt:0]];
        
    }
    
    return self;
}

// add a new layer
-(void)addLayer:(GemLayer *)layer {
    NSLog(@"GemScene adding layer with index %d", layer.index);
    [layers setObject:layer forKey:[NSNumber numberWithInt:layer.index]];
}


// add a display object to the default layer (layer 0)
-(void)addObject:(GemDisplayObject *)obj {
    NSLog(@"GemScene adding object");
    
    // get the default layer on the stage
    NSNumber *layerIndex = [NSNumber numberWithInt:0];
    GemLayer *layerGroup = (GemLayer *)[layers objectForKey:layerIndex];
    // remove from previous layer (if any) first
    [obj.layer remove:obj];
    obj.layer = layerGroup;
    [layerGroup insert:obj];
    
}


// add a display object to a given layer.  create the layer
// if it does not already exist
-(void)addObject:(GemDisplayObject *)obj toLayer:(int)layer {
    NSLog(@"GemScene adding object");
    // get the layer
    GemLayer *layerGroup = (GemLayer *)[layers objectForKey:[NSNumber numberWithInt:layer]];
    if (layerGroup == nil) {
        NSLog(@"GeminiRenderer layer is nil");
        layerGroup = [[[GemLayer alloc] initWithLuaState:((GemDisplayObject *)obj).L] autorelease];
        layerGroup.index = layer;
        NSLog(@"GeminiRenderer created new layer");
        [layers setObject:layerGroup forKey:[NSNumber numberWithInt:layer]];
    }
    NSLog(@"Inserting object into layer %d", layer);
    // remove from previous layer (if any) first
    [obj.layer remove:obj];
    obj.layer = layerGroup;
    [layerGroup insert:obj];
    
}

// allow the client to register a callback to render for a particular layer
-(void)addCallback:(void (*)(void))callback forLayer:(int)layer {
   
    NSValue *sel = [NSValue valueWithPointer:callback];
    [layers setObject:sel forKey:[NSNumber numberWithInt:layer]];
}

@end
