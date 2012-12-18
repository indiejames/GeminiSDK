//
//  GLUtils.h
//  GeminiSDK
//
//  Created by James Norton on 9/20/12.
//
//

#import <GLKit/GLKit.h>

void transformVertices(GLfloat *outVerts, GLfloat *inVerts, GLuint vertCount, GLKMatrix3 transform);
GLKMatrix4 computeModelViewProjectionMatrix(BOOL adjustForLayout);
GLKTextureInfo *createTexture(NSString * imgFileName);
void GemCheckGLError(void);
GLKVector2 getDimensionsFromSettings(BOOL adjustForLayout);
float randNorm(void);
