//
//  GemFontManager.h
//  GeminiSDK
//
//  Created by James Norton on 1/4/13.
//
//

#import <Foundation/Foundation.h>
#import "GemCharSet.h"

@interface GemFontManager : NSObject

-(void)addFont:(NSString *)name withCharset:(GemCharSet *)charset;
-(void)removeFont:(NSString *)name;
-(GemCharSet *)fontWithName:(NSString *)name;

@end
