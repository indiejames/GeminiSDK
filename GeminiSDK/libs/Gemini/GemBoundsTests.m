//
//  GemBoundingPoly.m
//  GeminiSDK
//
//  Created by James Norton on 10/10/12.
//
//

#import "GemBoundsTests.h"

// use Barycentric coordinate method to test for intersection of point and triangle
BOOL testTriangleIntersection(GLKVector2 *triangle, GLKVector2 point){

    GLKVector2 A = triangle[0];
    GLKVector2 B = triangle[1];
    GLKVector2 C = triangle[2];
    
    // compute vectors
    GLKVector2 v0 = GLKVector2Subtract(C, A);
    GLKVector2 v1 = GLKVector2Subtract(B, A);
    GLKVector2 v2 = GLKVector2Subtract(point, A);
    
    // compute dot products
    GLfloat dot00 = GLKVector2DotProduct(v0, v0);
    GLfloat dot01 = GLKVector2DotProduct(v0, v1);
    GLfloat dot02 = GLKVector2DotProduct(v0, v2);
    GLfloat dot11 = GLKVector2DotProduct(v1, v1);
    GLfloat dot12 = GLKVector2DotProduct(v1, v2);
    
    // compute barycentric coordinates
    GLfloat invDenom = 1.0 / (dot00 * dot11 - dot01 * dot01);
    GLfloat u = (dot11 * dot02 - dot01 * dot12) * invDenom;
    GLfloat v = (dot00 * dot12 - dot01 * dot02) * invDenom;
    
    // check if the point is in the triangle
    return (u >= 0) &&(v >= 0) && (u * v < 1);
    
}