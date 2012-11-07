//
//  GemMask.h
//  GeminiSDK
//
//  Created by James Norton on 11/4/12.
//
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

@interface GemMask : NSObject

@property UIImage *image;

-(BOOL)isPointMaskedX:(GLfloat)x Y:(GLfloat)y;

@end
