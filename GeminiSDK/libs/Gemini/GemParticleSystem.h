//
//  GemParticleSystem.h
//  TGem22
//
//  Created by James Norton on 12/5/12.
//
//

#import "GemDisplayObject.h"
#import "GemSpriteSheet.h"
#import "GeminiTypes.h"
#import "GemSpriteSheet.h"

#define GEM_PARTICLE_SYSTEM_LUA_KEY "GeminiLib.GEMINI_PARTICLE_SYSTEM_LUA_KEY"

typedef  enum GemEmitterType {
    GEM_EMITTER_RADIAL,
    GEM_EMITTER_GRAVITY
} GemEmitterType;

typedef struct {
    GLKVector2	position;
	GLKVector2	direction;
    GLKVector2	startPos;
	GLKVector4	color;
	GLKVector4	startColor;
    GLKVector4  finishColor;
    GLfloat		radialAcceleration;
    GLfloat		tangentialAcceleration;
	GLfloat		radius;
	GLfloat		rotation;
	GLfloat		degreesPerSecond;
	GLfloat		particleSize;
    GLfloat     startParticleSize;
    GLfloat     finishParticleSize;
	GLfloat		timeToLive;
    GLfloat     lifeSpan;
} GemParticle;


@interface GemParticleSystem : GemDisplayObject {
    GLuint numVerts;
    GLuint numIndices;
    unsigned int particleCount;
}

@property GLKTextureInfo *texture;
@property GLKVector2 sourcePositionVariance;
@property GLfloat particleLifeSpan;
@property GLfloat particleLifeSpanVariance;
@property GLfloat speed;
@property GLfloat speedVariance;
@property GLfloat angleVariance;
@property GLKVector2 gravity;
@property GLfloat radialAcceleration;
@property GLfloat radialAccelerationVariance;
@property GLfloat tangentialAcceleration;
@property GLfloat tangentialAccelerationVariance;
@property GLKVector4 startColor;
@property GLKVector4 startColorVariance;
@property GLKVector4 finishColor;
@property GLKVector4 finishColorVariance;
@property unsigned int maxParticles;
@property GLfloat startParticleSize;
@property GLfloat startParticleSizeVariance;
@property GLfloat finishParticleSize;
@property GLfloat finishParticleSizeVariance;
@property GLfloat duration;
@property GemEmitterType emmiterType;
@property GLfloat maxRadius;
@property GLfloat maxRadiusVariance;
@property GLfloat minRadius;
@property GLfloat rotatePerSecond;
@property GLfloat rotatePerSecondVariance;
@property GLfloat rotationStart;
@property GLfloat rotationStartVariance;
@property GLfloat rotationEnd;
@property GLfloat rotationEndVariance;
@property unsigned int particleCount;
@property BOOL on;
@property BOOL isPaused;
@property (readonly) GLuint numVerts;
@property (readonly) GLuint numIndices;
@property (readonly) GemSpriteSheet *spriteSheet;

-(id)initWithLuaState:(lua_State *)luaState File:(NSString *)filename SpriteSheet:(GemSpriteSheet *)spSheet;

-(void)start:(double)currentTime;
-(void)pause:(double)currentTime;
-(void)stop;

-(void)update:(double)deltaT;
-(GemTexturedVertex *)getVertsWithTransform:(GLKMatrix3)trans;

@end
