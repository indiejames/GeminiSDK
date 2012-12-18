//
//  GemParticleSystemManager.m
//  TGem22
//
//  Created by James Norton on 12/7/12.
//
//

#import "GemParticleSystemManager.h"

@implementation GemParticleSystemManager

-(id)init {
    self = [super init];
    if (self) {
        emitters = [[NSMutableArray alloc] initWithCapacity:1];
    }
    
    return self;
}

-(void)update:(double)currentTime {
    
    for(int i=0;i<[emitters count]; i++){
        GemParticleSystem *ps = (GemParticleSystem *)[emitters objectAtIndex:i];
        if (ps.on && !ps.isPaused) {
            [ps update:currentTime];
        } else {
            GemLog(@"Emitter is not active");
        }
    }
}


-(void)addEmitter:(GemParticleSystem *)ps {
    [emitters addObject:ps];
}

-(void)removeEmitter:(GemParticleSystem *)ps {
    [emitters removeObject:ps];
}

@end
