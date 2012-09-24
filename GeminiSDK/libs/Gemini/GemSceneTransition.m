//
//  GemSceneTransition.m
//  GeminiSDK
//
//  Created by James Norton on 8/17/12.
//
//

#import "GemSceneTransition.h"
#import "Gemini.h"
#import "GemGLKViewController.h"

@implementation GemSceneTransition

@synthesize sceneA, sceneB, elapsedTime, duration, params;


// must return YES if the transition is complete, NO otherwise
// overide this to create custom transitions
-(BOOL)transit:(double)timeSinceLastRender {
    // default implementation just switches scenes at end of transition
    BOOL rval = NO;
    elapsedTime += timeSinceLastRender;
    if (elapsedTime > duration) {
        rval = YES;
        // render sceneB
        [((GemGLKViewController *)[Gemini shared].viewController).director.renderer renderScene:sceneB];
    } else {
        // render sceneA
        [((GemGLKViewController *)[Gemini shared].viewController).director.renderer renderScene:sceneA];
    }
    
    return rval;
}

-(void)reset {
    elapsedTime = 0;
    if ([params valueForKey:@"duration"] != nil) {
        duration = [(NSNumber *)[params valueForKey:@"duration"] floatValue];
    } else {
        duration = 2.0;
    }
}

- (id)initWithParams:(NSDictionary *)p {
    self = [super init];
    if (self) {
        elapsedTime = 0;
        params = p;
        if ([p valueForKey:@"duration"] != nil) {
            duration = [(NSNumber *)[p valueForKey:@"duration"] floatValue];
        } else {
            duration = 2.0;
        }
        
        [self initGL];
    }
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


- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type source:(NSString *)shaderSource
{
    GLint status;
    //const GLchar *source = [shaderSource UTF8String];
    
    const GLchar *source = (GLchar *)[[NSString stringWithContentsOfFile:shaderSource encoding:NSUTF8StringEncoding error:nil] UTF8String];
    
    
    if (!source) {
        NSLog(@"Failed to load vertex shader");
        return NO;
    }
    
    *shader = glCreateShader(type);
    glShaderSource(*shader, 1, &source, NULL);
    glCompileShader(*shader);
    
#if defined(DEBUG)
    GLint logLength;
    glGetShaderiv(*shader, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetShaderInfoLog(*shader, logLength, &logLength, log);
        NSLog(@"Shader compile log:\n%s", log);
        free(log);
    }
#endif
    
    glGetShaderiv(*shader, GL_COMPILE_STATUS, &status);
    if (status == 0) {
        glDeleteShader(*shader);
        return NO;
    }
    
    return YES;
}

- (BOOL)linkProgram:(GLuint)prog
{
    GLint status;
    glLinkProgram(prog);
    
#if defined(DEBUG)
    GLint logLength;
    glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(prog, logLength, &logLength, log);
        NSLog(@"Program link log:\n%s", log);
        free(log);
    }
#endif
    
    glGetProgramiv(prog, GL_LINK_STATUS, &status);
    if (status == 0) {
        return NO;
    }
    
    return YES;
}

- (BOOL)validateProgram:(GLuint)prog
{
    GLint logLength, status;
    
    glValidateProgram(prog);
    glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(prog, logLength, &logLength, log);
        NSLog(@"Program validate log:\n%s", log);
        free(log);
    }
    
    glGetProgramiv(prog, GL_VALIDATE_STATUS, &status);
    if (status == 0) {
        return NO;
    }
    
    return YES;
}


@end
