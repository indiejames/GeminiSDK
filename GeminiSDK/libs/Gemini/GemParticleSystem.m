//
//  GemParticleSystem.m
//  TGem22
//
//  Created by James Norton on 12/5/12.
//
//

#import "GemParticleSystem.h"
#import "GemSpriteSheet.h"
#import "GLUtils.h"
#import "XMLDictionary.h"
#include "GemMathUtils.h"

@interface GemParticleSystem () {
    GemParticle *particles;
    unsigned int particleIndex;
    GLfloat emissionRate;
    GLfloat emitCounter;
    double elapsedTime;
    double lastUpdateTime;
    GemTexturedVertex *verts;
    GLushort *indices;
    GemSpriteSheet *spriteSheet;
    GLKVector4 texCoord;
}

@end

@implementation GemParticleSystem

@synthesize spriteSheet;
@synthesize particleCount;
@synthesize numIndices;

-(id)initWithLuaState:(lua_State *)luaState File:(NSString *)filename SpriteSheet:(GemSpriteSheet *)spSheet{
    
    self = [super initWithLuaState:luaState LuaKey:GEM_PARTICLE_SYSTEM_LUA_KEY];
    
    if (self) {
        spriteSheet = spSheet;
        
        filename = [filename lastPathComponent];
        NSString *filePrefix = [filename stringByDeletingPathExtension];
        NSString *extension = [filename pathExtension];
        if ([extension isEqualToString:@""]) {
            extension = @"pex";
        }
        NSString *path = [[NSBundle mainBundle] pathForResource:filePrefix ofType:extension];
        NSDictionary *config = [NSDictionary dictionaryWithXMLFile:path];
        
        NSString *textureFileName = [config valueForKeyPath:@"texture._name"];
        texCoord = [spSheet texCoordsForFilename:textureFileName];
        
        GLfloat x = [[config valueForKeyPath:@"sourcePosition._x"] floatValue];
        GLfloat y = [[config valueForKeyPath:@"sourcePosition._y"] floatValue];
        self.x = x;
        self.y = y;
        
        GLfloat varX = [[config valueForKeyPath:@"sourcePositionVariance._x"] floatValue];
        GLfloat varY = [[config valueForKeyPath:@"sourcePositionVariance._y"] floatValue];
        
        self.sourcePositionVariance = GLKVector2Make(varX, varY);
        
        GLfloat speed = [[config valueForKeyPath:@"speed._value"] floatValue];
        self.speed = speed;
        
        self.speedVariance = [[config valueForKeyPath:@"speedVariance._value"] floatValue];
        
        self.particleLifeSpan = [[config valueForKeyPath:@"particleLifeSpan._value"] floatValue];
        self.particleLifeSpanVariance = [[config valueForKeyPath:@"particleLifespanVariance._value"] floatValue];
        self.particleLifeSpan = self.particleLifeSpan * 0.5;
        self.particleLifeSpanVariance = self.particleLifeSpanVariance * 0.5;
        self.rotation = [[config valueForKeyPath:@"angle._value"] floatValue];
        self.angleVariance = [[config valueForKeyPath:@"angleVariance._value"] floatValue];
        GLfloat gravX = 0;
        GLfloat gravY = 0;
        gravX = [[config valueForKeyPath:@"gravity._x"] floatValue];
        gravY = [[config valueForKeyPath:@"gravity_.y"] floatValue];
        self.gravity = GLKVector2Make(gravX, gravY);
        self.radialAcceleration = [[config valueForKeyPath:@"radialAcceleration._value"] floatValue];
        
        self.radialAccelerationVariance = [[config valueForKeyPath:@"radialAccelerationVariance._value"] floatValue];
        self.tangentialAcceleration = [[config valueForKeyPath:@"tangentialAcceleration._value"] floatValue];
        self.tangentialAccelerationVariance = [[config valueForKeyPath:@"tangentialAccelerationVariance._value"] floatValue];
        GLfloat red = [[config valueForKeyPath:@"startColor._red"] floatValue];
        GLfloat green = [[config valueForKeyPath:@"startColor._green"] floatValue];
        GLfloat blue = [[config valueForKeyPath:@"startColor._blue"] floatValue];
        GLfloat alph = [[config valueForKeyPath:@"startColor._alpha"] floatValue];
        self.startColor = GLKVector4Make(red, green, blue, alph);
        red = [[config valueForKeyPath:@"startColorVariance._red"] floatValue];
        green = [[config valueForKeyPath:@"startColorVariance._green"] floatValue];
        blue = [[config valueForKeyPath:@"startColorVariance._blue"] floatValue];
        alph = [[config valueForKeyPath:@"startColorVariance._alpha"] floatValue];
        self.startColorVariance = GLKVector4Make(red, green, blue, alph);
        red = [[config valueForKeyPath:@"finishColor._red"] floatValue];
        green = [[config valueForKeyPath:@"finishColor._green"] floatValue];
        blue = [[config valueForKeyPath:@"finishColor._blue"] floatValue];
        alph = [[config valueForKeyPath:@"finishColor._alpha"] floatValue];
        self.finishColor = GLKVector4Make(red, green, blue, alph);
        red = [[config valueForKeyPath:@"finishColorVariance._red"] floatValue];
        green = [[config valueForKeyPath:@"finishColorVariance._green"] floatValue];
        blue = [[config valueForKeyPath:@"finishColorVariance._blue"] floatValue];
        alph = [[config valueForKeyPath:@"finishColorVariance._alpha"] floatValue];
        self.finishColorVariance = GLKVector4Make(red, green, blue, alph);
        self.maxParticles = [[config valueForKeyPath:@"maxParticles._value"] intValue];
        self.startParticleSize = [[config valueForKeyPath:@"startParticleSize._value"] floatValue];
        self.startParticleSizeVariance = [[config valueForKeyPath:@"startParticleSizeVariance._value"] floatValue];
        self.finishParticleSize = [[config valueForKeyPath:@"finishParticleSize._value"] floatValue];
        self.finishParticleSizeVariance = [[config valueForKeyPath:@"finishParticleSizeVariance._value"] floatValue];
        self.duration = [[config valueForKeyPath:@"duration._value"] floatValue];
        unsigned int eType = [[config valueForKeyPath:@"emitterType._value"] intValue];
        if (eType == 0) {
            self.emmiterType = GEM_EMITTER_GRAVITY;
        } else {
            self.emmiterType = GEM_EMITTER_RADIAL;
        }
        self.maxRadius = [[config valueForKeyPath:@"maxRadius._value"] floatValue];
        self.maxRadiusVariance = [[config valueForKeyPath:@"maxRadiusVariance._value"] floatValue];
        self.minRadius = [[config valueForKeyPath:@"minRadius._value"] floatValue];
        self.rotatePerSecond = [[config valueForKeyPath:@"rotatePerSecond._value"] floatValue];
        self.rotatePerSecondVariance = [[config valueForKeyPath:@"rotatePerSecondVariance._value"] floatValue];
        self.rotationStart = [[config valueForKeyPath:@"rotationStart._value"] floatValue];
        self.rotationStartVariance = [[config valueForKeyPath:@"rotationStartVariance._value"] floatValue];
        self.rotationEnd = [[config valueForKeyPath:@"rotationEnd._value"] floatValue];
        self.rotationEndVariance = [[config valueForKeyPath:@"rotationEndVariance._value"] floatValue];
        
        particles = (GemParticle *)malloc(2 * self.maxParticles * sizeof(GemParticle));
        //indices = (GLushort *)malloc(self.maxParticles * 6 * sizeof(GLushort));
        verts = (GemTexturedVertex *)malloc(2 * self.maxParticles * 4 * sizeof(GemTexturedVertex));
        
        self.on = YES;
        elapsedTime = 0;
        particleCount = 0;
    }
    
    return self;
}

