//
//  GemRectangleBatch.h
//  Gemini
//
//  Created by James Norton on 6/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>
#include "GeminiTypes.h"

@interface GemRectangleBatch : NSObject {
    GemColoredVertex *vertexBuffer;
    unsigned int capacity;
    unsigned int bufferOffset;
}

@property (readonly) GemColoredVertex *vertexBuffer;

-(id)initWithCapacity:(unsigned int)capacity;
-(GemColoredVertex *)getPointerForInsertion;
-(unsigned int)count; // number of vertices currently stored

@end

