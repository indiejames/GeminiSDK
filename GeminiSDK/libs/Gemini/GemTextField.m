//
//  GemTextField.m
//  GeminiSDK
//
//  Created by James Norton on 1/3/13.
//
//

#import "GemTextField.h"
#import "GemText.h"
#import "GemImage.h"

@implementation GemTextField {
    GemCharSet *charSet;
    GemText *gemText;
    NSString *text;
    unsigned int maxChars;
    GLKVector4 padding;
    BOOL hasFocus;
    GemImage *background;
    GemImage *disabledBackground;
    GemImage *caretImage;
}

@synthesize padding;


-(unsigned int)maxChars {
    return maxChars;
}

-(void)setMaxChars:(unsigned int)mChars {
    maxChars = mChars;
    
    if ([text length] > maxChars) {
        NSString *substr = [text substringToIndex:mChars];
        gemText.text = substr;
    }
}

-(NSString *)text {
    return text;
}

-(void)setText:(NSString *)txt {
    
    if ([txt length] > maxChars) {
        txt = [txt substringToIndex:maxChars];
    }
    
    text = txt;
}

-(GemCharSet *)charSet {
    return charSet;
}

-(void)setFont:(NSString *)font{
    [gemText setFont:font];
}

@end
