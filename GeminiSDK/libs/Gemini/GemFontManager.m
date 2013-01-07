//
//  GemFontManager.m
//  GeminiSDK
//
//  Created by James Norton on 1/4/13.
//
//

#import "GemFontManager.h"

@implementation GemFontManager {
    NSMutableDictionary *fonts;
}

-(id) init {
    self = [super init];
    
    if (self) {
        fonts = [NSMutableDictionary dictionaryWithCapacity:1];
    }
    
    return self;
}

-(void)addFont:(NSString *)name withCharset:(GemCharSet *)charset {
    [fonts setValue:charset forKey:name];
}

-(void)removeFont:(NSString *)name {
    [fonts removeObjectForKey:name];
}

-(GemCharSet *)fontWithName:(NSString *)name {
    return [fonts objectForKey:name];
}

@end
