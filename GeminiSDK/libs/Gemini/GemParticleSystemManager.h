//
//  GemParticleSystemManager.h
//  TGem22
//
//  Created by James Norton on 12/7/12.
//
//

#import <Foundation/Foundation.h>
#import "GemParticleSystem.h"

@interface GemParticleSystemManager : NSObject {
    
        NSMutableArray *emitters;

}
    
-(void)update:(double)currentTime;
-(void)addEmitter:(GemParticleSystem *)ps;
-(void)removeEmitter:(GemParticleSystem *)ps;

@end
