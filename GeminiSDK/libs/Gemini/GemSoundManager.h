//
//  GemSoundManager.h
//  GeminiSDK
//
//  Created by James Norton on 11/22/12.
//
//

#import <Foundation/Foundation.h>
#import "GemSoundEffect.h"

@interface GemSoundManager : NSObject

-(void)addSound:(GemSoundEffect *)sound;
-(void)removeSound:(GemSoundEffect *)sound;

@end
