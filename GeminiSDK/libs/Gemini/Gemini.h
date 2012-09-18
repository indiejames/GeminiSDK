//
//  Gemini.h
//  Gemini
//
//  Created by James Norton on 2/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>
#include "lua.h"
#include "lualib.h"
#include "lauxlib.h"
#import "GemPhysics.h"
#import "GemFileNameResolver.h"


@interface Gemini : NSObject

//@property (readonly) lua_State *L;
@property (readonly) NSMutableArray *geminiObjects;
@property (readonly) GLKViewController *viewController;
@property (readonly) double initTime;
@property (readonly) GemPhysics *physics;
@property (readonly) NSString *deviceString;
@property (readonly) GemFileNameResolver *fileNameResolver;
@property (readonly) NSDictionary *settings;

-(void)execute:(NSString *)filename;
-(BOOL)handleEvent:(NSString *)event;
-(void)update:(double)deltaT;
+(Gemini *)shared;


@end

// global error function for Lua scripts
int traceback (lua_State *L);
