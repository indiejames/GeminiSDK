//
//  GeminiSpriteManager.h
//  Gemini
//
//  Created by James Norton on 5/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GemSprite.h"

@interface GemSpriteManager : NSObject {
    NSMutableArray *sprites;
}

-(void)update:(double)currentTime;
-(void)addSprite:(GemSprite *)sprite;
-(void)removeSprite:(GemSprite *)sprite;

@end
