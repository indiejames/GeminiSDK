//
//  GemTextField.h
//  GeminiSDK
//
//  Created by James Norton on 1/3/13.
//
//

#import "GemDisplayGroup.h"
#import "GemCharSet.h"

@interface GemTextField : GemDisplayGroup

@property GLKVector4 padding;
@property NSString *text;
@property unsigned int maxChars;


@end
