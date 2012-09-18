//
//  GemSoundEffect.h
//  GeminiSDK
//
//  Created by James Norton on 9/2/12.
//
//

#import <Foundation/Foundation.h>

@interface GemSoundEffect : NSObject {
    NSString *name;
    int callback;
}

@property (nonatomic, strong) NSString *name;
@property (nonatomic) int callback;

@end
