//
//  GemSlideSceneTransition.m
//  GeminiSDK
//
//  Created by James Norton on 9/20/12.
//
//

#import "GemSlideSceneTransition.h"
#import "Gemini.h"
#import "GemGLKViewController.h"
#include "GLUtils.h"
#include "GemOpenGLState.h"

// Sprite shader uniform index
enum {
    UNIFORM_PROJECTION_SLIDE_SCENE,
    UNIFORM_TEXTURE_SLIDE_SCENE,
    NUM_UNIFORMS_SLIDE_SCENE
};

GLint uniforms_slide_scene[NUM_UNIFORMS_SLIDE_SCENE];

// Sprite vertex attribute index
enum {
    ATTRIB_VERTEX_SLIDE_SCENE,
    ATTRIB_COLOR_SLIDE_SCENE,
    ATTRIB_TEXCOORD_SLIDE_SCENE,
    NUM_ATTRIBUTES_SLIDE_SCENE
};

int count = 0;

@implementation GemSlideSceneTransition

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
    GemOpenGLState *glState = [GemOpenGLState shared];
    
    // render the two scenes involved in the transition to textures so we can do cool things with them
    // this is only done once at the beginning
    if (!texturedAreRendered) {
        // get the default scene (always rendered)
        GemScene *defaultScene = [((GemGLKViewController *)[Gemini shared].viewController).director getDefaultScene];
        
        //set the viewport to be the size of the texture
        glViewport(0,0, textWidth, textHeight);
        
        glBindFramebuffer(GL_FRAMEBUFFER, fboA);
        
        //clear the ouput texture for A
        if (glState.depthMask = GL_FALSE) {
            glDepthMask(GL_TRUE);
            glState.depthMask = GL_TRUE;
        }
        
        //glClearColor(0, 0, 0, 1);
        glClear ( GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
        
        [((GemGLKViewController *)[Gemini shared].viewController).director.renderer renderScene:sceneA];
        [((GemGLKViewController *)[Gemini shared].viewController).director.renderer renderScene:defaultScene];
        
        //const GLenum discards[]  = {GL_DEPTH_ATTACHMENT};
        //glDiscardFramebufferEXT(GL_FRAMEBUFFER,1,discards);
        
        glBindFramebuffer(GL_FRAMEBUFFER, fboB);
        
        //clear the ouput texture for B
        glClear ( GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
        
        [((GemGLKViewController *)[Gemini shared].viewController).director.renderer renderScene:sceneB];
        [((GemGLKViewController *)[Gemini shared].viewController).director.renderer renderScene:defaultScene];
        
        //glDiscardFramebufferEXT(GL_FRAMEBUFFER,1,discards);
        
        // render the mixed scenes using the two textures
        GLKView *view = (GLKView *)[Gemini shared].viewController.view;
        GLfloat contentScaleFactor = view.contentScaleFactor;
        GLuint width = view.bounds.size.width * contentScaleFactor;
        GLuint height = view.bounds.size.height * contentScaleFactor;
        
        
        [view bindDrawable];
        glViewport(0,0, width, height);
        
        // TODO - figure out why this is necessary and fix it
        if (count == 1) {
            texturedAreRendered = YES;
        
        } else {
            count++;
        }
        
        
    }
    
    
    //glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    GLfloat xOffsetA = 0;
    GLfloat yOffsetA = 0;
    GLfloat xOffsetB = 0;
    GLfloat yOffsetB = 0;
    GLfloat offset = elapsedTime / duration;
    if (offset > 1.0) {
        offset = 1.0;
    }
    
    NSString *direction = [params objectForKey:@"direction"];
    if ([direction isEqualToString:@"up"]) {
        yOffsetA = offset;
        yOffsetB = -(1 - offset);
    } else if ([direction isEqualToString:@"down"]){
        yOffsetA = -offset;
        yOffsetB = 1 - offset;
    } else if ([direction isEqualToString:@"left"]){
        xOffsetA = -offset;
        xOffsetB = 1 - offset;  
    } else if ([direction isEqualToString:@"right"]){
        yOffsetA = offset;
        yOffsetB = 1 - offset;
    }
    
    [self renderSceneTexture:textureA WithXOffset:xOffsetA YOffset:yOffsetA];
    [self renderSceneTexture:textureB WithXOffset:xOffsetB YOffset:yOffsetB];
    
}



-(void)renderSceneTexture:(GLuint)texture WithXOffset:(GLfloat)xOffset YOffset:(GLfloat)yOffset {
    GLenum glErr;
    glGetError();
    
    GemOpenGLState *glState = [GemOpenGLState shared];
    if (glState.boundVertexArrayObject != vao) {
        glBindVertexArrayOES(vao);
        glState.boundVertexArrayObject = vao;
    }
   
    
    
    glUseProgram(program);
    glErr = glGetError();
    
    glDepthMask(GL_FALSE);
    glDisable(GL_DEPTH_TEST);
    
    
    
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    glEnable(GL_BLEND);
    
    glBindBuffer(GL_ARRAY_BUFFER, vBuffer);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, iBuffer);
    
    
    GemTexturedVertex verts[] = {
        {{xOffset,yOffset,-0.5}, {1,1,1,1}, {0,0}},
        {{xOffset,1+yOffset,-0.5}, {1,1,1,1}, {0,1}},
        {{1+xOffset,yOffset,-0.5}, {1,1,1,1}, {1,0}},
        {{1+xOffset,1+yOffset,-0.5}, {1,1,1,1}, {1,1}}
    };
    
   glBufferSubData(GL_ARRAY_BUFFER, 0, 4*sizeof(GemTexturedVertex), verts);
    
   //glBufferData(GL_ARRAY_BUFFER, 4*sizeof(GemTexturedVertex), verts, GL_STATIC_DRAW);
    
    
    
    glVertexAttribPointer(ATTRIB_VERTEX_SLIDE_SCENE, 3, GL_FLOAT, GL_FALSE, sizeof(GemTexturedVertex), (GLvoid *)0);
    
    glVertexAttribPointer(ATTRIB_COLOR_SLIDE_SCENE, 4, GL_FLOAT, GL_FALSE,
                          sizeof(GemTexturedVertex), (GLvoid*) (sizeof(float) * 3));
    glVertexAttribPointer(ATTRIB_TEXCOORD_SLIDE_SCENE, 2, GL_FLOAT, GL_FALSE, sizeof(GemTexturedVertex), (GLvoid *)(sizeof(float) * 7));
    
    glActiveTexture(GL_TEXTURE0);
    
    glBindTexture(GL_TEXTURE_2D, texture);
    glUniform1i(uniforms_slide_scene[UNIFORM_TEXTURE_SLIDE_SCENE], 0);
    
    //GLKMatrix4 modelViewProjectionMatrix = computeModelViewProjectionMatrix(NO);
    
    GLKMatrix4 modelViewProjectionMatrix = {
        2,0,0,0,
        0,2,0,0,
        0,0,-2,0,
        0,0,0,10
    };
    
    modelViewProjectionMatrix = GLKMatrix4MakeOrtho(0, 1, 0, 1, -1, 1);
    
    glUniformMatrix4fv(uniforms_slide_scene[UNIFORM_PROJECTION_SLIDE_SCENE], 1, 0, modelViewProjectionMatrix.m);
    
    
    glDrawElements(GL_TRIANGLE_STRIP, 4, GL_UNSIGNED_SHORT, (void*)0);
    
}


