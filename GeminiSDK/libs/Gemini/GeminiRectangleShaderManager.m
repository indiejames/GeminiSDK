//
//  GeminiRectangleShaderManager.m
//  Gemini
//
//  Created by James Norton on 5/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GeminiRectangleShaderManager.h"

@implementation GeminiRectangleShaderManager

- (BOOL)loadShaders
{
    GLuint vertShader, fragShader;
    
    // Create shader program.
    program = glCreateProgram();
    
    // Create and compile vertex shader.
    NSString *vertShaderPathname = [[NSBundle mainBundle] pathForResource:@"rectangle_shader" ofType:@"vsh"];
    if (![self compileShader:&vertShader type:GL_VERTEX_SHADER source:vertShaderPathname]) {
        NSLog(@"Failed to compile vertex shader for rectangles");
        return NO;
    }
    
    // Create and compile fragment shader.
    NSString *fragShaderPathname = [[NSBundle mainBundle] pathForResource:@"rectangle_shader" ofType:@"fsh"];
    if (![self compileShader:&fragShader type:GL_FRAGMENT_SHADER source:fragShaderPathname]) {
        NSLog(@"Failed to compile fragment shader for rectangles");
        return NO;
    }
    
    // Attach vertex shader to program.
    glAttachShader(program, vertShader);
    
    // Attach fragment shader to program.
    glAttachShader(program, fragShader);
    
    // Bind attribute locations.
    // This needs to be done prior to linking.
    glBindAttribLocation(program, ATTRIB_VERTEX_RECTANGLE, "position");
    glBindAttribLocation(program, ATTRIB_COLOR_RECTANGLE, "color");
    
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
    uniforms_rectangle[UNIFORM_PROJECTION_RECTANGLE] = glGetUniformLocation(program, "modelViewProjectionMatrix");
    // Release vertex and fragment shaders.
    if (vertShader)
        glDeleteShader(vertShader);
    if (fragShader)
        glDeleteShader(fragShader);
    
    return TRUE;
}


@end
