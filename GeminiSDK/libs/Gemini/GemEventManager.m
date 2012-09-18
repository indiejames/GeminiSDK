//
//  GemEventManager.m
//  GeminiSDK
//
//  Created by James Norton on 9/13/12.
//
//

#import "GemEventManager.h"
#import "GemGLKViewController.h"


@implementation GemEventManager

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
}
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    // test all current display objects to see if they were hit
    for (UITouch *touch in touches) {
        CGPoint location = [touch locationInView:self.parentGLKViewController.view];
        float contentScale = self.parentGLKViewController.view.contentScaleFactor;
        GemLog(@"touch at (x,y) = (%f,%f)", contentScale*location.x, contentScale*location.y);
    }
}
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    
}

@end
