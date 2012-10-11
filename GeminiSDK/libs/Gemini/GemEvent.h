//
//  GeminiEvent.h
//  Gemini
//
//  Created by James Norton on 2/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GemObject.h"


@interface GemEvent : GemObject {
    GemObject *target;  // the object receiving the event
}

@property (nonatomic, retain) GemObject *target;

-(id)initWithLuaState:(lua_State *)luaState Target:(GemObject *)trgt;

@end