//
//  GeminiTransitionManager.h
//  Gemini
//
//  Created by James Norton on 5/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GemTransistion.h"

@interface GemTransitionManager : NSObject {
    NSMutableArray *transitions;
}

-(void) addTransition:(GemTransistion *)trans;
-(void)removeTransition:(GemTransistion *)trans;
-(void)processTransitions:(double)secondsSinceLastUpdate;

+(GemTransitionManager *)shared;

@end
