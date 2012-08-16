//
//  GeminiGLKViewController.m
//  Gemini
//
//  Created by James Norton on 2/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Gemini.h"
#import "GemGLKViewController.h"
#import "GemRenderer.h"
#import "LGeminiDisplay.h"

//NSString *spriteFragmentShaderStr = @"uniform sampler2D texture; // texture sampler\nuniform highp float alpha; // alpha value for image\nvarying highp vec2 vTexCoord; // texture coordinates\nvoid main()\n{\nhighp vec4 texVal = texture2D(texture, vTexCoord);\ngl_FragColor = texVal;\n}";
NSString *spriteFragmentShaderStr = @"void main(){\ngl_FragColor = vec4(1.0,1.0,1.0,1.0);\n}";
NSString *spriteVertexShaderStr = @"attribute vec4 position;\nattribute vec2 texCoord;\nvarying vec2 vTexCoord;\nuniform mat4 proj;\nuniform mat4 rot;\nvoid main()\n{\ngl_Position = proj * rot * position;\nvTexCoord = texCoord;\n}";


@interface GemGLKViewController () {
    
    GLKMatrix4 _modelViewProjectionMatrix;
    GLKMatrix3 _normalMatrix;
    
    GLKMatrix4 planetModelViewProjectionMatrix;
    GLKMatrix3 planetNormalMatrix;
    
    GLuint _vertexArray;
    GLuint _vertexBuffer;
    
    GLuint planetVertexBuffer;
    GLuint planetIndexBuffer;
    
    GLuint quadVertexBuffer;
    GLuint quadIndexBuffer;
    
    lua_State *L;
    
    double frameRenderTime;
    double frameCount;
    
}
@property (strong, nonatomic) EAGLContext *context;
@property (nonatomic) lua_State *L;

- (void)setupGL;
- (void)tearDownGL;

@end

@implementation GemGLKViewController
@synthesize context;
@synthesize renderer;
@synthesize spriteManager;
@synthesize timerManager;
@synthesize updateTime;
@synthesize L;

-(id)initWithLuaState:(lua_State *)luaState {
    self = [super init];
    
    if (self) {
            
        preRenderCallback = nil;
        postRenderCallback = nil;
        L = luaState;
        frameCount = 0;
        frameRenderTime = 0;
        updateTime = 0;
    }
    
    return self;
}


-(void) viewDidLoad {
    self.context = [[[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2] autorelease];
    
    if (!self.context) {
        NSLog(@"Failed to create ES context");
    }
    
    GLKView *view = (GLKView *)self.view;
    view.context = self.context;
    //view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    view.drawableDepthFormat = GLKViewDrawableDepthFormat16;
    view.drawableMultisample = GLKViewDrawableMultisample4X;
    view.contentScaleFactor = 2.0;
    
    self.preferredFramesPerSecond = 60;
    
    [self setupGL];
    
    timerManager = [[GemTimerManager alloc] init];
}

- (void)viewDidUnload
{    
    [super viewDidUnload];
    
    [self tearDownGL];
    
    if ([EAGLContext currentContext] == self.context) {
        [EAGLContext setCurrentContext:nil];
    }
	self.context = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    BOOL rval = interfaceOrientation == UIInterfaceOrientationLandscapeLeft || interfaceOrientation == UIInterfaceOrientationLandscapeRight;
    
    return rval;
}

- (void)setupGL
{
        
    [EAGLContext setCurrentContext:self.context];
    
    // load the renderer
    renderer = [[GemRenderer alloc] initWithLuaState:L];
    [renderer addLayer:createLayerZero(L)];
    spriteManager = [[GemSpriteManager alloc] init];
}


- (void)tearDownGL
{
    [EAGLContext setCurrentContext:self.context];
    
    glDeleteBuffers(1, &_vertexBuffer);
    glDeleteVertexArraysOES(1, &_vertexArray);
    
}

- (void)update
{
    //NSLog(@"update()");
    //double scale = [UIScreen mainScreen].scale;
    double timeDelta = self.timeSinceLastUpdate;
    
    GLint width;
    GLint height;
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &width);
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &height);
    
    /*NSLog(@"width = %d", width);
    NSLog(@"height = %d", height);
    NSLog(@"main screen scale = %f", scale);*/
    
    updateTime += timeDelta;
    
    [timerManager update:updateTime];
    [spriteManager update:updateTime];
    
    [[Gemini shared] update:timeDelta];
    
}

- (void)glkViewController:(GLKViewController *)controller willPause:(BOOL)pause {
    
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    glDepthMask(GL_TRUE);
    
    glClearColor(0, 0, 0, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    // compute frame rate
    if (frameCount > 0) {
        frameRenderTime += self.timeSinceLastDraw;
    }
    
    if (frameCount == 60) {
        double frameRate = (double)frameCount / frameRenderTime;
        frameCount = 0;
        frameRenderTime = 0;
        NSLog(@"frame rate = %f", frameRate);
    }
    
    frameCount += 1;
    
    //NSLog(@"Drawing");
   // glClearColor(0, 0.0, 1.0, 1.0);
    //glClear(GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT);
    
     // call the pre render method
    if (preRenderCallback) {
        [self performSelector:preRenderCallback];
    }
    
    
    
    // do our thing
    
    [renderer render];
    
    
    //////////////////////////////
    
    
    // call the post render method
    if (postRenderCallback) {
        [self performSelector:postRenderCallback];
    }
    
    const GLenum discards[]  = {GL_DEPTH_ATTACHMENT};
    glDiscardFramebufferEXT(GL_FRAMEBUFFER,1,discards);
    
}

- (void) setPreRenderCallback:(SEL)callback {
    preRenderCallback = callback;
}

- (void) setPostRenderCallback:(SEL)callback {
    postRenderCallback = callback;
}

@end
