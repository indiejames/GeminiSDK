//
//  GemEventManager.m
//  GeminiSDK
//
//  Created by James Norton on 9/13/12.
//
//

#import "GemEventManager.h"
#import "GemGLKViewController.h"
#import "GemTouchEvent.h"

@interface GemEventManager () {
    NSMutableDictionary *listeners;
}

@end


@implementation GemEventManager

-(id) initWithLuaState:(lua_State *)luaState {
    self = [super initWithLuaState:luaState];
    
    if (self) {
        listeners = [[NSMutableDictionary alloc] initWithCapacity:1];
    }
    
    return self;
}

- (void)addEventListener:(GemObject *)listener forEvent:(NSString *)event {
    NSMutableArray *eventListeners = [listeners objectForKey:event];
    if (eventListeners == nil) {
        eventListeners = [[NSMutableArray alloc] initWithCapacity:1];
        [listeners setObject:eventListeners forKey:event];
    }
    
    [eventListeners addObject:listener];
    if([event isEqualToString:GEM_TOUCH_EVENT_NAME]){
        [eventListeners sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            int index1 = ((GemDisplayObject *)obj1).layer.index;
            int index2 = ((GemDisplayObject *)obj2).layer.index;
            
            if(index1 == index2){
                return NSOrderedSame;
            } else if (index1 < index2){
                return NSOrderedDescending;
            } else {
                return NSOrderedAscending;
            }
            
        }];
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
}
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    // test all current display objects to see if they were hit
    NSArray *eventListeners = [listeners objectForKey:@"touch"];
    if (listeners == nil) {
        return;
    }
    for (UITouch *touch in touches) {
        CGPoint location = [touch locationInView:self.parentGLKViewController.view];
        float contentScale = self.parentGLKViewController.view.contentScaleFactor;
        GemLog(@"touch at (x,y) = (%f,%f)", contentScale*location.x, contentScale*(self.parentGLKViewController.view.bounds.size.height - location.y));
        
        GemTouchEvent *tevent = [[GemTouchEvent alloc]initWithLuaState:L Target:nil];
        tevent.x = location.x;
        tevent.y = self.parentGLKViewController.view.bounds.size.height - location.y;
        tevent.name = GEM_TOUCH_EVENT_NAME;
        GLKVector2 point;
        point.x = tevent.x;
        point.y = tevent.y;
        
        GemLog(@"Testing %d objects for touch event", [eventListeners count]);
        
        for (GemDisplayObject *obj in eventListeners){
            if ([obj doesContainPoint:point]) {
                GemLog(@"Object contains point");
            }
            if ([obj doesContainPoint:point] && [obj handleEvent:tevent]) {
                break;
            }
        }
    }
}
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    
}

@end
