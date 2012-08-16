//
//  GemTimerManager.m
//  Gemini
//
//  Created by James Norton on 6/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GemTimerManager.h"

@implementation GemTimerManager 

-(id)init {
    self = [super init];
    if (self) {
        timers = [[NSMutableArray alloc] initWithCapacity:100];
    }
    
    return self;
}

-(void)dealloc {
    [timers release];
    
    [super dealloc];
}

-(void)update:(double)currentTime {
    NSMutableArray *expiredTimers = [NSMutableArray arrayWithCapacity:1];
    
    for(int i=0;i<[timers count]; i++){
        GemTimer *timer = (GemTimer *)[timers objectAtIndex:i];
        if (!timer.paused) {
            [timer update:currentTime];
        }
        
        if ([timer isExpired]) {
            [expiredTimers addObject:timer];
        }
    }
    
    [timers removeObjectsInArray:expiredTimers];
}

-(void)addTimer:(GemTimer *)timer {
    [timers addObject:timer];
}

-(void)removeTimer:(GemTimer *)timer {
    [timers removeObject:timer];
}

@end
