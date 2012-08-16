//
//  AppDelegate.h
//  GeminiTestProgram
//
//  Created by James Norton on 2/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import <GLKit/GLKit.h>
#import "Gemini.h"

@class ViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate> {
    Gemini *gemini;
}

@property (retain, nonatomic) UIWindow *window;

@property (retain, nonatomic) ViewController *viewController;

@end
