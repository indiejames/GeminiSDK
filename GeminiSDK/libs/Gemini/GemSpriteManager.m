//
//  GeminiSpriteManager.m
//  Gemini
//
//  Created by James Norton on 5/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GemSpriteManager.h"

@implementation GemSpriteManager

-(id)init {
    self = [super init];
    if (self) {
        sprites = [[NSMutableArray alloc] initWithCapacity:100];
    }
    
    return self;
}

-(void)dealloc {
    [sprites release];
    
    [super dealloc];
}

-(void)update:(double)currentTime {
    for(int i=0;i<[sprites count]; i++){
        GemSprite *sprite = (GemSprite *)[sprites objectAtIndex:i];
        if (!sprite.paused) {
            [sprite update:currentTime];
        }
    }
}

-(void)addSprite:(GemSprite *)sprite {
    [sprites addObject:sprite];
}

-(void)removeSprite:(GemSprite *)sprite {
    [sprites removeObject:sprite];
}

@end


