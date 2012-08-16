//
//  GeminiTransistion.h
//  Gemini
//
//  Created by James Norton on 5/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GemDisplayObject.h"
#import "LGeminiLuaSupport.h"

@interface GemTransistion : NSObject {
    double elapsedTime;
    double duration;
    double delay;
    int onStart; // ref to lua method
    int onComplete; // ref to lua method
    lua_State *L;
    
    NSMutableDictionary *finalParamValues;
    NSMutableDictionary *initialParamValues;

    GemDisplayObject *obj;
}

-(id)initWithLuaState:(lua_State *)lua_state Object:(GemDisplayObject *)object Data:(NSDictionary *)data To:(BOOL)to;
-(void)update:(double)secondsSinceLastUpdate;
-(BOOL)isActive;

@end
