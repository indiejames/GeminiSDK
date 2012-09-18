//
//  GemEventManager.h
//  GeminiSDK
//
//  Created by James Norton on 9/13/12.
//
//

#import <Foundation/Foundation.h>
#import "GemObject.h"

@class GemGLKViewController;

@interface GemEventManager : GemObject

@property (weak) GemGLKViewController *parentGLKViewController;

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event;

@end
