//
//  GemTextureBasedSceneTransition.h
//  GeminiSDK
//
//  Created by James Norton on 9/26/12.
//
//

#import "GemSceneTransition.h"

@interface GemTextureBasedSceneTransition : GemSceneTransition {
    GLuint vao;
    GLuint program;
    GLuint textureA;
    GLuint textureB;
    GLuint fboA;
    GLuint fboB;
    GLuint depthRBA;
    GLuint depthRBB;
    GLuint textWidth;
    GLuint textHeight;
    GLuint vBuffer;
    GLuint iBuffer;
    BOOL texturedAreRendered;
}

@end
