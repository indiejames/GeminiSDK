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
#include "GLUtils.h"


// Sprite shader uniform index
enum {
    UNIFORM_PROJECTION_FADE_SCENE,
    UNIFORM_TEXTURE_FADE_SCENE,
    NUM_UNIFORMS_FADE_SCENE
};

GLint uniforms_fade_scene[NUM_UNIFORMS_FADE_SCENE];

// Sprite vertex attribute index
enum {
    ATTRIB_VERTEX_FADE_SCENE,
    ATTRIB_COLOR_FADE_SCENE,
    ATTRIB_TEXCOORD_FADE_SCENE,
    NUM_ATTRIBUTES_FADE_SCENE
};


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
    glBindVertexArrayOES(0);
    
    // get the default scene (always rendered)
    GemScene *defaultScene = [((GemGLKViewController *)[Gemini shared].viewController).director getDefaultScene];
    
    // compute texture size
    float scale = [Gemini shared].viewController.view.contentScaleFactor;
    unsigned int screenWidth = scale * [Gemini shared].viewController.view.bounds.size.width;
    unsigned int screenHeight = scale * [Gemini shared].viewController.view.bounds.size.height;
    
    unsigned int textWidth = screenWidth;
    unsigned int textHeight = screenHeight;
    
    
    //create texture A
    GLuint textureA;
    glEnable(GL_TEXTURE_2D);
    glGenTextures(1, &textureA);
    glBindTexture(GL_TEXTURE_2D, textureA);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, textWidth, textHeight, 0, GL_RGBA,
                 GL_UNSIGNED_BYTE, NULL);
    
    
    //create textureB
    GLuint textureB;
    glGenTextures(1, &textureB);
    glBindTexture(GL_TEXTURE_2D, textureB);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, textWidth, textHeight, 0, GL_RGBA,
                 GL_UNSIGNED_BYTE, NULL); 
    
    //create fboA and attach texture A to it
    GLuint fboA;
    glGenFramebuffers(1, &fboA);
    glBindFramebuffer(GL_FRAMEBUFFER, fboA);
    glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, textureA, 0);
    //set the viewport to be the size of the texture
    glViewport(0,0, textWidth, textHeight);
    
    //clear the ouput texture
    glClearColor(1.0, 0, 0, 0);
    glClear ( GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT );
    
   [((GemGLKViewController *)[Gemini shared].viewController).director.renderer renderScene:sceneA];
    [((GemGLKViewController *)[Gemini shared].viewController).director.renderer renderScene:defaultScene];

    
    // do the same for B
    GLuint fboB;
    glGenFramebuffers(1, &fboB);
    glBindFramebuffer(GL_FRAMEBUFFER, fboB);
    glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, textureB, 0);
    
    //clear the ouput texture
    glClear ( GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT );
    
    [((GemGLKViewController *)[Gemini shared].viewController).director.renderer renderScene:sceneB];
    [((GemGLKViewController *)[Gemini shared].viewController).director.renderer renderScene:defaultScene];
    
    
    // render the mixed scenes using the two textures
    GLKView *view = (GLKView *)[Gemini shared].viewController.view;
    GLuint width = view.bounds.size.width;
    GLuint height = view.bounds.size.height;
    
        
    [view bindDrawable];
    glViewport(0,0, width, height);
    
    GLfloat alpha = elapsedTime / duration;
    if (alpha > 1.0) {
        alpha = 1.0;
    }
    
    glClearColor(0, 0, 1.0, 0);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    [self renderSceneTexture:textureA WithAlpha:(1-alpha)];
    [self renderSceneTexture:textureB WithAlpha:alpha];
    
    glDeleteFramebuffers(1, &fboA);
    //glDeleteFramebuffers(1, &fboB);
    
    glDeleteTextures(1, &textureA);
    //glDeleteTextures(1, &textureB);

}



