//
//  GemPageTurnSceneTransition.m
//  GeminiSDK
//
//  Created by James Norton on 9/27/12.
//
//

#import "GemPageTurnSceneTransition.h"
#import "Gemini.h"
#import "GemGLKViewController.h"
#include "GLUtils.h"
#include "GemOpenGLState.h"

// Sprite shader uniform index
enum {
    UNIFORM_PROJECTION_PAGE_TURN_SCENE,
    UNIFORM_TEXTURE_PAGE_TURN_SCENE,
    NUM_UNIFORMS_PAGE_TURN_SCENE
};

GLint uniforms_PAGE_TURN_scene[NUM_UNIFORMS_PAGE_TURN_SCENE];

// Sprite vertex attribute index
enum {
    ATTRIB_VERTEX_PAGE_TURN_SCENE,
    ATTRIB_COLOR_PAGE_TURN_SCENE,
    ATTRIB_TEXCOORD_PAGE_TURN_SCENE,
    NUM_ATTRIBUTES_PAGE_TURN_SCENE
};

int page_turn_render_count = 0;

static inline float funcLinear(float ft, float f0, float f1)
{
	// Linear interpolation between f0 and f1
	return f0 + (f1 - f0) * ft;
}


@implementation GemPageTurnSceneTransition


// must return YES if the transition is complete, NO otherwise
// overide this to create custom transitions
-(BOOL)transit:(double)timeSinceLastRender {
    // default implementation just switches scenes at end of transition
    BOOL rval = NO;
    elapsedTime += timeSinceLastRender;
    if (elapsedTime > duration) {
        rval = YES;
    }
    
    t = elapsedTime / duration;
    if (t > 1.0) {
        t = 1.0;
    }
    
    gamma = elapsedTime / duration * M_PI;
    //TEST
    gamma = 0;
    
    theta = M_PI/2.0 - 3.0/2.0 * M_PI * (elapsedTime / duration);
    if (theta < -M_PI) {
        theta = M_PI;
    }
    
    
    A = A - 100000 * (elapsedTime / duration);
    
    [self render];
    
    return rval;
}

-(void)render {
    GemOpenGLState *glState = [GemOpenGLState shared];
    
    glUseProgram(program);
    
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
        
        // render the mixed scenes using the two textures
        GLKView *view = (GLKView *)[Gemini shared].viewController.view;
        GLfloat contentScaleFactor = view.contentScaleFactor;
        GLuint width = view.bounds.size.width * contentScaleFactor;
        GLuint height = view.bounds.size.height * contentScaleFactor;
        
        
        [view bindDrawable];
        glViewport(0,0, width, height);
        
        // TODO - figure out why this is necessary and fix it
        if (page_turn_render_count == 1) {
            texturedAreRendered = YES;
            
        } else {
            page_turn_render_count++;
        }
        
        
    }
        
    //[self renderSceneTexture:textureB WithXOffset:xOffsetB YOffset:0];
    GemScene *defaultScene = [((GemGLKViewController *)[Gemini shared].viewController).director getDefaultScene];
    [((GemGLKViewController *)[Gemini shared].viewController).director.renderer renderScene:sceneB];
    [((GemGLKViewController *)[Gemini shared].viewController).director.renderer renderScene:defaultScene];
    glDisable(GL_BLEND);
    [self renderSceneTexture:textureA WithPageTurn:gamma];
    glEnable(GL_BLEND);
       
}


