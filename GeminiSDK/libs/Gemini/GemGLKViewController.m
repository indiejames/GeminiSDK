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
#import <QuartzCore/CAEAGLLayer.h>

// Uniform index.
enum {
    UNIFORM_PROJECTION,
    UNIFORM_ROTATION,
    NUM_UNIFORMS
};
GLint uniforms[NUM_UNIFORMS];

// Attribute index.
enum {
    ATTRIB_VERTEX,
    ATTRIB_TEXCOORD,
    NUM_ATTRIBUTES
};



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
@synthesize spriteManager;
@synthesize timerManager;
@synthesize eventManager;
@synthesize particleSystemManager;
@synthesize director;
@synthesize displayType;
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
        displayType = GEM_IPHONE;
    }
    
    return self;
}


-(void) viewDidLoad {
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){
        if ([[UIScreen mainScreen] respondsToSelector: @selector(scale)]) {
            CGSize result = [[UIScreen mainScreen] bounds].size;
            CGFloat scale = [UIScreen mainScreen].scale;
            result = CGSizeMake(result.width * scale, result.height * scale);
            
            if(result.height == 960){
                NSLog(@"iphone 4, 4s retina resolution");
                displayType = GEM_IPHONE_RETINA;
            }
            if(result.height == 1136){
                NSLog(@"iphone 5 resolution");
                displayType = GEM_IPHONE_5;
            }
            if (result.height == 480) {
                GemLog(@"iphone standard resolution");
                displayType = GEM_IPHONE;
            }
        }
        else{
            NSLog(@"iphone standard resolution");
            displayType = GEM_IPHONE;
        }
    }
    else{
        if ([[UIScreen mainScreen] respondsToSelector: @selector(scale)]) {
            if ([UIScreen mainScreen].scale == 2.0) {
                NSLog(@"ipad Retina resolution");
                displayType = GEM_IPAD_RETINA;
            } else {
                NSLog(@"ipad resolution");
                displayType = GEM_IPAD;
            }
            
        }
        else{
            NSLog(@"ipad Standard resolution");
            displayType = GEM_IPAD;
        }
    }
    
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    
    if (!self.context) {
        NSLog(@"Failed to create ES context");
    }
    
    GLKView *view = (GLKView *)self.view;
    view.context = self.context;
    //view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    view.drawableDepthFormat = GLKViewDrawableDepthFormat16;
    //view.drawableMultisample = GLKViewDrawableMultisample4X;
    //view.contentScaleFactor = 2.0;
    view.contentScaleFactor = [UIScreen mainScreen].scale;
    /*CAEAGLLayer *lyr = (CAEAGLLayer *)view.layer;
    lyr.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
                               [NSNumber numberWithBool:FALSE], kEAGLDrawablePropertyRetainedBacking, kEAGLColorFormatRGB565, kEAGLDrawablePropertyColorFormat, nil];
    */
    GemLog(@"view.contentScaleFactor = %f", view.contentScaleFactor);
    
    self.preferredFramesPerSecond = 60;
    
    [self setupGL];
    eventManager = [[GemEventManager alloc] initWithLuaState:L];
    eventManager.parentGLKViewController = self;
    particleSystemManager = [[GemParticleSystemManager alloc] init];
    timerManager = [[GemTimerManager alloc] init];
    
    view.multipleTouchEnabled = YES;
    
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
    //renderer = [[GemRenderer alloc] initWithLuaState:L];
    director = [[GemDirector alloc] initWithLuaState:L];
    //[renderer addLayer:createLayerZero(L)];
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
    //width = 960;
   // height = 640;
    
    /*NSLog(@"width = %d", width);
    NSLog(@"height = %d", height);
    NSLog(@"main screen scale = %f", scale);*/
    
    updateTime += timeDelta;
    
    [timerManager update:updateTime];
    [spriteManager update:updateTime];
    [particleSystemManager update:updateTime];
    
    [[Gemini shared] update:timeDelta];
    
}

- (void)glkViewController:(GLKViewController *)controller willPause:(BOOL)pause {
    
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    glDepthMask(GL_TRUE);
    [GemOpenGLState shared].glDepthMask = GL_TRUE;
    
    glClearColor(0, 0, 0, 1.0);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    // compute frame rate
    if (frameCount > 0) {
        frameRenderTime += self.timeSinceLastDraw;
    }
    
    if (frameCount == 300) {
        double frameRate = (double)frameCount / frameRenderTime;
        frameCount = 0;
        frameRenderTime = 0;
        GemLog(@"frame rate = %f", frameRate);
    }
    
    frameCount += 1;
    
    // call the pre render method
    if (preRenderCallback) {
        [self performSelector:preRenderCallback];
    }
    
    
    
    // do our thing
    
    //[renderer render];
    [director render:self.timeSinceLastDraw];
    
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

// Touch events
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [eventManager touchesBegan:touches withEvent:event];
}
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    [eventManager touchesMoved:touches withEvent:event];
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [eventManager touchesEnded:touches withEvent:event];
}
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [eventManager touchesCancelled:touches withEvent:event];
}


@end
