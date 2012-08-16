//
//  GeminiTransistion.m
//  Gemini
//
//  Created by James Norton on 5/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GemTransistion.h"
#import "GemLine.h"
#import "GemRectangle.h"
#import "GemSprite.h"
#import "LGeminiTransition.h"

@implementation GemTransistion

-(id)initWithLuaState:(lua_State *)lua_state Object:(GemDisplayObject *)object Data:(NSDictionary *)data To:(BOOL)to {
    self = [super init];
    
    if (self) {
        L = lua_state;
        obj = object;
        elapsedTime = 0;
        duration = [(NSNumber *)[data objectForKey:@"time"] doubleValue] / 1000.0;
        NSNumber *delayNumber = (NSNumber *)[data objectForKey:@"delay"];
        if (delayNumber) {
            delay = [delayNumber doubleValue] / 1000.0;
        } else {
            delay = 0;
        }
        
        if ([data objectForKey:@"onStart"]) {
            onStart = [(NSNumber *)[data objectForKey:@"onStart"] intValue];
            
        } else {
            onStart = -1;
        }
        
        if ([data objectForKey:@"onComplete"]) {
            onComplete = [(NSNumber *)[data objectForKey:@"onComplete"] intValue];
            
        } else {
            onComplete = -1;
        }
        
        initialParamValues = [[NSMutableDictionary alloc] initWithCapacity:1];
        finalParamValues = [[NSMutableDictionary alloc] initWithCapacity:1];
        
        NSArray *params = [data allKeys];
        for (int i=0; i<[params count]; i++) {
            NSString *param = (NSString *)[params objectAtIndex:i];
            if (![param isEqualToString:@"time"] && ![param isEqualToString:@"delay"] && ![param isEqualToString:@"onStart"] && ![param isEqualToString:@"onComplete"]) {
                
                NSNumber *value = [data objectForKey:param];
                NSNumber *initialValue = [obj valueForKey:param];
                
                if (to) {
                    [finalParamValues setObject:value forKey:param];
                    
                    [initialParamValues setObject:initialValue forKey:param];
                } else {
                    [finalParamValues setObject:initialValue forKey:param];
                    
                    [initialParamValues setObject:value forKey:param];   
                }
                
                
            }
        }
    }
    
    return self;
}

-(void)dealloc {
    [initialParamValues release];
    [finalParamValues release];
    
    [super dealloc];
}

-(void)update:(double)secondsSinceLastUpdate {
    if (elapsedTime) {
        if (onStart != -1) {
            callOnStartForDisplayObject(L, onStart, obj);
        }
        
    }
    elapsedTime += secondsSinceLastUpdate;
    
    if (elapsedTime > delay) {
        double actualTime = elapsedTime - delay;
        if (actualTime > duration) {
            actualTime = duration;
        }
        
        NSArray *params = [finalParamValues allKeys];
        for (int i=0; i<[params count]; i++) {
            NSString * param = (NSString *)[params objectAtIndex:i];
            double finalValue = [(NSNumber *)[finalParamValues objectForKey:param] doubleValue];
            double initialValue = [(NSNumber *)[initialParamValues objectForKey:param] doubleValue];
            
            // only support linear easing for now
            
            double currentValue = initialValue + (finalValue - initialValue) * (actualTime / duration);
            
            [obj setValue:[NSNumber numberWithDouble:currentValue] forKey:param];
            
            // call onComplete method
            if (onComplete != -1) {
                callOnCompleteForDisplayObject(L, onComplete, obj);
            }
        }
    }
    
}

-(BOOL)isActive {
    BOOL rval = NO;
    if (elapsedTime < duration + delay) {
        rval = YES;
    }
    
    return rval;
}

@end
