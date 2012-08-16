//
//  GemTimer.h
//  Gemini
//
//  Created by James Norton on 6/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GemObject.h"

#define GEM_TIMER_EVENT_NAME @"GEM_TIMER_EVENT"

@interface GemTimer : GemObject {
    double delay; // sec
    double startTime;
    int numIterations;
    int iteration;
    double lastUpdateTime;
    double accumulatedTime;
    BOOL paused;
}

@property (nonatomic) BOOL paused;

-(id)initWithLuaState:(lua_State *)luaState Delay:(double)del Listener:(int)listener;
-(id)initWithLuaState:(lua_State *)luaState Delay:(double)del Listener:(int)listener NumIterations:(int)numIters;

-(void)resume:(double)currentTime;
-(void)pause:(double)currentTime;
-(void)update:(double)currentTime;
-(void)cancel;
-(double)timeLeft;
-(BOOL)isExpired;

@end
