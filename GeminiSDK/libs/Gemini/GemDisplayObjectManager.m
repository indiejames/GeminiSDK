//
//  GemDisplayObjectManager.m
//  GeminiSDK
//
//  Created by James Norton on 1/9/13.
//
//
// TODO - make this more efficient

#import "GemDisplayObjectManager.h"

@implementation GemDisplayObjectManager {
    NSMutableArray *objects;
    NSMutableDictionary *objectsByName;
}

-(id)init {
    self = [super init];
    if (self) {
        objects = [[NSMutableArray alloc] initWithCapacity:1];
        objectsByName = [[NSMutableDictionary alloc] initWithCapacity:1];
    }
    
    return self;
}

-(void)addObject:(GemDisplayObject *)obj {
    [objects addObject:obj];
    if (obj.name != nil) {
        [objectsByName setObject:obj forKey:obj.name];
    }
}

-(void)removeObject:(GemDisplayObject *)obj {
    [objects removeObject:obj];
    if (obj.name != nil) {
        [objectsByName removeObjectForKey:obj.name];
    }
}

-(GemDisplayObject *)objectWithName:(NSString *)name {
    //return [objectsByName objectForKey:name];
    
    // need to search all objects since the object will not have had a name when it was added
    GemDisplayObject *rval = nil;
    
    for (int i=0; i<[objects count]; i++) {
        GemDisplayObject *obj = [objects objectAtIndex:i];
        if ([obj.name isEqualToString:name]) {
            rval = obj;
            break;
        }
    }
    
    return rval;
}

@end
