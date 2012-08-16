//
//  GeminiSpriteShaderManager.h
//  Gemini
//
//  Created by James Norton on 3/31/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GemShaderManager.h"

// Sprite shader uniform index
enum {
    UNIFORM_PROJECTION_SPRITE,
    UNIFORM_TEXTURE_SPRITE,
    NUM_UNIFORMS_SPRITE
};

GLint uniforms_sprite[NUM_UNIFORMS_SPRITE];

// Sprite vertex attribute index
enum {
    ATTRIB_VERTEX_SPRITE,
    ATTRIB_COLOR_SPRITE,
    ATTRIB_TEXCOORD_SPRITE,
    NUM_ATTRIBUTES_SPRITE
};


@interface GemSpriteShaderManager : GemShaderManager

@end