-(void)dealloc {
    free(particles);
    free(verts);
    //free(indices);
}


-(void)start:(double)currentTime {
    lastUpdateTime = currentTime;
    self.isPaused = NO;
    self.on = YES;
}

-(void)pause:(double)currentTime {
    [self update:currentTime];
    self.isPaused = YES;
}

-(void)stop {
    self.on = NO;
    elapsedTime = 0;
    emitCounter = 0;
}

-(BOOL)addParticle {
    // don't add any more particles if we are already at the max count
    if (particleCount < self.maxParticles) {
        
        GemParticle *particle = &particles[particleCount];
        [self initParticle:particle];
        
        particleCount++;
        
        return YES;
        
    }
    
    return NO;
}

-(void)initParticle:(GemParticle *)particle {
    // user a source position of (0,0) here since we will add the source position in using
    // the transform later
    particle->position.x = self.sourcePositionVariance.x * randNorm();
    particle->position.y = self.sourcePositionVariance.y * randNorm();
    particle->startPos.x = particle->position.x;
    particle->startPos.y = particle->position.y;
    
    
    GLfloat angle = (GLfloat)DEG_TO_RAD(self.rotation + self.angleVariance * randNorm());
    GLKVector2 vector = GLKVector2Make(cosf(angle), sinf(angle));
    
    //GemLog(@"direction = (%f, %f)", particle->direction.x, particle->direction.y);
    
    GLfloat vecSpeed = self.speed + self.speedVariance * randNorm();
    
    particle->direction = GLKVector2MultiplyScalar(vector, vecSpeed);
    
    particle->radius = self.maxRadius + self.maxRadiusVariance * randNorm();
    
    //particle->rotation = DEG_TO_RAD(self.rotation + self.angleVariance * randNorm());
    particle->rotation = self.rotation + self.angleVariance * randNorm();
    //particle->degreesPerSecond = DEG_TO_RAD(self.rotatePerSecond + self.rotatePerSecondVariance * randNorm());
    particle->degreesPerSecond = self.rotatePerSecond + self.rotatePerSecondVariance * randNorm();
    
    particle->radialAcceleration = self.radialAcceleration;
    particle->tangentialAcceleration = self.tangentialAcceleration;

    particle->timeToLive = MAX(0, self.particleLifeSpan + self.particleLifeSpanVariance * randNorm());
    // TEST
    //particle->timeToLive = self.particleLifeSpan;
    particle->lifeSpan = particle->timeToLive;
    
    GLfloat particleStartSize = self.startParticleSize + self.startParticleSizeVariance * randNorm();
    
    particle->particleSize = MAX(0, particleStartSize);
    particle->startParticleSize = particle->particleSize;
    
    GLfloat particleFinishSize = self.finishParticleSize + self.finishParticleSizeVariance * randNorm();
    particle->finishParticleSize = MAX(0, particleFinishSize);
    
    GLKVector4 startColor;
    startColor.r = self.startColor.r + self.startColorVariance.r * randNorm();
    startColor.g = self.startColor.g + self.startColorVariance.g * randNorm();
    startColor.b = self.startColor.b + self.startColorVariance.b * randNorm();
    startColor.a = self.startColor.a + self.startColorVariance.a * randNorm();
    particle->color = startColor;
    particle->startColor = startColor;
    
    GLKVector4 endColor;
    endColor.r = self.finishColor.r + self.finishColorVariance.r * randNorm();
    endColor.g = self.finishColor.g + self.finishColorVariance.g * randNorm();
    endColor.b = self.finishColor.b + self.finishColorVariance.b * randNorm();
    endColor.a = self.finishColor.a + self.finishColorVariance.a * randNorm();
    
    particle->finishColor = endColor;
}

