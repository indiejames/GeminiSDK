//
//  GeminiRectangleShaderManager.h
//  Gemini
//
//  Created by James Norton on 5/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GemShaderManager.h"

// Line shader uniform index
enum {
    UNIFORM_PROJECTION_RECTANGLE,
    NUM_UNIFORMS_RECTANGLE
};

GLint uniforms_rectangle[NUM_UNIFORMS_RECTANGLE];

// Line attribute index
enum {
    ATTRIB_VERTEX_RECTANGLE,
    ATTRIB_COLOR_RECTANGLE,
    NUM_ATTRIBUTES_RECTANGLE
};

@interface GeminiRectangleShaderManager : GemShaderManager

@end
