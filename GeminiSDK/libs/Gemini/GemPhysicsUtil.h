//
//  GemPhysicsUtil.h
//  GeminiSDK
//
//  Created by James Norton on 11/10/12.
//
//

#import "GemDisplayGroup.h"

// utiltiy method for rendering physics bodies
#ifdef __cplusplus
extern "C" {
#endif    
    GemDisplayGroup *getPhysicsShapes(void *obj, float scale);
#ifdef __cplusplus
}
#endif