-(void)update:(double)currentTime {
    if (self.on && !self.isPaused) {
        
        double deltaTime = currentTime - lastUpdateTime;
        
        lastUpdateTime = currentTime;
        
        while (deltaTime > 0) {
            double deltaT = 1.0 / 100.0;
            if (deltaT > deltaTime) {
                deltaT = deltaTime;
            }
        
            
            //GemLog(@"deltaT = %f", deltaT);
            //GemLog(@"deltaTime = %f", deltaTime);
            
            
            if (self.particleLifeSpan + self.particleLifeSpanVariance > 0) {
                emissionRate = self.maxParticles / (self.particleLifeSpan = self.particleLifeSpanVariance);
            } else {
                emissionRate = 0;
            }
            
            if (emissionRate) {
                float rate = 1.0 / emissionRate;
                emitCounter += deltaT;
                while (particleCount < self.maxParticles && emitCounter > rate) {
                    [self addParticle];
                    emitCounter -= rate;
                }
                
                elapsedTime += deltaT;
                
                if (self.duration != -1 && self.duration < elapsedTime) {
                    [self stop];
                }
                
            }
            
            particleIndex = 0;
            while (particleIndex < particleCount) {
                GemParticle *currentParticle = &particles[particleIndex];
                
                //GemLog(@"particle %d ttl = %f sec", particleIndex, currentParticle->timeToLive);
                
                currentParticle->timeToLive -= deltaT;
                
                //GemLog(@"particle %d ttl = %f sec", particleIndex, currentParticle->timeToLive);
                
                GLfloat fractionOfLifeSpan = (1.0 - currentParticle->timeToLive / currentParticle->lifeSpan);
                
                if (currentParticle->timeToLive > 0) {
                    if (self.emmiterType == GEM_EMITTER_RADIAL) {
                        currentParticle->rotation += currentParticle->degreesPerSecond * deltaT;
                        currentParticle->radius -= (self.maxRadius / currentParticle->lifeSpan) * deltaT;
                        
                        if (currentParticle->radius < self.minRadius) {
                            currentParticle->timeToLive = 0;
                        } else {
                            GLKVector2 tmp;
                            tmp.x = -cosf(GLKMathDegreesToRadians(currentParticle->rotation)) * currentParticle->radius;
                            tmp.y = -sinf(GLKMathDegreesToRadians(currentParticle->rotation)) * currentParticle->radius;
                            currentParticle->position = tmp;
                        }
                        
                    } else {
                        GLKVector2 tmp, radial, tangential;
                        radial = GLKVector2Make(0, 0);
                        GLKVector2 diff = GLKVector2Subtract(currentParticle->startPos, radial);
                        currentParticle->position = GLKVector2Subtract(currentParticle->position, diff);
                        
                        if (currentParticle->position.x || currentParticle->position.y) {
                            radial = GLKVector2Normalize(currentParticle->position);
                            
                        } 
                        
                        tangential.x = radial.x;
                        tangential.y = radial.y;
                        
                        radial = GLKVector2MultiplyScalar(radial, currentParticle->radialAcceleration);
                        
                        GLfloat newy = tangential.x;
                        tangential.x = tangential.y;
                        tangential.y = newy;
                        tangential = GLKVector2MultiplyScalar(tangential, currentParticle->tangentialAcceleration);
                        
                        //tmp = GLKVector2Add(GLKVector2Add(radial, tangential), self.gravity);
                        //tmp = GLKVector2MultiplyScalar(tmp, deltaT);
                        //currentParticle->position = GLKVector2Add(currentParticle->position, tmp);
                        tmp = GLKVector2MultiplyScalar(currentParticle->direction, deltaT);
                        currentParticle->position = GLKVector2Add(currentParticle->position, tmp);
                        currentParticle->position = GLKVector2Add(currentParticle->position, diff);
                        
                        //GemLog(@"Particle.position = (%f, %f)", currentParticle->position.x, currentParticle->position.y);
                        
                    }
                    
                    currentParticle->color.r = currentParticle->startColor.r + (currentParticle->finishColor.r - currentParticle->startColor.r) * fractionOfLifeSpan;
                    currentParticle->color.g = currentParticle->startColor.g + (currentParticle->finishColor.g - currentParticle->startColor.g) * fractionOfLifeSpan;
                    currentParticle->color.b = currentParticle->startColor.b + (currentParticle->finishColor.b - currentParticle->startColor.b) * fractionOfLifeSpan;
                    currentParticle->color.a = currentParticle->startColor.a + (currentParticle->finishColor.a - currentParticle->startColor.a) * fractionOfLifeSpan;
                    
                    currentParticle->particleSize = currentParticle->startParticleSize - (currentParticle->startParticleSize - currentParticle->finishParticleSize) * fractionOfLifeSpan;
                    
                    
                    particleIndex++;
                    
                } else {
                    if (particleIndex != particleCount - 1) {
                        particles[particleIndex] = particles[particleCount - 1];
                    }
                    
                    particleCount--;
                }
                
                
                
            }
            
            deltaTime -= deltaT;
        }
    
    }
    
    //GemLog(@"GemParticleSystem: particleCount = %d", particleCount);
}

