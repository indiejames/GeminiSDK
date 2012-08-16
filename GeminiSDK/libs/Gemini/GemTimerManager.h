//
//  GemTimerManager.h
//  Gemini
//
//  Created by James Norton on 6/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GemTimer.h"

@interface GemTimerManager : NSObject {
    NSMutableArray *timers;
}

-(void)update:(double)currentTime;
-(void)addTimer:(GemTimer *)timer;
-(void)removeTimer:(GemTimer *)timer;

@end
