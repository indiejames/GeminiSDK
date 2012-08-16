//
//  GeminiSpriteBatch.h
//  Gemini
//
//  Created by James Norton on 5/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>
#include "GeminiTypes.h"

@interface GemSpriteBatch : NSObject {
    GemTexturedVertex *vertexBuffer;
    unsigned int capacity;
    unsigned int bufferOffset;
}

@property (readonly) GemTexturedVertex *vertexBuffer;

-(id)initWithCapacity:(unsigned int)capacity;
-(GemTexturedVertex *)getPointerForInsertion;
-(unsigned int)count; // number of sprites currently stored

@end
