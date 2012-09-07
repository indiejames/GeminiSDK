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
        sprites = [[NSMutableArray alloc] initWithCapacity:1];
        spriteSets = [[NSMutableArray alloc] initWithCapacity:1];
        spriteSheets = [[NSMutableArray alloc] initWithCapacity:1];
    }
    
    return self;
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

-(void)addSpriteSet:(GemSpriteSet *)spriteSet {
    [spriteSets addObject:spriteSet];
}

-(void)addSpriteSheet:(GemSpriteSheet *)spriteSheet {
    [spriteSheets addObject:spriteSheet];
}

-(void)removeSprite:(GemSprite *)sprite {
    [sprites removeObject:sprite];
}

-(void)removeSpriteSet:(GemSpriteSet *)spriteSet {
    [spriteSets removeObject:spriteSet];
}

-(void)removeSpriteSheet:(GemSpriteSheet *)spriteSheet {
    [spriteSheets removeObject:spriteSheet];
}

@end


