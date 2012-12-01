//
//  GemSoundManager.m
//  GeminiSDK
//
//  Created by James Norton on 11/22/12.
//
//

#import "GemSoundManager.h"

@interface GemSoundManager () {
    NSMutableArray *sounds;
}

@end

@implementation GemSoundManager

-(id) init {
    self = [super init];
    if(self){
        sounds = [[NSMutableArray alloc] initWithCapacity:1];
    }
    
    return self;
}

-(void)addSound:(GemSoundEffect *)sound {
    [sounds addObject:sound];
}

-(void)removeSound:(GemSoundEffect *)sound {
    [sounds removeObject:sound];
}

@end