-(void)renderSceneTexture:(GLuint)texture WithPageTurn:(GLfloat)gmma {
    GLenum glErr;
    glGetError();
    
    GemOpenGLState *glState = [GemOpenGLState shared];
    if (glState.boundVertexArrayObject != vao) {
        glBindVertexArrayOES(vao);
        glState.boundVertexArrayObject = vao;
    }
    
    
    
    glUseProgram(program);
    glErr = glGetError();
    
    //glDepthMask(GL_FALSE);
    glDisable(GL_DEPTH_TEST);
    //glEnable(GL_DEPTH_TEST);
    
    
    
    //glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    //glEnable(GL_BLEND);
    glDisable(GL_BLEND);
    
    glBindBuffer(GL_ARRAY_BUFFER, vBuffer);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, iBuffer);
    
    
    
    CGFloat angle1 =  M_PI;  //  }
    //CGFloat angle2 =   0.13962634;  //  }
    CGFloat angle2 =   0.13962634;
    CGFloat angle3 =   0.104719755;  //  }
    CGFloat     A1 = -15.0f;        //  }
    CGFloat     A2 =  -2.5f;        //  }--- Experiment with these parameters to adjust the page turn behavior to your liking.
    CGFloat     A3 =  -3.5f;        //  }
    CGFloat theta1 =   0.05f;       //  }
    CGFloat theta2 =   0.5f;        //  }
    CGFloat theta3 =  10.0f;        //  }
    CGFloat theta4 =   2.0f;        //  }
    
    CGFloat f1, f2, dt;
    
    // Here rho, the angle of the page rotation around the spine, is a linear function of time t. This is the simplest case and looks
    // Good Enough. A side effect is that due to the curling effect, the page appears to accelerate quickly at the beginning
    // of the turn, then slow down toward the end as the page uncurls and returns to its natural form, just like in real life.
    // A non-linear function may be slightly more realistic but is beyond the scope of this example.
    GLfloat rho = t * M_PI;
    
	if (t <= 0.15f)
	{
        // Start off with a flat page with no deformation at the beginning of a page turn, then begin to curl the page gradually
        // as the hand lifts it off the surface of the book.
		dt = t / 0.15;
		f1 = sin(M_PI * pow(dt, theta1) / 2.0);
		f2 = sin(M_PI * pow(dt, theta2) / 2.0);
        theta = funcLinear(f1, angle1, angle2);
		A = funcLinear(f2, A1, A2);
	}
	else if (t <= 0.4)
	{
        // Produce the most pronounced curling near the middle of the turn. Here small values of theta and A
        // result in a short, fat cone that distinctly show the curl effect.
		dt = (t - 0.15) / 0.25;
		theta = funcLinear(dt, angle2, angle3);
		A = funcLinear(dt, A2, A3);
	}
	else if (t <= 1.0)
	{
        // Near the middle of the turn, the hand has released the page so it can return to its normal form.
        // Ease out the curl until it returns to a flat page at the completion of the turn. More advanced simulations
        // could apply a slight wobble to the page as it falls down like in real life.
		dt = (t - 0.4) / 0.6;
		f1 = sin(M_PI * pow(dt, theta3) / 2.0);
		f2 = sin(M_PI * pow(dt, theta4) / 2.0);
		//theta = funcLinear(f1, angle3, angle1);
        theta = funcLinear(f1, angle3, 0);
		A = funcLinear(f2, A3, A1);
	}

    
    // create the verts and indices for a grid using GL_TRIANGLE_STRIPS
    GemTexturedVertex *verts = (GemTexturedVertex *)malloc(gridX * gridY * sizeof(GemTexturedVertex));
    for (int j=0; j<gridY; j++) {
        
        for (int i=0; i<gridX; i++) {
            GLfloat x = (GLfloat)i / (GLfloat)(gridX - 1);
            GLfloat y = (GLfloat)j / (GLfloat)(gridY - 1);
            
            GLfloat R = sqrtf(x*x + (y-A)*(y-A));
            GLfloat beta = asin(x/R) / sin(theta);
            GLfloat r = R * sin(theta);
            
            GLfloat xi = r*sin(beta);
            GLfloat yi = R + A - r*(1-cos(beta))*sin(theta);
            GLfloat zi = r*(1-cos(beta))*cos(theta);
            
            verts[i + j*gridX].position[0] = xi*cos(rho) - zi*(sin(rho));
            verts[i + j*gridX].position[1] = yi;
            verts[i + j*gridX].position[2] = xi*sin(rho) + zi*cos(rho) - 10.0;
            
            verts[i + j*gridX].color[0] = 1.0;
            verts[i + j*gridX].color[1] = 1.0;
            verts[i + j*gridX].color[2] = 1.0;
            verts[i + j*gridX].color[3] = 1.0;
            
            verts[i + j*gridX].texCoord[0] = x;
            verts[i + j*gridX].texCoord[1] = y;
            
            /*if (t > 0.95 && i == gridX - 1 && j == gridY - 1) {
                GemLog(@"(x0,y0,z0) = (%f,%f,%f)", x,y,1.0);
                GemLog(@"(x,y,z) = (%f,%f,%f)", verts[i + j*gridX].position[0],verts[i + j*gridX].position[1],verts[i + j*gridX].position[2]);
                GemLog(@"R = %f", R);
                GemLog(@"beta = %f", beta);
                GemLog(@"r = %f", r);
                GemLog(@"rho = %f", rho);
                GemLog(@"t = %f", t);
            }*/
            
            
        }        
    }
    
    glBufferSubData(GL_ARRAY_BUFFER, 0, gridX*gridY*sizeof(GemTexturedVertex), verts);
    
    
    glVertexAttribPointer(ATTRIB_VERTEX_PAGE_TURN_SCENE, 3, GL_FLOAT, GL_FALSE, sizeof(GemTexturedVertex), (GLvoid *)0);
    
    glVertexAttribPointer(ATTRIB_COLOR_PAGE_TURN_SCENE, 4, GL_FLOAT, GL_FALSE,
                          sizeof(GemTexturedVertex), (GLvoid*) (sizeof(float) * 3));
    glVertexAttribPointer(ATTRIB_TEXCOORD_PAGE_TURN_SCENE, 2, GL_FLOAT, GL_FALSE, sizeof(GemTexturedVertex), (GLvoid *)(sizeof(float) * 7));
    
    glActiveTexture(GL_TEXTURE0);
    
    glBindTexture(GL_TEXTURE_2D, texture);
    glUniform1i(uniforms_PAGE_TURN_scene[UNIFORM_TEXTURE_PAGE_TURN_SCENE], 0);
    
    GLKMatrix4 modelViewProjectionMatrix = GLKMatrix4MakeOrtho(0, 1, 0, 1, 0.01, 10);
    
    glUniformMatrix4fv(uniforms_PAGE_TURN_scene[UNIFORM_PROJECTION_PAGE_TURN_SCENE], 1, 0, modelViewProjectionMatrix.m);
    
    glEnable(GL_CULL_FACE);
    glFrontFace(GL_CW);
    
    GLuint numElements = 2*(gridY - 1)*(gridX + 1);
    
    
    glDrawElements(GL_TRIANGLE_STRIP, numElements, GL_UNSIGNED_SHORT, (void*)0);
    
    // now render the back of the page
    //if (glState.boundVertexArrayObject != vao) {
        //glBindVertexArrayOES(backPageVao);
       // glState.boundVertexArrayObject = vao;
   // }
    glBindBuffer(GL_ARRAY_BUFFER, vBuffer);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, backPageIBuffer);
    glBindTexture(GL_TEXTURE_2D, paperTexture.name);
    
    glDrawElements(GL_TRIANGLE_STRIP, numElements, GL_UNSIGNED_SHORT, (void*)0);
    
    glBindVertexArrayOES(vao);
    
    glDisable(GL_CULL_FACE);
    
    free(verts);
}

