//
//  GemFadeSceneTransition.m
//  GeminiSDK
//
//  Created by James Norton on 9/18/12.
//
//

#import "GemFadeSceneTransition.h"
#import "Gemini.h"
#import "GemGLKViewController.h"

// compute the power of two closest to but not less than a number
unsigned int nearestPowerOfTwo(unsigned int v){
    v--;
    v |= v >> 1;
    v |= v >> 2;
    v |= v >> 4;
    v |= v >> 8;
    v |= v >> 16;
    v++;
    
    return v;
}

@implementation GemFadeSceneTransition

// must return YES if the transition is complete, NO otherwise
// overide this to create custom transitions
-(BOOL)transit:(double)timeSinceLastRender {
    // default implementation just switches scenes at end of transition
    BOOL rval = NO;
    elapsedTime += timeSinceLastRender;
    if (elapsedTime > duration) {
        rval = YES;
    }
    
    [self render];
    
    return rval;
}

-(void)render {
   /* glBindVertexArrayOES(0);
    
    // compute texture size
    float scale = [Gemini shared].viewController.view.contentScaleFactor;
    unsigned int screenWidth = scale * [Gemini shared].viewController.view.bounds.size.width;
    unsigned int screenHeight = scale * [Gemini shared].viewController.view.bounds.size.height;
    
       unsigned int textWidth = screenWidth;
    unsigned int textHeight = screenHeight;*/
    
    
    //create texture A
    GLuint textureA;
    glEnable(GL_TEXTURE_2D);
    glGenTextures(1, &textureA);
    glBindTexture(GL_TEXTURE_2D, textureA);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, 256, 256, 0, GL_RGBA,
                 GL_UNSIGNED_BYTE, NULL);
    /*
    
    //create textureB
    GLuint textureB;
    glGenTextures(1, &textureB);
    glBindTexture(GL_TEXTURE_2D, textureB);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, textWidth, textHeight, 0, GL_RGBA,
                 GL_UNSIGNED_BYTE, NULL); */
    
    //create fboA and attach texture A to it
    GLuint fboA;
    glGenFramebuffers(1, &fboA);
    glBindFramebuffer(GL_FRAMEBUFFER, fboA);
    glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, textureA, 0);
    //set the viewport to be the size of the texture
   // glViewport(0,0, 256, 256);
    
    //clear the ouput texture
    glClear ( GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT );
    
   /* [((GemGLKViewController *)[Gemini shared].viewController).director.renderer renderScene:sceneA];

    
    // do the same for B
    GLuint fboB;
    glGenFramebuffers(1, &fboB);
    glBindFramebuffer(GL_FRAMEBUFFER, fboB);
    glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, textureB, 0);
    
    //clear the ouput texture
    glClear ( GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT );
    
    [((GemGLKViewController *)[Gemini shared].viewController).director.renderer renderScene:sceneB];
    */
    
    // render the mixed scenes using the two textures
        
    [(GLKView *)[Gemini shared].viewController.view bindDrawable];
    
    [((GemGLKViewController *)[Gemini shared].viewController).director.renderer renderSceneTexture:textureA];
    //[((GemGLKViewController *)[Gemini shared].viewController).director.renderer renderScene:sceneB];
    
    glDeleteFramebuffers(1, &fboA);
    //glDeleteFramebuffers(1, &fboB);
    
    glDeleteTextures(1, &textureA);
    //glDeleteTextures(1, &textureB);

}

- (id)initWithParams:(NSDictionary *)p {
    self = [super initWithParams:p];

    return self;
}


@end
