//
//  GemShape.h
//  GeminiSDK
//
//  Created by James Norton on 10/20/12.
//
//

#import "GemDisplayObject.h"

@interface GemShape : GemDisplayObject {
    GLfloat *verts;
    GLfloat *vertColor;
    GLushort *vertIndex;
    GLKVector2 *points;
    GLKVector4 fillColor;
    GLKVector4 *gradient;
    GLKVector4 strokeColor;
    //GemLine *border;
    GLfloat strokeWidth;
    GLuint numInnerlVerts;
    GLuint numBorderVerts;
}

@property (readonly) GLfloat *verts;
@property (readonly) GLfloat *vertColor;
@property (readonly) GLushort *vertIndex;
@property (nonatomic) GLKVector4 fillColor;
@property (nonatomic) GLKVector4 *gradient;
@property (nonatomic) GLKVector4 strokeColor;
@property (nonatomic) GLfloat strokeWidth;
@property (readonly) GLuint numTriangles;
@property (readonly) GLuint vertCount;
@property (readonly) GLuint vertIndexCount;

@end
