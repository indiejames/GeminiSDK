//
//  GemBezier.m
//  TGem22
//
//  Created by James Norton on 12/19/12.
//
//

#import "GemBezier.h"
#import "GeminiTypes.h"

void getFirstControlPoints(double *rhs, double *x, int count) {
    double *tmp = (double *)malloc(count*sizeof(double));
    
    double b = 2.0;
    x[0] = rhs[0] / b;
    
    for (int i=1; i<count; i++) {
        tmp[i] = 1.0 / b;
        b = (i < count - 1 ? 4.0 : 3.5) - tmp[i];
        x[i] = (rhs[i] - x[i - 1]) / b;
    }
    
    for (int i=1; i<count; i++) {
        x[count - i - 1] -= tmp[count - i] * x[count - i];
    }
    
    free(tmp);
}

BOOL getCurveControlPoints(GLKVector2 *knots, GLKVector2 *firstControlPoints, GLKVector2 *secondControlPoints, int count) {
    int n = count - 1;
    if (n < 1) {
        return NO;
    }
    
    if (n == 1) {
        firstControlPoints[0].x = (2.0 * knots[0].x + knots[1].x) / 3.0;
        firstControlPoints[0].y = (2.0 * knots[0].y + knots[1].y) / 3.0;
        
        secondControlPoints[0].x = 2.0 * firstControlPoints[0].x - knots[0].x;
        secondControlPoints[0].y = 2.0 * firstControlPoints[0].y - knots[0].y;
        
        return YES;
    }
    
    double *rhs = (double *)malloc(n*sizeof(double));
    
    for (int i=1; i<n-1; i++) {
        rhs[i] = 4.0 * knots[i].x + 2.0 * knots[i+1].x;
    }
    
    rhs[0] = knots[0].x + 2.0*knots[1].x;
    rhs[n-1] = (8.0*knots[n-1].x + knots[n].x) / 2.0;
    
    double *x = (double *)malloc(n*sizeof(double));
    getFirstControlPoints(rhs, x, n);
    
    for (int i=1; i<n-1; i++) {
        rhs[i] = 4.0 * knots[i].y + 2.0 * knots[i+1].y;
    }
    
    rhs[0] = knots[0].y + 2.0*knots[1].y;
    rhs[n-1] = (8.0*knots[n-1].y + knots[n].y) / 2.0;
    
    double *y = (double *)malloc(n*sizeof(double));
    getFirstControlPoints(rhs, y, n);
    
    for (int i=0; i<n; i++) {
        firstControlPoints[i].x = x[i];
        firstControlPoints[i].y= y[i];
        
        if (i < n - 1) {
            secondControlPoints[i].x = 2.0*knots[i+1].x - x[i+1];
            secondControlPoints[i].y = 2.0*knots[i+1].y - y[i+1];
        } else {
            secondControlPoints[i].x = (knots[n].x + x[n-1]) / 2.0;
            secondControlPoints[i].y = (knots[n].y + y[n-1]) / 2.0;
        }
    }
    
    free(x);
    free(y);
    free(rhs);
    
    return YES;
}

// find a point along a bezier curve
GLKVector2 computeVertex(GLKVector2 *controlPoints, double t) {
    double tt = 1-t;
    GLKVector4 tVec = GLKVector4Make(tt*tt*tt, 3.0*tt*tt*tt, 3.0*tt*t*t, t*t*t);
    GLKVector4 pX = GLKVector4Make(controlPoints[0].x, controlPoints[1].x, controlPoints[2].x, controlPoints[3].x);
    GLKVector4 pY = GLKVector4Make(controlPoints[0].y, controlPoints[1].y, controlPoints[2].y, controlPoints[3].y);
    GLfloat x = GLKVector4DotProduct(tVec, pX);
    GLfloat y = GLKVector4DotProduct(tVec, pY);
    
    return GLKVector2Make(x, y);
}



@implementation GemBezier

-(id) initWithLuaState:(lua_State *)luaState {
    self = [super initWithLuaState:luaState LuaKey:GEMINI_BEZIER_LUA_KEY];
}

@end
