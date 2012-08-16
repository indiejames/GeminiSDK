//
//  GeminiDisplayObject.m
//  Gemini
//
//  Created by James Norton on 3/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GemDisplayObject.h"


@implementation GemDisplayObject


@synthesize parent;
@synthesize layer;
@synthesize alpha;
@synthesize needsUpdate;
@synthesize needsTransformUpdate;
@synthesize isVisible;
@synthesize physicsBody;

-(id)initWithLuaState:(lua_State *)luaState {
    self = [super initWithLuaState:luaState];
    
    if (self) {
        xScale = 1.0;
        yScale = 1.0;
        alpha = 1.0;
        xReference = 0;
        yReference = 0;
        needsUpdate = YES;
        needsTransformUpdate = YES;
        isVisible = YES;
    }
    
    return self;
}

-(GLfloat)height {
    return height;
}

-(void)setHeight:(GLfloat)ht {
    //[super setDouble:ht forKey:"height"];
    height = ht;
}

-(GLfloat) width {
    //return [super getDoubleForKey:"width" withDefault:1.0];
    return width;
}

-(void)setWidth:(GLfloat)w {
    needsUpdate = YES;
    needsTransformUpdate = YES;
    width = w;
}

-(BOOL) isHitTestMasked {
    return [super getDoubleForKey:"isHitTestMasked" withDefault:YES];
}

-(void) setIsHitTestMasked:(BOOL)isHitTestMasked {
    [super setBOOL:isHitTestMasked forKey:"isHitTestMasked"];
}

-(BOOL) isHitTestable {
    return [super getBooleanForKey:"isHitTestable" withDefault:YES];
}

-(void) setIsHitTestable:(BOOL)isHitTestable {
    [super setBOOL:isHitTestable forKey:"isHitTestable"];
}


-(GLfloat)xScale {
    return xScale;
}

-(void)setXScale:(GLfloat)xs {
    xScale = xs;
    needsTransformUpdate = YES;
}

-(GLfloat)yScale {
    return yScale;
}

-(void)setYScale:(GLfloat)ys {
    yScale = ys;
    needsTransformUpdate = YES;
}

-(GLfloat)maskRotation {
    return [super getDoubleForKey:"maskRotation" withDefault:0];
}

-(void)setMaskRotation:(GLfloat)maskRotation {
    [super setDouble:maskRotation forKey:"maskRotation"];
}

-(GLfloat)maskScaleX {
    return [super getDoubleForKey:"maskScaleX" withDefault:1.0];
}

-(void)setMaskScaleX:(GLfloat)maskScaleX {
    [super setDouble:maskScaleX forKey:"maskScaleX"];
}

-(GLfloat)maskScaleY {
    return [super getDoubleForKey:"maskScaleY" withDefault:1.0];
}

-(void)setMaskScaleY:(GLfloat)maskScaleY {
    [super setDouble:maskScaleY forKey:"maskScaleY"];
}

-(GLfloat)maskX {
    return [super getDoubleForKey:"maskX" withDefault:0];
}

-(void)setMaskX:(GLfloat)maskX {
    [super setDouble:maskX forKey:"maskX"];
}

-(GLfloat)maskY {
    return [super getDoubleForKey:"maskY" withDefault:0];
}

-(void)setMaskY:(GLfloat)maskY {
    [super setDouble:maskY forKey:"maskY"];
}

-(GLfloat)rotation {
    //return [super getDoubleForKey:"rotation" withDefault:0];
    return rotation;
}

-(void)setRotation:(GLfloat)rot {
    //[super setDouble:rotation forKey:"rotation"];
    rotation = rot;
    needsTransformUpdate = YES;
}

-(GLfloat)x {
    //return [super getDoubleForKey:"x" withDefault:0];
    return xOrigin + xReference;
}

-(void)setX:(GLfloat)x {
    //[super setDouble:x forKey:"x"];
    
    // must bypass property setter to avoid infinite recursion
    xOrigin = x - self.xReference;
    needsTransformUpdate = YES;
}

-(GLfloat)y {
    //return [super getDoubleForKey:"y" withDefault:0];
    return yOrigin + yReference;
}

-(void)setY:(GLfloat)y {
    //[super setDouble:y forKey:"y"];
    //GLfloat yRef = self.yReference;
    
    // must bypass property setter to avoid infinite recursion
    yOrigin = y - self.yReference;
    needsTransformUpdate = YES;
}

-(GLfloat)xOrigin {
    return xOrigin;
}

-(void)setXOrigin:(GLfloat)xOrig {
    xOrigin = xOrig;
    needsTransformUpdate = YES;
}

-(GLfloat)yOrigin {
    return yOrigin;
}

-(void)setYOrigin:(GLfloat)yOrig {
    yOrigin = yOrig;
    needsTransformUpdate = YES;
}

-(GLfloat)xReference {
    //return [super getDoubleForKey:"xReference" withDefault:0];
    return xReference;
}

-(void)setXReference:(GLfloat)xRef{
    xReference = xRef;
    needsTransformUpdate = YES;
}

-(GLfloat)yReference {
    return yReference;
}

-(void)setYReference:(GLfloat)yRef {
    yReference = yRef;
    needsTransformUpdate = YES;
}


-(GLKMatrix3) transform {
    if (needsTransformUpdate) {
        // NOTE - The order of operations may seem reversed, but this is correct for the way the
        // transform matrix is used
        
        // translate to (xOrigin,yOrigin)
        if (xReference != 0 || yReference != 0) {
            // combine two translations into one
            transform = GLKMatrix3Make(1.0, 0.0, 0, 0, 1, 0, xOrigin + xReference, yOrigin+yReference, 1.0);
            
        } else {
            
            transform = GLKMatrix3Make(1.0, 0, 0, 0, 1, 0, xOrigin, yOrigin, 1.0);
        }
        
        if (xScale != 1.0 || yScale != 1.0) {
            transform = GLKMatrix3Scale(transform, xScale, yScale, 1);
        }
        
        if (rotation != 0) {
            transform = GLKMatrix3RotateZ(transform, GLKMathDegreesToRadians(rotation));
        }
        
        // need to translate reference point to origin for proper rotation scaling about it
        if (xReference != 0 || yReference != 0) {
            transform = GLKMatrix3Multiply(transform, GLKMatrix3Make(1.0, 0, 0, 0, 1, 0, -xReference, -yReference, 1));
            
        }
        
        needsTransformUpdate = NO;

    }
    
    
    return transform;
}


@end
