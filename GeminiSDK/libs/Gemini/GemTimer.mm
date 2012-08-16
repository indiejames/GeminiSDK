//
//  GemTimer.m
//  Gemini
//
//  Created by James Norton on 6/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GemTimer.h"
#import "GemGLKViewController.h"
#import "Gemini.h"
#import "GemEvent.h"

@implementation GemTimer

@synthesize paused;


-(id)initWithLuaState:(lua_State *)luaState Delay:(double)del Listener:(int)listener {
    
    return [self initWithLuaState:luaState Delay:delay Listener:listener NumIterations:1];
    
}

-(id)initWithLuaState:(lua_State *)luaState Delay:(double)del Listener:(int)listener NumIterations:(int)numIters {
    self = [super initWithLuaState:luaState];
    
    if (self) {
        NSLog(@"del = %f", del);
        delay = del / 1000.0;
        numIterations = numIters;
        iteration = 0;
        accumulatedTime = 0;
        lastUpdateTime = ((GemGLKViewController *)([Gemini shared].viewController)).updateTime;
        [self addEventListener:listener forEvent:GEM_TIMER_EVENT_NAME];
    }
    
    return self;
}

-(void)resume:(double)currentTime{
    lastUpdateTime = currentTime;
    paused = NO;
}

-(void)pause:(double)currentTime {
    [self update:currentTime];
    paused = YES;
}

-(void)cancel {
    numIterations = -1;
    iteration = numIterations;
    paused = NO;
}

-(double)timeLeft {
    double rval = delay - accumulatedTime;
    if (rval < 0){
        rval = 0;
    }
    
    return rval;
}

-(void)update:(double)currentTime {
    // TODO - verify this logic
    if (!paused && (iteration < numIterations || numIterations == 0)) {
        double timeDelta = currentTime - lastUpdateTime;
        lastUpdateTime = currentTime;
        accumulatedTime += timeDelta;
        
        if (accumulatedTime >= delay) {
            
            GemEvent *timeEvent = [[GemEvent alloc] initWithLuaState:L Source:self];
            timeEvent.name = GEM_TIMER_EVENT_NAME;
            timeEvent.source = self;
            [self handleEvent:timeEvent];
            
            [timeEvent release];
            
            accumulatedTime = 0;
            
            iteration += 1;
           
        }
    }
}

-(BOOL)isExpired {
    BOOL rval = NO;
    
    if (numIterations != 0 && iteration >= numIterations) {
        rval = YES;
    }
    
    return rval;
}

-(void)dealloc {
    [super dealloc];
}

@end
