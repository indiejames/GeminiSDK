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
    }
    return self;
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
