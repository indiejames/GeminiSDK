//
//  GemTouchEvent.h
//  GeminiSDK
//
//  Created by James Norton on 10/9/12.
//
//

#import "GemEvent.h"

typedef enum GemTouchPhase {
    GEM_TOUCH_BEGAN,
    GEM_TOUCH_MOVED,
    GEM_TOUCH_ENDED,
    GEM_TOUCH_CANCELLED
} GemTouchPhase;

@interface GemTouchEvent : GemEvent

@property (nonatomic) GemTouchPhase phase;
@property (nonatomic) float x;
@property (nonatomic) float y;
@property (nonatomic) float startX;
@property (nonatomic) float startY;

@end


