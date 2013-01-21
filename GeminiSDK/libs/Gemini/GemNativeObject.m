//
//  GemNativeObject.m
//  GeminiSDK
//
//  Created by James Norton on 1/13/13.
//
//

#import "GemNativeObject.h"

@implementation GemNativeObject
@synthesize nativeObject;

-(GLKVector2) getTouchPoint {
    CGRect frame = nativeObject.frame;
    GLfloat x = frame.origin.x + frame.size.width / 2.0;
    GLfloat y = frame.origin.y + frame.size.height / 2.0;
    
    return GLKVector2Make(x, y);
    
}

@end
