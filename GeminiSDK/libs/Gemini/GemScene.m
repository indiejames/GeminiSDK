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

// create a scene with no default layer
-(id)initWithLuaState:(lua_State *)_L {
    self = [super initWithLuaState:_L];
    if (self) {
        layers = [[NSMutableDictionary alloc] initWithCapacity:1];
        
    }
    
    return self;
}

// create a scene with a default layer at the given index
-(id)initWithLuaState:(lua_State *)_L defaultLayerIndex:(int)index {
    self = [super initWithLuaState:_L];
    if (self) {
        layers = [[NSMutableDictionary alloc] initWithCapacity:1];
        // create a default layer
        defaultLayerIndex = [NSNumber numberWithInt:index];
        
        GemLayer *defaultLayer = [[GemLayer alloc] initWithLuaState:_L];
        [layers setObject:defaultLayer forKey:defaultLayerIndex];
        
    }
    
    return self;
}

// add a new layer
-(void)addLayer:(GemLayer *)newLayer {
    NSLog(@"GemScene %@ adding layer with index %d", self.name, newLayer.index);
    [newLayer.scene removeLayer:newLayer.index];
    newLayer.scene = self;
    [layers setObject:newLayer forKey:[NSNumber numberWithInt:newLayer.index]];
}
    
-(void)removeLayer:(int)layerIndex {
    [layers removeObjectForKey:[NSNumber numberWithInt:layerIndex]];
}


// add a display object to the default layer (layer 0)
-(void)addObject:(GemDisplayObject *)obj {
    NSLog(@"GemScene adding object to scene %@", self.name);
    
    // get the default layer on the stage
    GemLayer *layerGroup = (GemLayer *)[layers objectForKey:defaultLayerIndex];
    // remove from previous layer (if any) first
    [obj.layer remove:obj];
    obj.layer = layerGroup;
    [layerGroup insert:obj];
    
}


// add a display object to a given layer.  create the layer
// if it does not already exist
-(void)addObject:(GemDisplayObject *)obj toLayer:(int)destLayer {
    NSLog(@"GemScene adding object");
    // get the layer
    GemLayer *layerGroup = (GemLayer *)[layers objectForKey:[NSNumber numberWithInt:destLayer]];
    if (layerGroup == nil) {
        NSLog(@"GeminiRenderer layer is nil");
        layerGroup = [[GemLayer alloc] initWithLuaState:((GemDisplayObject *)obj).L];
        layerGroup.index = destLayer;
        NSLog(@"GeminiRenderer created new layer");
        [layers setObject:layerGroup forKey:[NSNumber numberWithInt:destLayer]];
    }
    NSLog(@"Inserting object into layer %d", destLayer);
    // remove from previous layer (if any) first
    [obj.layer remove:obj];
    obj.layer = layerGroup;
    [layerGroup insert:obj];
    
}

// allow the client to register a callback to render for a particular layer
-(void)addCallback:(void (*)(void))callback forLayer:(int)destLayer {
   
    NSValue *sel = [NSValue valueWithPointer:callback];
    [layers setObject:sel forKey:[NSNumber numberWithInt:destLayer]];
}

// add the layers from another scene to this scene
-(void)addScene:(GemScene *)scene {
    //NSLog(@"GemScene: adding %d layers from scene %@ to existing %d layers of scene %@", [scene numLayers], scene.name, [self numLayers], self.name);
    [layers addEntriesFromDictionary:scene.layers];
    //NSLog(@"GemScene: scene %@ now has %d layers", self.name, [self numLayers]);
}

-(int)numLayers {
    return [layers count];
}

@end
