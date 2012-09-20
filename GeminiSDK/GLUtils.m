//
//  GLUtils.c
//  GeminiSDK
//
//  Created by James Norton on 9/20/12.
//
//

#import <Foundation/Foundation.h>
#import "GemDisplayGroup.h"
#import "GemLineShaderManager.h"
#import "GemSpriteShaderManager.h"
#import "GeminiRectangleShaderManager.h"
#include "GeminiTypes.h"
#import "GemScene.h"
#import "GemGLKViewController.h"
#import "Gemini.h"


GLKMatrix4 computeModelViewProjectionMatrix(BOOL adjustForLayout){
    GLKView *view = (GLKView *)((GemGLKViewController *)([Gemini shared].viewController)).view;
    
    GLfloat width = view.bounds.size.width;
    GLfloat height = view.bounds.size.height;
    
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    BOOL isLandscape = UIDeviceOrientationIsLandscape([Gemini shared].viewController.interfaceOrientation);
    
    if (adjustForLayout && (isLandscape || orientation == UIDeviceOrientationLandscapeLeft || orientation == UIDeviceOrientationLandscapeRight)) {
        GLfloat tmp = width;
        width = height;
        height = tmp;
    }
    
    GemLog(@"View dimensions:(%f,%f)",width,height);
    
    GLfloat left = 0;
    GLfloat right = width;
    GLfloat bottom = 0;
    GLfloat top = height;
    
    return GLKMatrix4Make(2.0/(right-left),0,0,0,0,2.0/(top-bottom),0,0,0,0,-1.0,0,-1.0,-1.0,-1.0,1.0);
}