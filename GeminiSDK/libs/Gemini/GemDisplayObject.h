//
//  GeminiDisplayObject.h
//  Gemini
//
//  Created by James Norton on 3/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>
#import "GemObject.h"
#import "GemBoundsTests.h"
#import "GemMask.h"
#include "lua.h"
#include "lualib.h"
#include "lauxlib.h"

@class GemDisplayGroup;
@class GemLayer;

@interface GemDisplayObject : GemObject {
    GemDisplayGroup *parent;
    GemLayer *layer;
    GemMask *mask;
    GLfloat xReference;
    GLfloat yReference;
    GLfloat xOrigin;
    GLfloat yOrigin;
    GLfloat rotation;
    GLfloat width;
    GLfloat height;
    GLfloat xScale;
    GLfloat yScale;
    GLfloat alpha;
    GLKMatrix3 transform;
    GLKMatrix3 cumulativeTransform;
    BOOL needsTransformUpdate;
    BOOL needsUpdate;
    BOOL isVisible;
    void *physicsBody;
}

@property (nonatomic) GLfloat alpha;
@property (nonatomic) GLfloat height;
@property (nonatomic) GLfloat width;
@property (nonatomic) BOOL isHitTestMasked;
@property (nonatomic) BOOL isHitTestable;
@property (nonatomic) BOOL isVisible;
@property (nonatomic) GLfloat maskRotation;
@property (nonatomic) GLfloat maskScaleX;
@property (nonatomic) GLfloat maskScaleY;
@property (nonatomic) GLfloat maskX;
@property (nonatomic) GLfloat maskY;
@property (nonatomic, strong) GemDisplayGroup *parent;
@property (nonatomic, strong) GemLayer *layer;
@property (nonatomic, strong) GemMask *mask;
@property (nonatomic) GLfloat rotation;
@property (nonatomic) GLfloat x;
@property (nonatomic) GLfloat y;
@property (nonatomic) GLfloat xOrigin;
@property (nonatomic) GLfloat yOrigin;
@property (nonatomic) GLfloat xReference;
@property (nonatomic) GLfloat yReference;
@property (nonatomic) GLfloat xScale;
@property (nonatomic) GLfloat yScale;
@property (nonatomic) BOOL needsUpdate;
@property (nonatomic) BOOL needsTransformUpdate;
@property (nonatomic) void *physicsBody;
@property (nonatomic) GLKMatrix3 cumulativeTransform;

-(id) initWithLuaState:(lua_State *)luaState LuaKey:(const char *)luaKey;
-(GLKMatrix3) transform;
-(BOOL)doesContainPoint:(GLKVector2)point;
-(void)setIsActive:(bool)active;
-(bool)isActive;

@end
