//
//  FileNameResolver.h
//  GeminiSDK
//
//  Created by James Norton on 9/16/12.
//
//

#import <Foundation/Foundation.h>

@interface GemFileNameResolver : NSObject

-(id)initForWidth:(float)w Height:(float)h ContentScale:(float)scale Settings:(NSDictionary *)settings;
-(NSString *)resolveNameForFile:(NSString *)fileName ofType:(NSString *)type;

@end
