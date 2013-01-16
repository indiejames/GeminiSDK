//
//  GemDisplayObjectManager.h
//  GeminiSDK
//
//  Created by James Norton on 1/9/13.
//
//

#import <Foundation/Foundation.h>
#import "GemDisplayObject.h"

@interface GemDisplayObjectManager : NSObject

-(void)addObject:(GemDisplayObject *)obj;
-(void)removeObject:(GemDisplayObject *)obj;
-(GemDisplayObject *)objectWithName:(NSString *)name;

@end
