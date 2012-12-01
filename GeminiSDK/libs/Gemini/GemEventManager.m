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
#import "Gemini.h"

@interface GemEventManager () {
    NSMutableDictionary *listeners;
    NSMutableDictionary *touchFocus;
}

@end


@implementation GemEventManager

-(id) initWithLuaState:(lua_State *)luaState {
    self = [super initWithLuaState:luaState];
    
    if (self) {
        listeners = [[NSMutableDictionary alloc] initWithCapacity:1];
        touchFocus = [[NSMutableDictionary alloc] initWithCapacity:1];
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
    // test all current display objects to see if they were hit
    NSArray *eventListeners = [listeners objectForKey:@"touch"];
    if (listeners == nil) {
        return;
    }
    for (UITouch *touch in touches) {
        CGPoint location = [touch locationInView:self.parentGLKViewController.view];
        float contentScale = self.parentGLKViewController.view.contentScaleFactor;
        contentScale = 1.0;
        //GemLog(@"touch at (x,y) = (%f,%f)", contentScale*location.x, contentScale*(self.parentGLKViewController.view.bounds.size.height - location.y));
        
        GemTouchEvent *tevent = [[GemTouchEvent alloc]initWithLuaState:L Target:nil Event:event];
        tevent.phase = GEM_TOUCH_BEGAN;
        tevent.x = location.x;
        tevent.y = self.parentGLKViewController.view.bounds.size.height - location.y;
        tevent.name = GEM_TOUCH_EVENT_NAME;
        GLKVector2 point;
        point.x = tevent.x;
        point.y = tevent.y;
        
        for (GemDisplayObject *obj in eventListeners){
            
            if ([obj doesContainPoint:point] && [obj handleEvent:tevent]) {
                break;
            }
        }
        
        //[[Gemini shared] handleEvent:tevent];
    }
    
}
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    NSArray *eventListeners = [listeners objectForKey:@"touch"];
    if (listeners == nil) {
        return;
    }
    for (UITouch *touch in touches) {
        CGPoint location = [touch locationInView:self.parentGLKViewController.view];
        float contentScale = self.parentGLKViewController.view.contentScaleFactor;
        contentScale = 1.0;
        //GemLog(@"touch at (x,y) = (%f,%f)", contentScale*location.x, contentScale*(self.parentGLKViewController.view.bounds.size.height - location.y));
        
        GemTouchEvent *tevent = [[GemTouchEvent alloc]initWithLuaState:L Target:nil Event:event];
        tevent.phase = GEM_TOUCH_MOVED;
        tevent.x = location.x;
        tevent.y = self.parentGLKViewController.view.bounds.size.height - location.y;
        tevent.name = GEM_TOUCH_EVENT_NAME;
        GLKVector2 point;
        point.x = tevent.x;
        point.y = tevent.y;
        
        //check to see if an object has already become the focus for this event
        NSNumber *timestamp = tevent.timestamp;
        
        if ([touchFocus objectForKey:timestamp]) {
            GemDisplayObject *obj = [touchFocus objectForKey:timestamp];
            [obj handleEvent:tevent];
            continue;
        }

        
        for (GemDisplayObject *obj in eventListeners){
            
            if ([obj doesContainPoint:point] && [obj handleEvent:tevent]) {
                break;
            }
        }
        
       // [[Gemini shared] handleEvent:tevent];
    }

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
        contentScale = 1.0;
       // GemLog(@"touch at (x,y) = (%f,%f)", contentScale*location.x, contentScale*(self.parentGLKViewController.view.bounds.size.height - location.y));
        
        GemTouchEvent *tevent = [[GemTouchEvent alloc]initWithLuaState:L Target:nil Event:event];
        tevent.phase = GEM_TOUCH_ENDED;
        tevent.x = location.x;
        tevent.y = self.parentGLKViewController.view.bounds.size.height - location.y;
        tevent.name = GEM_TOUCH_EVENT_NAME;
        GLKVector2 point;
        point.x = tevent.x;
        point.y = tevent.y;

        //check to see if an object has already become the focus for this event
        NSNumber *timestamp = tevent.timestamp;
        if ([touchFocus objectForKey:timestamp]) {
            GemDisplayObject *obj = [touchFocus objectForKey:timestamp];
            [obj handleEvent:tevent];
            continue;
        }

        
        //GemLog(@"Testing %d objects for touch event", [eventListeners count]);
        
        for (GemDisplayObject *obj in eventListeners){
           
            if ([obj doesContainPoint:point] && [obj handleEvent:tevent]) {
                break;
            }
        }
        
        //[[Gemini shared] handleEvent:tevent];
        
    }
}
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    
}

-(void)setTouchFocus:(GemObject *)focus forEvent:(GemEvent *)event {
    [touchFocus setObject:focus forKey:event.timestamp];
}

-(void)removeTouchFocus:(GemEvent *)event {
    [touchFocus removeObjectForKey:event.timestamp];
}

@end
