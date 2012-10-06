//
//  GemTextureBasedSceneTransition.m
//  GeminiSDK
//
//  Created by James Norton on 9/26/12.
//
//

#import "GemTextureBasedSceneTransition.h"
#import "Gemini.h"


@implementation GemTextureBasedSceneTransition

-(void)reset {
    texturedAreRendered = NO;
    [super reset];
}

-(id) initWithParams:(NSDictionary *)p {
    self = [super initWithParams:p];
    if (self) {
         texturedAreRendered = NO;
    }
    
    [self initGL];
    
    return self;
}

-(void)dealloc {
    glDeleteRenderbuffers(1, &depthRBA);
    glDeleteRenderbuffers(1, &depthRBB);
    
    glDeleteFramebuffers(1, &fboA);
    glDeleteFramebuffers(1, &fboB);
    
    glDeleteTextures(1, &textureA);
    glDeleteTextures(1, &textureB);
}

-(void)initGL {
    // compute texture size
    float scale = [Gemini shared].viewController.view.contentScaleFactor;
    unsigned int screenWidth = scale * [Gemini shared].viewController.view.bounds.size.width;
    unsigned int screenHeight = scale * [Gemini shared].viewController.view.bounds.size.height;
    
    textWidth = screenWidth;
    textHeight = screenHeight;
    
    
    //create texture A
    glGenTextures(1, &textureA);
    glBindTexture(GL_TEXTURE_2D, textureA);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    //glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, textWidth, textHeight, 0, GL_RGBA,
    //             GL_UNSIGNED_SHORT_5_5_5_1, NULL);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, textWidth, textHeight, 0, GL_RGBA,
                 GL_UNSIGNED_BYTE, NULL);
    
    glLabelObjectEXT(GL_TEXTURE, textureA, 0, "ScentTransitionTextureA");
    
    
    //create textureB
    glGenTextures(1, &textureB);
    glBindTexture(GL_TEXTURE_2D, textureB);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    //glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, textWidth, textHeight, 0, GL_RGBA,
    //            GL_UNSIGNED_BYTE, NULL);
    //glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, textWidth, textHeight, 0, GL_RGBA,
    //             GL_UNSIGNED_SHORT_5_5_5_1, NULL);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, textWidth, textHeight, 0, GL_RGBA,
                 GL_UNSIGNED_BYTE, NULL);
    
    //create fboA and attach texture A to it
    glGenFramebuffers(1, &fboA);
    glBindFramebuffer(GL_FRAMEBUFFER, fboA);
    glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, textureA, 0);
    
    // create and attach a depth buffer
    glGenRenderbuffers(1, &depthRBA);
    
    // bind the depth buffer
    glBindRenderbuffer(GL_RENDERBUFFER, depthRBA);
    // create the render buffer in the GPU
    glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT16, textWidth, textHeight);
    // unbind the render buffer
    glBindRenderbuffer(GL_RENDERBUFFER, fboA);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, depthRBA);
    
    // do the same for B
    glGenFramebuffers(1, &fboB);
    glBindFramebuffer(GL_FRAMEBUFFER, fboB);
    glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, textureB, 0);
    
    // create and attach a depth buffer
    glGenRenderbuffers(1, &depthRBB);
    
    // bind the depth buffer
    glBindRenderbuffer(GL_RENDERBUFFER, depthRBB);
    // create the render buffer in the GPU
    glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT16, textWidth, textHeight);
    // unbind the render buffer
    glBindRenderbuffer(GL_RENDERBUFFER, fboB);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, depthRBB);
}


@end
