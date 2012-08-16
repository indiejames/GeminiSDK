//
//  GeminiSpriteShaderManager.m
//  Gemini
//
//  Created by James Norton on 3/31/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GemSpriteShaderManager.h"

@implementation GemSpriteShaderManager

- (BOOL)loadShaders
{
    GLuint vertShader, fragShader;
    
    // Create shader program.
    program = glCreateProgram();
    
    // Create and compile vertex shader.
    NSString *vertShaderPathname = [[NSBundle mainBundle] pathForResource:@"sprite_shader" ofType:@"vsh"];
    if (![self compileShader:&vertShader type:GL_VERTEX_SHADER source:vertShaderPathname]) {
        NSLog(@"Failed to compile vertex shader for sprites");
        return NO;
    }
    
    // Create and compile fragment shader.
    NSString *fragShaderPathname = [[NSBundle mainBundle] pathForResource:@"sprite_shader" ofType:@"fsh"];
    if (![self compileShader:&fragShader type:GL_FRAGMENT_SHADER source:fragShaderPathname]) {
        NSLog(@"Failed to compile fragment shader for sprites");
        return NO;
    }
    
    // Attach vertex shader to program.
    glAttachShader(program, vertShader);
    
    // Attach fragment shader to program.
    glAttachShader(program, fragShader);
    
    // Bind attribute locations.
    // This needs to be done prior to linking.
    glBindAttribLocation(program, ATTRIB_VERTEX_SPRITE, "position");
    glBindAttribLocation(program, ATTRIB_COLOR_SPRITE, "color");
    glBindAttribLocation(program, ATTRIB_TEXCOORD_SPRITE, "texCoord");
    
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
    uniforms_sprite[UNIFORM_PROJECTION_SPRITE] = glGetUniformLocation(program, "modelViewProjectionMatrix");
    uniforms_sprite[UNIFORM_TEXTURE_SPRITE] = glGetUniformLocation(program, "texture");
    
    // Release vertex and fragment shaders.
    if (vertShader)
        glDeleteShader(vertShader);
    if (fragShader)
        glDeleteShader(fragShader);
    
    return TRUE;
}


@end
