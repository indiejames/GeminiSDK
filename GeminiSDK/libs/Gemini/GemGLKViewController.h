//
//  GeminiGLKViewController.h
//  Gemini
//
//  Created by James Norton on 2/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <GLKit/GLKit.h>
#import "GemLineShaderManager.h"
#import "GemRenderer.h"
#import "GemSpriteManager.h"
#import "GemTimerManager.h"

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



@interface GemGLKViewController : GLKViewController {
    EAGLContext *context;
    SEL preRenderCallback;
    SEL postRenderCallback;
    GemShaderManager *lineShaderManager;
    GemRenderer *renderer;
    GemSpriteManager *spriteManager;
    GemTimerManager *timerManager;
    
    double updateTime;
}

@property (readonly) GemRenderer *renderer;
@property (readonly) GemSpriteManager *spriteManager;
@property (readonly) GemTimerManager *timerManager;
@property (readonly) double updateTime;

-(void)setPreRenderCallback:(SEL)callback;
-(void)setPostRenderCallback:(SEL)callback;
-(id)initWithLuaState:(lua_State *)luaState;
@end