-(GLuint)numVerts {
    return self.particleCount * 4;
}

-(GLuint)numIndices {
    return self.particleCount * 6;
}

-(GLushort *)indices {
    return indices;
}

-(GemTexturedVertex *)getVertsWithTransform:(GLKMatrix3)trans {
    
    GLuint vertIndex = 0;
    for (int i=0; i<self.particleCount; i++) {
        GemParticle *particle = &particles[i];
        
        GLfloat particleVerts[] = {
            -0.5, -0.5, 1.0,
            -0.5, 0.5, 1.0,
            0.5, -0.5, 1.0,
            0.5, 0.5, 1.0
        };
        
        /*GLfloat particleVerts[] = {
            -0.75, -0.75, 1.0,
            -0.75, 0.75, 1.0,
            0.75, -0.75, 1.0,
            0.75, 0.75, 1.0
        };*/
        
        
        GLKMatrix3 particleTransform  = GLKMatrix3Make(1.0, 0, 0, 0, 1, 0, particle->position.x, particle->position.y, 1.0);
        
        particleTransform = GLKMatrix3Scale(particleTransform, particle->particleSize, particle->particleSize, 1);
        
        
        if (particle->rotation != 0) {
            particleTransform = GLKMatrix3RotateZ(particleTransform, GLKMathDegreesToRadians(particle->rotation));
        }
        
        GLKMatrix3 tmpTransform = GLKMatrix3Multiply(self.transform, particleTransform);
        GLKMatrix3 finalTransform = GLKMatrix3Multiply(trans, tmpTransform);
        
        transformVertices(particleVerts, particleVerts, 4, finalTransform);
        //GemLog(@"Start verts for particle %d", i);
        
        for (int j=0; j<4; j++) {
            
            GemTexturedVertex *vert = &verts[vertIndex++];
            
            // vertex color
            vert->color[0] = particle->color.r;
            vert->color[1] = particle->color.g;
            vert->color[2] = particle->color.b;
            vert->color[3] = particle->color.a;
            
            // vertex position
            vert->position[0] = particleVerts[j*3];
            vert->position[1] = particleVerts[j*3+1];
            vert->position[2] = particleVerts[j*3+2];
            
            //GemLog(@"Vertex %d is at (%f, %f)", j, vert->position[0], vert->position[1]);
            
            // vertex texture coordinates
            vert->texCoord[0] = (j == 0 || j == 1) ? texCoord.x : texCoord.z;
            vert->texCoord[1] = (j == 0 || j == 2) ? texCoord.y : texCoord.w;
            
        }
        
        
        
    }
    
    return verts;
}

// we don't use the roation of the emitter since that is already being done in the particle update
-(GLKMatrix3) transform {
    if (needsTransformUpdate) {
        // NOTE - The order of operations may seem reversed, but this is correct for the way the
        // transform matrix is used
        
        // translate to (xOrigin,yOrigin)
        if (xReference != 0 || yReference != 0) {
            // combine two translations into one
            transform = GLKMatrix3Make(1.0, 0.0, 0, 0, 1, 0, xOrigin + xReference, yOrigin + yReference, 1.0);
            
        } else {
            
            transform = GLKMatrix3Make(1.0, 0, 0, 0, 1, 0, xOrigin, yOrigin, 1.0);
        }
        
        if (xScale != 1.0 || yScale != 1.0) {
            transform = GLKMatrix3Scale(transform, xScale, yScale, 1);
        }
        
        
        // need to translate reference point to origin for proper rotation scaling about it
        if (xReference != 0 || yReference != 0) {
            transform = GLKMatrix3Multiply(transform, GLKMatrix3Make(1.0, 0, 0, 0, 1, 0, -xReference, -yReference, 1));
            
        }
        
        needsTransformUpdate = NO;
        
    }
    
    
    return transform;
}


@end
