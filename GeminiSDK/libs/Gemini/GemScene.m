//
//  GemScene.m
//  GeminiSDK
//
//  Created by James Norton on 8/17/12.
//
//

#import "GemScene.h"
#import "GemEvent.h" 
#import "LGeminiDirector.h"
#import "GLUtils.h"
#import "GemNativeTextField.h"
#import "GemNativeObject.h"
#import "Gemini.h"
#import "GemGLKViewController.h"

@implementation GemScene { 
    NSMutableDictionary *layers;
    NSNumber *defaultLayerIndex;
    GLfloat zoom;
    NSMutableArray *nativeObjects;
}

@synthesize layers;
@synthesize zoom;

// create a scene with no default layer
-(id)initWithLuaState:(lua_State *)_L {
    self = [super initWithLuaState:_L LuaKey:GEMINI_SCENE_LUA_KEY];
    if (self) {
        // preseve the stack
        int top = lua_gettop(L);
        layers = [[NSMutableDictionary alloc] initWithCapacity:1];
        nativeObjects = [[NSMutableArray alloc] initWithCapacity:1];
        int pop = lua_gettop(L) - top;
        lua_pop(L, pop);
        
        zoom = 1.0;
    }
    
    return self;
}

//////////////////////////////////////////////////////////////
///
//  FIX THIS
//
//  There is an issue with creating a layer object in the scene
//   after creating the scene object - the stack gets messed up
//
//////////////////////////////////////////////////////////////

// create a scene with a default layer at the given index
-(id)initWithLuaState:(lua_State *)_L defaultLayerIndex:(int)index {
    self = [super initWithLuaState:_L LuaKey:GEMINI_SCENE_LUA_KEY];
    if (self) {
        if (luaL_checkudata(L, -1, GEMINI_SCENE_LUA_KEY)) {
            GemLog(@"Userdata is a GemScene");
        } else {
            GemLog(@"USerdata is not a GemScene!!!");
        }
        // preseve the stack
        int top = lua_gettop(L);
        
        layers = [[NSMutableDictionary alloc] initWithCapacity:1];
        nativeObjects = [[NSMutableArray alloc] initWithCapacity:1];
        
        // create a default layer
        defaultLayerIndex = [NSNumber numberWithInt:index];
        
        GemLayer *defaultLayer = [[GemLayer alloc] initWithLuaState:_L];
        
        
        int pop = lua_gettop(L) - top;
        lua_pop(L, pop);
        
        [layers setObject:defaultLayer forKey:defaultLayerIndex];
        
        zoom = 1.0;
        
    }
    
    int top = lua_gettop(_L);
    GemLog(@"top = %d", top);
    
    if (luaL_checkudata(_L, -1, GEMINI_SCENE_LUA_KEY)) {
        GemLog(@"Userdata is a GemScene");
    } else {
        GemLog(@"USerdata is not a GemScene!!!");
    }
    
    return self;
}

-(void)dealloc {
    GemLog(@"Deallocing scene %@", self.name);
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


// add a display object to the default layer (layer 0) or to the list of native objects
-(void)addObject:(GemDisplayObject *)obj {
    GemLog(@"GemScene adding object to scene %@", self.name);
    
    if ([obj.class isSubclassOfClass:GemNativeObject.class]) {
        // native objects don't get added to a layer since they are always on top
        [nativeObjects addObject:obj];
    } else {
        // get the default layer on the stage
        GemLayer *layerGroup = (GemLayer *)[layers objectForKey:defaultLayerIndex];
        // remove from previous layer (if any) first
        [obj.layer remove:obj];
        obj.layer = layerGroup;
        [layerGroup insert:obj];

    }
    
        
}


// add a display object to a given layer or to the list of native objects.  create the layer
// if it does not already exist
-(void)addObject:(GemDisplayObject *)obj toLayer:(int)destLayer {
    GemLog(@"GemScene adding object");
    
    if ([obj.class isSubclassOfClass:GemNativeObject.class]) {
        // native objects don't get added to a layer since they are always on top
        [nativeObjects addObject:obj];
    } else {
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

-(void) setZoom:(GLfloat)z {
    
    if (z > 0) {
        
        // scale
        GLfloat scale = sqrtf(z);
        
        [self setXScale:scale];
        [self setYScale:scale];
        
        // translate
        GLKVector2 dim = getDimensionsFromSettings(YES);
        
        self.x = self.x + 0.5 * dim.x * (1.0 - scale);
        self.y = self.y + 0.5 * dim.y * (1.0 - scale);
        
        zoom = z;
        
    }     
    
}

-(BOOL)handleEvent:(GemEvent *)event {
    if ([event.name isEqualToString:GEM_DESTROY_SCENE_EVENT]) {
        /*// free all the objects in this scene
        NSArray *keys = [layers allKeys];
        for (int i=-0; i<[keys count]; i++) {
            NSNumber *key = [keys objectAtIndex:i];
            GemLayer *layer = [layers objectForKey:key];
            [layer.objects enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                GemDisplayObject *gemObj = (GemDisplayObject *)obj;
                if ([gemObj.class isSubclassOfClass:GemDisplayGroup.class]) {
                    
                }
            }];
        }*/
        
        // free any native objects in this scene
        [nativeObjects enumerateObjectsUsingBlock:^(id obj, NSUInteger index, BOOL *stop) {
            GemNativeObject *gemObj = (GemNativeObject *)obj;
            [gemObj.nativeObject removeFromSuperview];
        }];
    }

    return [super handleEvent:event];
}

@end
