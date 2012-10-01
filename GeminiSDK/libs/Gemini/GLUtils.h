//
//  GLUtils.h
//  GeminiSDK
//
//  Created by James Norton on 9/20/12.
//
//

#import <GLKit/GLKit.h>

GLKMatrix4 computeModelViewProjectionMatrix(BOOL adjustForLayout);
GLKTextureInfo *createTexture(NSString * imgFileName);
