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



//
// apply a transform to a set of vertices.
// the ouput array should be preallocated to the same size as the input array
//
void transformVertices(GLfloat *outVerts, GLfloat *inVerts, GLuint vertCount, GLKMatrix3 transform){
    GLKVector3 vectorArray[1024];
    
    // create an array of vectors from our input data
    // GLKVector3 *vectorArray = (GLKVector3 *)malloc(vertCount * sizeof(GLKVector3));
    /*for (GLuint i = 0; i<vertCount; i++) {
     vectorArray[i] = GLKVector3MakeWithArray(inVerts + 3*i);
     }*/
    
    memcpy(vectorArray, inVerts, vertCount * sizeof(GLKVector3));
    
    GLKMatrix3MultiplyVector3Array(transform, vectorArray, vertCount);
    
    memcpy(outVerts, vectorArray, vertCount * sizeof(GLKVector3));
    
    /*for (GLuint i = 0; i<vertCount; i++) {
     
     outVerts[i*3] = vectorArray[i].x;
     outVerts[i*3+1] = vectorArray[i].y;
     outVerts[i*3+2] = vectorArray[i].z;
     
     }*/
    
    //free(vectorArray);
    
}


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
