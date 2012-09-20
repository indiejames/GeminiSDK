//
//  GemSceneTransition.h
//  GeminiSDK
//
//  Created by James Norton on 8/17/12.
//
//

#import <Foundation/Foundation.h>
#import "GemScene.h"

@interface GemSceneTransition : NSObject {
    GemScene *sceneA;
    GemScene *sceneB;
    double elapsedTime;
    double duration;
    NSDictionary *params;
    GLuint vao;
    GLuint program;

}

@property (nonatomic, retain) GemScene *sceneA;
@property (nonatomic, retain) GemScene *sceneB;
@property (readonly) double elapsedTime;
@property (nonatomic) double duration;

-(id)initWithParams:(NSDictionary *)params;
-(BOOL)transit:(double)timeSinceLastRender;
- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type source:(NSString *)shaderSource;
- (BOOL)linkProgram:(GLuint)prog;

@end