-(void)setupRender {
    
    // create paper texture
    paperTexture = createTexture(@"paper.png");
    
    glGenVertexArraysOES(1, &vao);
    glBindVertexArrayOES(vao);
    GemOpenGLState *glState = [GemOpenGLState shared];
    glState.boundVertexArrayObject = vao;
    
    [self loadShaders];
    
    glUseProgram(program);
    
    glEnableVertexAttribArray(ATTRIB_VERTEX_PAGE_TURN_SCENE);
    glEnableVertexAttribArray(ATTRIB_COLOR_PAGE_TURN_SCENE);
    glEnableVertexAttribArray(ATTRIB_TEXCOORD_PAGE_TURN_SCENE);
    
    glEnable(GL_DEPTH_TEST);
    glDepthMask(GL_TRUE);
    glDepthFunc(GL_LEQUAL);
    
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    
    glGenBuffers(1, &vBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, vBuffer);
    glBufferData(GL_ARRAY_BUFFER, gridX*gridY*sizeof(GemTexturedVertex), NULL, GL_DYNAMIC_DRAW);
    
    glGenBuffers(1, &iBuffer);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, iBuffer);
    GLuint numBytes = (2*(gridY - 1)*(gridX + 1)) * sizeof(GLushort);
    GLushort *index = (GLushort *)malloc(numBytes);
    GLushort *backPageIndex = (GLushort *)malloc(numBytes);
    GLuint index_count = 0;
    GLuint back_index_count = 0;
    for (int j=0; j<gridY-1; j++) {
        for (int i=0; i<gridX; i++) {
            GLushort idx = i + j*gridX;
            GLushort idx2 = idx + gridX;
            GLushort bp_idx = (j+1)*gridX - i - 1;
            GLushort bp_idx2 = bp_idx + gridX;

            index[index_count++] = idx;
            backPageIndex[back_index_count++] = bp_idx;
            
            if (i == 0 && j > 0) {
                index[index_count++] = idx;
                backPageIndex[back_index_count++] = bp_idx;
            }
            index[index_count++] = idx2;
            
            backPageIndex[back_index_count++] = bp_idx2;
            
            
            if (i == gridX - 1) {
                index[index_count++] = i + (j+1)*gridX;
                backPageIndex[back_index_count++] = bp_idx2;
            }
            
        }
    }
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, numBytes, index, GL_STATIC_DRAW);
    
    glGenBuffers(1, &backPageIBuffer);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, backPageIBuffer);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, numBytes, backPageIndex, GL_STATIC_DRAW);
    
    glBindVertexArrayOES(0);
    
    free(index);
    free(backPageIndex);
    
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
    glBindAttribLocation(program, ATTRIB_VERTEX_PAGE_TURN_SCENE, "position");
    glBindAttribLocation(program, ATTRIB_COLOR_PAGE_TURN_SCENE, "color");
    glBindAttribLocation(program, ATTRIB_TEXCOORD_PAGE_TURN_SCENE, "texCoord");
    
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
    uniforms_PAGE_TURN_scene[UNIFORM_PROJECTION_PAGE_TURN_SCENE] = glGetUniformLocation(program, "modelViewProjectionMatrix");
    uniforms_PAGE_TURN_scene[UNIFORM_TEXTURE_PAGE_TURN_SCENE] = glGetUniformLocation(program, "texture");
    
    // Release vertex and fragment shaders.
    if (vertShader)
        glDeleteShader(vertShader);
    if (fragShader)
        glDeleteShader(fragShader);
    
    return TRUE;
}



- (id)initWithParams:(NSDictionary *)p {
    self = [super initWithParams:p];
    gridX = 10;
    gridY = 10;
    A = 0;
    theta = M_PI;
    //duration = 7.0;
    t = 0;
    [self setupRender];
    return self;
}

-(void)reset {
    [super reset];
    theta = M_PI;
    A = 0;
    gamma = 0;
    t = 0;
}

-(void)dealloc {
    
}


@end