-(void)renderSceneTexture:(GLuint)texture WithAlpha:(GLfloat)alpha {
    GLenum glErr;
    glGetError();
    
    glBindVertexArrayOES(vao);
    glErr = glGetError();
    if (glErr) {
        GemLog(@"GL_ERROR: %d", glErr);
    }

    glUseProgram(program);
    glErr = glGetError();
    if (glErr) {
        GemLog(@"GL_ERROR: %d", glErr);
    }

    
    glDepthMask(GL_FALSE);
    glDisable(GL_DEPTH_TEST);
    
    
    
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    glEnable(GL_BLEND);
    
    
    GemTexturedVertex verts[] = {
        {{0,0,-0.5}, {1,1,1,alpha}, {0,0}},
        {{0,1,-0.5}, {1,1,1,alpha}, {0,1}},
        {{1,0,-0.5}, {1,1,1,alpha}, {1,0}},
        {{1,1,-0.5}, {1,1,1,alpha}, {1,1}}
    };
    
    
    GLubyte index[] = {
        0,1,2,3
    };
    
    GLuint vBuffer;
    glGenBuffers(1, &vBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, vBuffer);
    glBufferData(GL_ARRAY_BUFFER, 4*sizeof(GemTexturedVertex), verts, GL_STATIC_DRAW);
    
    glErr = glGetError();
    if (glErr) {
        GemLog(@"GL_ERROR: %d", glErr);
    }
    
    GLuint iBuffer;
    glGenBuffers(1, &iBuffer);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, iBuffer);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, 4*sizeof(GLubyte), index, GL_STATIC_DRAW);
    
    glErr = glGetError();
    if (glErr) {
        GemLog(@"GL_ERROR: %d", glErr);
    }
    
    
    glVertexAttribPointer(ATTRIB_VERTEX_FADE_SCENE, 3, GL_FLOAT, GL_FALSE, sizeof(GemTexturedVertex), (GLvoid *)0);
    
    glVertexAttribPointer(ATTRIB_COLOR_FADE_SCENE, 4, GL_FLOAT, GL_FALSE,
                          sizeof(GemTexturedVertex), (GLvoid*) (sizeof(float) * 3));
    glVertexAttribPointer(ATTRIB_TEXCOORD_FADE_SCENE, 2, GL_FLOAT, GL_FALSE, sizeof(GemTexturedVertex), (GLvoid *)(sizeof(float) * 7));
    
    glActiveTexture(GL_TEXTURE0);
    
    glBindTexture(GL_TEXTURE_2D, texture);
    glUniform1i(uniforms_fade_scene[UNIFORM_TEXTURE_FADE_SCENE], 0);
    
    //GLKMatrix4 modelViewProjectionMatrix = computeModelViewProjectionMatrix(NO);
    
    GLKMatrix4 modelViewProjectionMatrix = {
        2,0,0,0,
        0,2,0,0,
        0,0,-2,0,
        0,0,0,10
    };
    
    modelViewProjectionMatrix = GLKMatrix4MakeOrtho(0, 1, 0, 1, -1, 1);
    
    glUniformMatrix4fv(uniforms_fade_scene[UNIFORM_PROJECTION_FADE_SCENE], 1, 0, modelViewProjectionMatrix.m);
    
    
    glDrawElements(GL_TRIANGLE_STRIP, 4, GL_UNSIGNED_BYTE, (void*)0);
    
    glErr = glGetError();
    if (glErr) {
        GemLog(@"GL_ERROR: %d", glErr);
    }
    
    glDeleteBuffers(1, &vBuffer);
    glDeleteBuffers(1, &iBuffer);
    
}


-(void)setupRender {
    glGenVertexArraysOES(1, &vao);
    glBindVertexArrayOES(vao);
    
    [self loadShaders];
    
    glUseProgram(program);
    
    glEnableVertexAttribArray(ATTRIB_VERTEX_FADE_SCENE);
    glEnableVertexAttribArray(ATTRIB_COLOR_FADE_SCENE);
    glEnableVertexAttribArray(ATTRIB_TEXCOORD_FADE_SCENE);
    
    /*GLKMatrix4 modelViewProjectionMatrix = computeModelViewProjectionMatrix();
    
    glUniformMatrix4fv(uniforms_fade_scene[UNIFORM_PROJECTION_FADE_SCENE], 1, 0, modelViewProjectionMatrix.m);*/
    
    glEnable(GL_DEPTH_TEST);
    glDepthFunc(GL_LEQUAL);
    
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    
    glBindVertexArrayOES(0);
}


- (BOOL)loadShaders {
    GLuint vertShader, fragShader;
    NSString *name = @"scene_transition_shader";
    
    // Create shader program.
    program = glCreateProgram();
    
    // Create and compile vertex shader.
    NSString *vertShaderPathname = [[NSBundle mainBundle] pathForResource:name ofType:@"vsh"];
    if (![self compileShader:&vertShader type:GL_VERTEX_SHADER source:vertShaderPathname]) {
        GemLog(@"Failed to compile vertex shader %@", name);
        return NO;
    }
    
    // Create and compile fragment shader.
    NSString *fragShaderPathname = [[NSBundle mainBundle] pathForResource:name ofType:@"fsh"];
    if (![self compileShader:&fragShader type:GL_FRAGMENT_SHADER source:fragShaderPathname]) {
        NSLog(@"Failed to compile fragment shader %@", name);
        return NO;
    }
    
    // Attach vertex shader to program.
    glAttachShader(program, vertShader);
    
    // Attach fragment shader to program.
    glAttachShader(program, fragShader);
    
    // Bind attribute locations.
    // This needs to be done prior to linking.
    glBindAttribLocation(program, ATTRIB_VERTEX_FADE_SCENE, "position");
    glBindAttribLocation(program, ATTRIB_COLOR_FADE_SCENE, "color");
    glBindAttribLocation(program, ATTRIB_TEXCOORD_FADE_SCENE, "texCoord");
    
    // Link program.
    if (![self linkProgram:program])
    {
        NSLog(@"Failed to link program: %d", program);
        
        if (vertShader)
        {
            glDeleteShader(vertShader);
            vertShader = 0;
        }
        if (fragShader)
        {
            glDeleteShader(fragShader);
            fragShader = 0;
        }
        if (program)
        {
            glDeleteProgram(program);
            program = 0;
        }
        
        return FALSE;
    }
    
    // Get uniform locations.
    uniforms_fade_scene[UNIFORM_PROJECTION_FADE_SCENE] = glGetUniformLocation(program, "modelViewProjectionMatrix");
    uniforms_fade_scene[UNIFORM_TEXTURE_FADE_SCENE] = glGetUniformLocation(program, "texture");
    
    // Release vertex and fragment shaders.
    if (vertShader)
        glDeleteShader(vertShader);
    if (fragShader)
        glDeleteShader(fragShader);
    
    return TRUE;
}



- (id)initWithParams:(NSDictionary *)p {
    self = [super initWithParams:p];
    [self setupRender];
    return self;
}


@end
