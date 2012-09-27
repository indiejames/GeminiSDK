//
//  GemOpenGLState.h
//  GeminiSDK
//
//  Created by James Norton on 9/24/12.
//
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

@interface GemOpenGLState : NSObject {
    
}

@property GLKVector3 glColor;
@property GLint depthMask;
@property GLint glBlend;
@property GLint glDepthMask;
@property GLKVector2 glBlendFunc;
@property GLuint boundArrayBuffer;
@property GLuint boundArrayElementBuffer;
@property GLuint boundVertexArrayObject;
@property GLuint shaderProgram;

+(GemOpenGLState *) shared;

@end
