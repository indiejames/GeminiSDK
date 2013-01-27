//
//  AppDelegate.m
//  GeminiTestProgram
//
//  Created by James Norton on 2/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"
#import "QSStrings.h"
#import "GemGLKViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "Gemini.h"
#import "GemEvent.h"

@implementation AppDelegate

@synthesize window = _window;
@synthesize viewController = _viewController;


#ifdef CUKE
// backdoor for calabash testing - allows calabash steps to do screen captures
- (NSString *) calabashBackdoor:(NSString *)command {
    
    if ([command isEqualToString:@"screenshot"]) {
        // take and return a base64 encoded screenshot
        GLKViewController *viewController = [Gemini shared].viewController;
        GLKView *view = (GLKView *)viewController.view;
        
        UIImage *image = [view snapshot];
        
        NSData *data = UIImagePNGRepresentation(image);
        
        NSString *base64 = [QSStrings encodeBase64WithData:data];
        
        return base64;
        
    } else if([command isEqualToString:@"nativeScreenshot"]) {
        if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)])
            UIGraphicsBeginImageContextWithOptions(self.window.bounds.size, NO, [UIScreen mainScreen].scale);
        else
            UIGraphicsBeginImageContext(self.window.bounds.size);
        GLKViewController *viewController = [Gemini shared].viewController;
        GLKView *view = (GLKView *)viewController.view;
        CALayer *layer = view.layer;

        [layer renderInContext:UIGraphicsGetCurrentContext()];
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        NSData * data = UIImagePNGRepresentation(image);
        NSString *base64 = [QSStrings encodeBase64WithData:data];
        
        return base64;
        
    } else if([command hasPrefix:@"goto_"]){
        // load a Lua scene
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"goto_(.*)" options:0 error:NULL];
        NSTextCheckingResult *match = [regex firstMatchInString:command options:0 range:NSMakeRange(0, [command length])];
        NSString *sceneName = [command substringWithRange:[match rangeAtIndex:1]];
        
        [((GemGLKViewController *)[Gemini shared].viewController).director gotoScene:sceneName withOptions:nil];
        
    } else if([command hasPrefix:@"get_touch_point_of_object_"]){
        // get the (touch) coordinates for a display object
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"get_touch_point_of_object_(.*)" options:0 error:NULL];
        NSTextCheckingResult *match = [regex firstMatchInString:command options:0 range:NSMakeRange(0, [command length])];
        NSString *object_name = [command substringWithRange:[match rangeAtIndex:1]];
        GemDisplayObject *obj = [((GemGLKViewController *)[Gemini shared].viewController).displayObjectManager objectWithName:object_name];
        
        if (obj == nil) {
            // check to see if it is a native object
        }
        
        if (obj != nil) {
            GLKVector2 center = [obj getTouchPoint];
            NSString *centerStr = [NSString stringWithFormat:@"%f,%f",center.x, center.y];
            return centerStr;
        } else {
            return @"NO SUCH OBJECT";
        }
        
    }
    
    return @"OK";
}
#endif // CUKE

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [UIApplication sharedApplication].statusBarHidden = YES;
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    gemini = [Gemini shared];
        
    self.window.rootViewController = gemini.viewController;
    
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    self.window.multipleTouchEnabled = YES;
    
#ifdef CUKE
    [gemini execute:@"main_cuke"];
    GemLog(@"Using CUKE");
#else
    [gemini execute:@"main"];
#endif // CUKE
    
    // TEST
    //[gemini.viewController becomeFirstResponder];
    
    return YES;
}

#pragma mark - GLKViewDelegate

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    
    glClearColor(1.0, 0.0, 0.0, 1.0);
    glClear(GL_COLOR_BUFFER_BIT);
    
}

#pragma mark - GLKViewControllerDelegate

- (void)glkViewControllerUpdate:(GLKViewController *)controller {
   /* if (_increasing) {
        _curRed += 1.0 * controller.timeSinceLastUpdate;
    } else {
        _curRed -= 1.0 * controller.timeSinceLastUpdate;
    }
    if (_curRed >= 1.0) {
        _curRed = 1.0;
        _increasing = NO;
    }
    if (_curRed <= 0.0) {
        _curRed = 0.0;
        _increasing = YES;
    }*/
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
    
    [[Gemini shared] applicationWillResignActive];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
    
    [[Gemini shared] applicationDidEnterBackground];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
    
    [[Gemini shared] applicationWillEnterForeground];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
    [[Gemini shared] applicationDidBecomeActive];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // call any Lua listeners
    [[Gemini shared] applicationWillExit];
}

@end
