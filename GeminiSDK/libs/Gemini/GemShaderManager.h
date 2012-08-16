//
//  GeminiShaderManager.h
//  Gemini
//
//  Created by James Norton on 3/31/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

@interface GemShaderManager : NSObject {
    GLuint program;
}

@property (nonatomic) GLuint program;

-(BOOL)loadShaders;
- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type source:(NSString *)shaderSource;
- (BOOL)linkProgram:(GLuint)prog;
- (BOOL)validateProgram:(GLuint)prog;


@end
