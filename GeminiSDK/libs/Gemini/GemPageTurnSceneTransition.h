//
//  GemPageTurnSceneTransition.h
//  GeminiSDK
//
//  Created by James Norton on 9/27/12.
//
//

#import "GemTextureBasedSceneTransition.h"
#import <GLKit/GLKit.h>

@interface GemPageTurnSceneTransition : GemTextureBasedSceneTransition {
    GLfloat A;
    GLfloat theta;
    GLfloat gamma;
    GLuint gridX;
    GLuint gridY;
    GLfloat t;
    GLKTextureInfo *paperTexture;
    GLuint backPageIBuffer;
    GLuint backPageVao;
}

@end
