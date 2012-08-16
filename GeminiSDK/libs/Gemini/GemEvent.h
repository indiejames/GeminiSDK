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
    GemObject *source;  // the object generating/triggering the event
}

@property (nonatomic, retain) GemObject *source;

-(id)initWithLuaState:(lua_State *)luaState Source:(GemObject *)src;

@end