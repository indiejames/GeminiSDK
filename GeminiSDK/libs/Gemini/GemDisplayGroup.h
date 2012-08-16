//
//  GeminiDisplayGroup.h
//  Gemini
//
//  Created by James Norton on 3/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GemDisplayObject.h"

@interface GemDisplayGroup : GemDisplayObject {
    NSMutableArray *objects;
}

@property (readonly) NSArray *objects;
@property (readonly) unsigned int numChildren;

-(void)remove:(GemDisplayObject *) obj;
-(void)recomputeWidthHeight;
-(void)insert:(GemDisplayObject *) obj;
-(void)insert:(GemDisplayObject *)obj atIndex:(int)indx;

@end
