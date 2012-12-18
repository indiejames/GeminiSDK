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


// return a random number between -1 and 1
float randNorm(void){
    return 2.0*arc4random()/ULONG_MAX - 1.0;
}


//
// apply a transform to a set of vertices.
// the ouput array should be preallocated to the same size as the input array
//
void transformVertices(GLfloat *outVerts, GLfloat *inVerts, GLuint vertCount, GLKMatrix3 transform){
    //GLKVector3 vectorArray[1024];
    /*GLKVector3 *vectorArray = (GLKVector3 *)malloc(vertCount * sizeof(GLKVector3));
       
    memcpy(vectorArray, inVerts, vertCount * sizeof(GLKVector3));
    
    GLKMatrix3MultiplyVector3Array(transform, vectorArray, vertCount);
    
    memcpy(outVerts, vectorArray, vertCount * sizeof(GLKVector3));
    
    
    free(vectorArray);*/
    memcpy(outVerts, inVerts, vertCount*sizeof(GLKVector3));
    GLKMatrix3MultiplyVector3Array(transform, (GLKVector3 *)outVerts, vertCount);
    
}

GLKVector2 getDimensionsFromSettings(BOOL adjustForLayout){
    NSDictionary *settings = [Gemini shared].settings;
    NSString *resolution = [settings objectForKey:@"resolution"];
    NSCharacterSet *cs = [NSCharacterSet characterSetWithCharactersInString:@"xX"];
    NSArray *widthHeight = [resolution componentsSeparatedByCharactersInSet:cs];
    GLfloat width = [(NSString *)[widthHeight objectAtIndex:0] floatValue];
    GLfloat height = [(NSString *)[widthHeight objectAtIndex:1] floatValue];
    
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    BOOL isLandscape = UIDeviceOrientationIsLandscape([Gemini shared].viewController.interfaceOrientation);
    
    if (adjustForLayout && (isLandscape || orientation == UIDeviceOrientationLandscapeLeft || orientation == UIDeviceOrientationLandscapeRight)) {
        GLfloat tmp = width;
        width = height;
        height = tmp;
    }
    
    return GLKVector2Make(width, height);
}


GLKMatrix4 computeModelViewProjectionMatrix(BOOL adjustForLayout){
    /*GLKView *view = (GLKView *)((GemGLKViewController *)([Gemini shared].viewController)).view;
    
    GLfloat width = view.bounds.size.width * view.contentScaleFactor;
    GLfloat height = view.bounds.size.height * view.contentScaleFactor;*/
    
    GLKVector2 dim = getDimensionsFromSettings(YES);
    GLfloat width = dim.x;
    GLfloat height = dim.y;
    
       
    GemLog(@"View dimensions:(%f,%f)",width,height);
    
    GLfloat left = 0;
    GLfloat right = width;
    GLfloat bottom = 0;
    GLfloat top = height;
    
    return GLKMatrix4Make(2.0/(right-left),0,0,0,0,2.0/(top-bottom),0,0,0,0,-1.0,0,-1.0,-1.0,-1.0,1.0);
}

GLKTextureInfo *createTexture(NSString * imgFileName){
    
    NSRange separatorRange = [imgFileName rangeOfString:@"."];
    
    NSString *imgFilePrefix = [imgFileName substringToIndex:separatorRange.location];
    NSString *imgFileSuffix = [imgFileName substringFromIndex:separatorRange.location + 1];
    
    NSMutableDictionary *options = [NSMutableDictionary dictionaryWithCapacity:1];
    [options setValue:[NSNumber numberWithBool:YES] forKey:GLKTextureLoaderOriginBottomLeft];
    
    // resolve the name for the current device resolution
    GemFileNameResolver *resolver = [Gemini shared].fileNameResolver;
    imgFilePrefix = [resolver resolveNameForFile:imgFilePrefix ofType:imgFileSuffix];
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:imgFilePrefix ofType:imgFileSuffix];
    
    GLKTextureInfo *textId = [GLKTextureLoader textureWithContentsOfFile:filePath options:options error:nil];
    
    assert(textId != nil);
    
    return textId;
}

void GemCheckGLError(void){
    int err;
    
    BOOL isError = NO;
    while ((err = glGetError()) != GL_NO_ERROR) {
        switch (err) {
            case GL_INVALID_ENUM:
                GemLog(@"An unacceptable value is specified for an enumerated argument. The offending command is ignored and has no other side effect than to set the error flag.");
                isError = YES;
                break;
            case GL_INVALID_VALUE:
                GemLog(@"A numeric argument is out of range. The offending command is ignored and has no other side effect than to set the error flag.");
                isError = YES;
                break;
            case GL_INVALID_OPERATION:
                GemLog(@"The specified operation is not allowed in the current state. The offending command is ignored and has no other side effect than to set the error flag.");
                isError = YES;
                break;
            case GL_INVALID_FRAMEBUFFER_OPERATION:
                GemLog(@"The framebuffer object is not complete. The offending command is ignored and has no other side effect than to set the error flag.");
                isError = YES;
                break;
            case GL_OUT_OF_MEMORY:
                GemLog(@"There is not enough memory left to execute the command. The state of the GL is undefined, except for the state of the error flags, after this error is recorded.");
                isError = YES;
                break;
            case GL_STACK_UNDERFLOW:
                GemLog(@"An attempt has been made to perform an operation that would cause an internal stack to underflow.");
                isError = YES;
                break;
            case GL_STACK_OVERFLOW:
                GemLog(@"An attempt has been made to perform an operation that would cause an internal stack to overflow.");
                isError = YES;
                break;
            default:
                break;
        }
    }
    
    if (isError) {
        [NSException raise:@"glGetError() returned error" format:@"Error code %d", err];
    }
}