-(void)setupRender {
    glGenVertexArraysOES(1, &vao);
    glBindVertexArrayOES(vao);
    GemOpenGLState *glState = [GemOpenGLState shared];
    glState.boundVertexArrayObject = vao;
    
    [self loadShaders];
    
    glUseProgram(program);
    
    glEnableVertexAttribArray(ATTRIB_VERTEX_SLIDE_SCENE);
    glEnableVertexAttribArray(ATTRIB_COLOR_SLIDE_SCENE);
    glEnableVertexAttribArray(ATTRIB_TEXCOORD_SLIDE_SCENE);
    
    /*GLKMatrix4 modelViewProjectionMatrix = computeModelViewProjectionMatrix();
     
     glUniformMatrix4fv(uniforms_SLIDE_scene[UNIFORM_PROJECTION_SLIDE_SCENE], 1, 0, modelViewProjectionMatrix.m);*/
    
    glEnable(GL_DEPTH_TEST);
    glDepthMask(GL_TRUE);
    glDepthFunc(GL_LEQUAL);
    
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    
    glGenBuffers(1, &vBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, vBuffer);
    glBufferData(GL_ARRAY_BUFFER, 4*sizeof(GemTexturedVertex), NULL, GL_DYNAMIC_DRAW);
    
    glGenBuffers(1, &iBuffer);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, iBuffer);
    GLushort index[] = {
        0,1,2,3
    };
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, 4*sizeof(GLushort), index, GL_STATIC_DRAW);
    
    glBindVertexArrayOES(0);
    
    glState.boundVertexArrayObject = 0;
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
    glBindAttribLocation(program, ATTRIB_VERTEX_SLIDE_SCENE, "position");
    glBindAttribLocation(program, ATTRIB_COLOR_SLIDE_SCENE, "color");
    glBindAttribLocation(program, ATTRIB_TEXCOORD_SLIDE_SCENE, "texCoord");
    
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
    uniforms_slide_scene[UNIFORM_PROJECTION_SLIDE_SCENE] = glGetUniformLocation(program, "modelViewProjectionMatrix");
    uniforms_slide_scene[UNIFORM_TEXTURE_SLIDE_SCENE] = glGetUniformLocation(program, "texture");
    
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
