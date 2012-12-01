//
//  GeminiRenderer.m
//  Gemini
//
//  Created by James Norton on 3/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GemRenderer.h"
#import "Gemini.h"
#import "GemLine.h"
#import "GemRectangle.h"
#import "GemCircle.h"
#import "GemConvexShape.h"
#import "GemSprite.h"
#import "GemLayer.h"
#import "LGeminiDisplay.h"
#import "GemSpriteBatch.h"
#import "GemGLKViewController.h"
#import "GemDirector.h"
#import "GemScene.h"
#import "GemPhysicsUtil.h"
#include "GLUtils.h"

#define LINE_BUFFER_CHUNK_SIZE (512)

#define SPRITE_BATCH_CHUNK_SIZE (64)


BOOL bufferCreated = NO;
GLfloat lineWidth[512];
GLuint lineCount = 0;

GLfloat posVerts[12];
GLfloat newPosVerts[12];


GLuint rectangleVBO[4];
GLuint lineVBO[4];
GLuint spriteVBO[4];

GemColoredVertex *blendedRectangles;
GemColoredVertex *unblendedRectangles;

GLuint ringBufferOffset = 0;
GLuint lineRingBufferOffset = 0;
GLuint spriteRingBufferOffset = 0;

BOOL firstPass = YES;

@interface DisplayGroupTransform : NSObject {
    GLKMatrix3 transform;
    GemDisplayGroup *group;
}

@property (nonatomic) GLKMatrix3 transform;
@property (nonatomic, strong) GemDisplayGroup *group;

@end

@implementation DisplayGroupTransform
@synthesize transform, group;

@end


@implementation GemRenderer

@synthesize spriteShaderManager;



-(void)renderScene:(GemScene *)scene {
    firstPass = YES;
    NSArray *blendedLayers = [self renderUnblendedLayersForScene:(GemScene *)scene];
    [self renderBlendedLayers:blendedLayers];
    glBindVertexArrayOES(0);
}

// render layers from front to back to minimize overdraw
-(NSArray *)renderUnblendedLayersForScene:(GemScene *)scene {
    GemOpenGLState *glState = [GemOpenGLState shared];
    
    if (glState.glBlend == GL_TRUE) {
        glDisable(GL_BLEND);
        glState.glBlend = GL_FALSE;
    }
    
    if (glState.depthMask == GL_FALSE) {
        glDepthMask(GL_TRUE);
        glState.depthMask = GL_TRUE;
    }
    
    NSMutableArray *blendedLayers = [[NSMutableArray alloc] initWithCapacity:1];
    
    NSMutableDictionary *stage = [scene layers];
    NSMutableArray *layers = [NSMutableArray arrayWithArray:[stage allKeys]];
    // sort layers from front (highest number) to back (lowest number)
    [layers sortUsingComparator:(NSComparator)^(NSNumber *layer1, NSNumber *layer2) {
        return [layer2 compare:layer1];
    }];
    lineCount = 0;
    
    for (int i=0; i<[layers count]; i++) {
        NSNumber *layerIndex = (NSNumber *)[layers objectAtIndex:i];
        
        NSObject *obj = [stage objectForKey:layerIndex];
        if (obj.class == NSValue.class) {
            // this is a callback layer
            void(*callback)(void) = (void (*)(void))[(NSValue *)obj pointerValue];
            callback();
        } else {
            // a display group layer 
            GemLayer *layer = (GemLayer *)obj;
            if (layer.isBLendingLayer) {
               
                [blendedLayers insertObject:layer atIndex:0];
            } else {
                
                GLKMatrix3 transform = GLKMatrix3Identity;
                
                [self renderDisplayGroup:layer forLayer:[layerIndex intValue] withAlpha:1.0 transform:transform];
            }
            
        }
        
        if ([spriteBatches count] > 0) {
            [self renderSpriteBatches];
        }
        
    }
    
    return blendedLayers;
    
}

// render layers from back to front to support blending
-(void)renderBlendedLayers:(NSArray *)layers {
    
    GemOpenGLState *glState = [GemOpenGLState shared];
    
    if (glState.glBlend == GL_FALSE) {
        glEnable(GL_BLEND);
        glState.glBlend = GL_TRUE;
    }
    if (glState.glDepthMask == GL_TRUE) {
        glDepthMask(GL_FALSE);
        glState.glDepthMask = GL_FALSE;
    }
    
    
    for (int i=0; i<[layers count]; i++) {
        
        [physicsShapes removeAllObjects];
        
        NSObject *obj = [layers objectAtIndex:i];
        if (obj.class == NSValue.class) {
            // this is a callback layer
            void(*callback)(void) = (void (*)(void))[(NSValue *)obj pointerValue];
            callback();
        } else {
            // a display group layer
            GemLayer *layer = (GemLayer *)obj;
            
            GLKMatrix3 transform = GLKMatrix3Identity;
            
            GLKVector2 blendFunc = glState.glBlendFunc;
            if (blendFunc.x != layer.sourceBlend || blendFunc.y != layer.destBlend) {
                glBlendFunc(layer.sourceBlend, layer.destBlend);
                
                glState.glBlendFunc = GLKVector2Make(layer.sourceBlend, layer.destBlend);
            }
            
            [self renderDisplayGroup:layer forLayer:layer.index withAlpha:1.0 transform:transform];
            
        }
        
        GemPhysicsDrawMode drawMode = [Gemini shared].physics.drawMode;
        
        if ([spriteBatches count] > 0 && (drawMode == GEM_PHYSICS_NORMAL || drawMode == GEM_PHYSICS_HYBRID)) {
            [self renderSpriteBatches];
        }
        
        if ([physicsShapes count] > 0 && (drawMode == GEM_PHYSICS_DEBUG || drawMode == GEM_PHYSICS_HYBRID)) {
            for (int i=0; i<[physicsShapes count]; i++) {
                DisplayGroupTransform *dgroup = [physicsShapes objectAtIndex:i];
                GLKMatrix3 gtran = dgroup.transform;
                //[self renderDisplayGroup:dgroup.group forLayer:dgroup.group.layer.index+1 withAlpha:1.0 transform:gtran];
                [self renderPhysicsShapeDisplayGroup:dgroup.group forLayer:dgroup.group.layer.index+1 withAlpha:1.0 transform:gtran];
            }
        }
        
    }
}




-(void)renderDisplayGroup:(GemDisplayGroup *)group forLayer:(int)layer withAlpha:(GLfloat)alpha transform:(GLKMatrix3)transform {
    
    if (!group.isVisible) {
        return;
    }
    
    GemPhysicsDrawMode drawMode = [Gemini shared].physics.drawMode;
    
    NSMutableArray *lines = [NSMutableArray arrayWithCapacity:1];
    NSMutableArray *shapes = [NSMutableArray arrayWithCapacity:1];
    
      
    GLKMatrix3 cumulTransform = GLKMatrix3Multiply(transform, group.transform);
    GLfloat groupAlpha = group.alpha;
    GLfloat cumulAlpha = groupAlpha * alpha;
    
    for (int i=0; i<[group.objects count]; i++) {
        
        GemDisplayObject *gemObj = (GemDisplayObject *)[group.objects objectAtIndex:i];
        if (gemObj.isVisible) {
            if (gemObj.class == GemDisplayGroup.class) {
                // recursion
                [self renderDisplayGroup:(GemDisplayGroup *)gemObj forLayer:layer withAlpha:cumulAlpha transform:cumulTransform];
                
            } else if (drawMode == GEM_PHYSICS_NORMAL || drawMode == GEM_PHYSICS_HYBRID) {
                if(gemObj.class == GemLine.class){
                    // TODO - sort all lines by line properties so they can be batched
                    [lines addObject:gemObj];
                    
                } else if(gemObj.class == GemSprite.class){
                    [self renderSprite:(GemSprite *)gemObj withLayer:layer alpha:cumulAlpha transform:cumulTransform];
                    
                } else if(gemObj.class == GemRectangle.class){
                    
                    [shapes addObject:gemObj];
                } else if(gemObj.class == GemCircle.class){
                    [shapes addObject:gemObj];
                } else if(gemObj.class == GemConvexShape.class){
                    [shapes addObject:gemObj];
                }
            }
        }
        
        
        
        if (gemObj.physicsBody != NULL && gemObj.isActive && (drawMode == GEM_PHYSICS_DEBUG || drawMode == GEM_PHYSICS_HYBRID)) {
            GemDisplayGroup *phyShapes = getPhysicsShapes((__bridge void *)(gemObj), [[Gemini shared].physics getScale]);
            DisplayGroupTransform *dgt = [[DisplayGroupTransform alloc] init];
            dgt.transform = cumulTransform;
            dgt.group = phyShapes;
            [physicsShapes addObject:dgt];
        }
        
    }

    
    if (drawMode == GEM_PHYSICS_NORMAL || drawMode == GEM_PHYSICS_HYBRID) {
        if ([lines count] > 0) {
            [self renderLines:lines layerIndex:layer alpha:cumulAlpha tranform:cumulTransform];
        }
        
        if ([shapes count] > 0) {
            [self renderShapes:shapes withLayer:layer alpha:cumulAlpha transform:cumulTransform];
        }
    }
    
}

-(void)renderPhysicsShapeDisplayGroup:(GemDisplayGroup *)group forLayer:(int)layer withAlpha:(GLfloat)alpha transform:(GLKMatrix3)transform {
    NSMutableArray *lines = [NSMutableArray arrayWithCapacity:1];
    NSMutableArray *shapes = [NSMutableArray arrayWithCapacity:1];
    
    
    GLKMatrix3 cumulTransform = GLKMatrix3Multiply(transform, group.transform);
    GLfloat groupAlpha = group.alpha;
    GLfloat cumulAlpha = groupAlpha * alpha;
    
    for (int i=0; i<[group.objects count]; i++) {
        
        GemDisplayObject *gemObj = (GemDisplayObject *)[group.objects objectAtIndex:i];
        if (!gemObj.isVisible) {
            //continue;
        }
        
        if (gemObj.class == GemLine.class){
            // TODO - sort all lines by line properties so they can be batched
            [lines addObject:gemObj];
            
        } else if(gemObj.class == GemSprite.class){
            [self renderSprite:(GemSprite *)gemObj withLayer:layer alpha:cumulAlpha transform:cumulTransform];
            
        } else if(gemObj.class == GemRectangle.class){
            
            [shapes addObject:gemObj];
        } else if(gemObj.class == GemCircle.class){
            [shapes addObject:gemObj];
        } else if(gemObj.class == GemConvexShape.class){
            [shapes addObject:gemObj];
        }  
    }
    
    
    if ([lines count] > 0) {
        [self renderLines:lines layerIndex:layer alpha:cumulAlpha tranform:cumulTransform];
    }
    
    if ([shapes count] > 0) {
        [self renderShapes:shapes withLayer:layer alpha:cumulAlpha transform:cumulTransform];
    }


}

-(void)renderSpriteBatches {
    //return;
    GemOpenGLState *glState = [GemOpenGLState shared];
    
    if (glState.boundVertexArrayObject != spriteVAO) {
        glBindVertexArrayOES(spriteVAO);
        glState.boundVertexArrayObject = spriteVAO;
    }
    
    glBindVertexArrayOES(spriteVAO);
    glState.boundVertexArrayObject = spriteVAO;
    
    glUseProgram(spriteShaderManager.program);
    
    glBindBuffer(GL_ARRAY_BUFFER, spriteVBO[spriteRingBufferOffset]);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, spriteVBO[spriteRingBufferOffset+1]);
    
    if (spriteRingBufferOffset == 0) {
        spriteRingBufferOffset = 2;
    } else {
        spriteRingBufferOffset = 0;
    }
    
    glVertexAttribPointer(ATTRIB_VERTEX_SPRITE, 3, GL_FLOAT, GL_FALSE, sizeof(GemTexturedVertex), (GLvoid *)0);
    
    glVertexAttribPointer(ATTRIB_COLOR_SPRITE, 4, GL_FLOAT, GL_FALSE, 
                          sizeof(GemTexturedVertex), (GLvoid*) (sizeof(float) * 3));
    glVertexAttribPointer(ATTRIB_TEXCOORD_SPRITE, 2, GL_FLOAT, GL_FALSE, sizeof(GemTexturedVertex), (GLvoid *)(sizeof(float) * 7));
    
    NSEnumerator *textureEnumerator = [spriteBatches keyEnumerator];
    GLKTextureInfo *texture;
    while (texture = (GLKTextureInfo *)[textureEnumerator nextObject]) {
        GemSpriteBatch *batch = [spriteBatches objectForKey:texture];
        //GLuint indexByteCount = 6 * [batch count] * sizeof(GLushort);
        GLuint indexByteCount = (4 * [batch count] + 2*([batch count] - 1)) * sizeof(GLushort);
        GLushort *index = (GLushort *)malloc(indexByteCount);
        
        unsigned int indexCount = 0;
        for (int i=0; i<[batch count]; i++) {
            index[i*6] = indexCount++;
            index[i*6 + 1] = indexCount++;
            index[i*6 + 2] = indexCount++;
            index[i*6 + 3] = indexCount++;
            
            if (i < [batch count] - 1) {
                index[i*6 + 4] = indexCount - 1;
                index[i*6 + 5] = indexCount;
            }
            
            
        }
                                                         
        
        glBufferSubData(GL_ARRAY_BUFFER, 0, [batch count] * 4*sizeof(GemTexturedVertex), batch.vertexBuffer);
        glBufferSubData(GL_ELEMENT_ARRAY_BUFFER, 0, indexByteCount, index);
        
        glActiveTexture(GL_TEXTURE0); 
        GLuint texId = texture.name;
        glBindTexture(GL_TEXTURE_2D, texId);
        glUniform1i(uniforms_sprite[UNIFORM_TEXTURE_SPRITE], 0); 
        
        
        glDrawElements(GL_TRIANGLE_STRIP, indexByteCount / sizeof(GLushort), GL_UNSIGNED_SHORT, (void*)0);
        
        free(index);
    }
    
    glBindVertexArrayOES(0);
    
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
  

    [spriteBatches removeAllObjects];
}

-(void)renderSprite:(GemSprite *)sprite withLayer:(int)layerIndex alpha:(GLfloat)alpha transform:(GLKMatrix3)transform {
    
    GLKMatrix3 finalTransform = GLKMatrix3Multiply(transform, sprite.transform);
        
    GLfloat z = ((GLfloat)(layerIndex)) / 256.0 - 0.5;
    
    transformVertices(posVerts, sprite.frameCoords, 4, finalTransform);
    
    GemSpriteBatch *sprites = (GemSpriteBatch *)[spriteBatches objectForKey:sprite.textureInfo];
    if (sprites == nil) {
        sprites = [[GemSpriteBatch alloc] initWithCapacity:SPRITE_BATCH_CHUNK_SIZE];
        [spriteBatches setObject:sprites forKey:sprite.textureInfo];
        
    }
    
    GemTexturedVertex *spriteVerts = [sprites getPointerForInsertion];
    
    GLKVector4 texCoord = sprite.textureCoord;
    
    // account for sprite orientation
    if (sprite.isFlippedHorizontally) {
        GLfloat oldX = texCoord.x;
        texCoord.x = texCoord.z;
        texCoord.z = oldX;
    }
    
    if (sprite.isFlippedVertically) {
        GLfloat oldY = texCoord.y;
        texCoord.y = texCoord.w;
        texCoord.w = oldY;
    }
    
    GLfloat texCoordX = texCoord.x;
    GLfloat texCoordY = texCoord.y;
    GLfloat texCoordZ = texCoord.z;
    GLfloat texCoordW = texCoord.w;
    
    
    for (int i=0; i<4; i++) {
        
        for (int j=0; j<2; j++) {
            
            spriteVerts[i].position[j] = posVerts[i*3+j];
            spriteVerts[i].color[j] = 1.0; // TODO - allow use of colors here
        }
        spriteVerts[i].position[2] = z;
        spriteVerts[i].color[2] = 1.0;
        spriteVerts[i].color[3] = sprite.alpha * alpha;
        spriteVerts[i].texCoord[0] = (i == 0 || i == 1) ? texCoordX : texCoordZ;
        spriteVerts[i].texCoord[1] = (i == 0 || i == 2) ? texCoordY : texCoordW;
    }
    
    //free(posVerts);
    
}


-(void)renderLines:(NSArray *)lines layerIndex:(int)layerIndex alpha:(GLfloat)alpha tranform:(GLKMatrix3 ) transform {
    
    GemOpenGLState *glState = [GemOpenGLState shared];
    
    if (glState.boundVertexArrayObject != lineVAO) {
        glBindVertexArrayOES(lineVAO);
        glState.boundVertexArrayObject = lineVAO;
    }
    
    
    glUseProgram(lineShaderManager.program);
    
    glBindBuffer(GL_ARRAY_BUFFER, lineVBO[lineRingBufferOffset]);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, lineVBO[lineRingBufferOffset + 1]);
    if (lineRingBufferOffset == 0) {
        lineRingBufferOffset = 2;
    } else {
        lineRingBufferOffset = 0;
    }
    
    glVertexAttribPointer(ATTRIB_VERTEX_LINE, 3, GL_FLOAT, GL_FALSE, 0, (GLvoid *)0);
    
    for (int i=0; i<[lines count]; i++) {
        GemLine *line = (GemLine *)[lines objectAtIndex:i];
        
               
        [self renderLine:line withLayer:layerIndex alpha:alpha transform:transform];
        
    }
    
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
}

-(void)renderLine:(GemLine *)line withLayer:(int)layerIndex alpha:(GLfloat)alpha transform:(GLKMatrix3)transform {
    
    GLfloat z = ((GLfloat)(layerIndex)) / 256.0 - 0.5;
    //[line computeVertices:layerIndex];
    
    glUniform4f(uniforms_line[UNIFORM_COLOR_LINE], line.color.r, line.color.g, line.color.b, line.color.a * line.alpha * alpha);

    
    GLKMatrix3 finalTransform = GLKMatrix3Multiply(transform, line.transform);
    
    GLfloat *newVerts = (GLfloat *)malloc(line.numPoints * 6*sizeof(GLfloat));
    transformVertices(newVerts, line.verts, line.numPoints*2, finalTransform);
    
    GLfloat *finalVerts = (GLfloat *)malloc(line.numPoints * 6 *sizeof(GLfloat));
    for (int i=0; i<line.numPoints * 2; i++) {
        finalVerts[i*3] = newVerts[i*3];
        finalVerts[i*3+1] = newVerts[i*3+1];
        finalVerts[i*3+2] = z;
    }
    
    glBufferSubData(GL_ARRAY_BUFFER, 0, 6*line.numPoints*sizeof(GLfloat), finalVerts);
    //glBufferSubData(GL_ARRAY_BUFFER, 0, 6*line.numPoints*sizeof(GLfloat), line.verts);
    glBufferSubData(GL_ELEMENT_ARRAY_BUFFER, 0, (line.numPoints - 1)*6*sizeof(GLushort), line.vertIndex);
    
    glDrawElements(GL_TRIANGLES,(line.numPoints - 1)*6,GL_UNSIGNED_SHORT, (void*)0);
    
    free(finalVerts);
    free(newVerts);
}

-(void)renderShapes:(NSArray *)shapes withLayer:(int)layerIndex alpha:(GLfloat)alpha transform:(GLKMatrix3)transform {
    GLfloat z = ((GLfloat)(layerIndex)) / 256.0 - 0.5;
    
    
    GemOpenGLState *glState = [GemOpenGLState shared];
    //if (glState.boundVertexArrayObject != rectangleVAO) {
    glBindVertexArrayOES(rectangleVAO);
    glState.boundVertexArrayObject = rectangleVAO;
    //}
    
    
    glUseProgram(rectangleShaderManager.program);
    
    
    glBindBuffer(GL_ARRAY_BUFFER, rectangleVBO[0]);
    
    
    if (ringBufferOffset == 0) {
        ringBufferOffset = 2;
    } else {
        ringBufferOffset = 0;
    }
    
    //GemCheckGLError();
    
    // invalidate the VBO mappings to make sure any leftover rendering will get done
    //glMapBufferRangeEXT(GL_ARRAY_BUFFER, 0, 0, GL_MAP_INVALIDATE_BUFFER_BIT_EXT);
    //GemCheckGLError();
    //glMapBufferRangeEXT(GL_ELEMENT_ARRAY_BUFFER, 0, 0, GL_MAP_INVALIDATE_BUFFER_BIT_EXT);
    
    GemCheckGLError();
    
    GLvoid *vbuf;
    GLvoid *ibuf;
    
  /* if (firstPass) {
        firstPass = NO;
        vbuf = glMapBufferRangeEXT(GL_ARRAY_BUFFER, 0, 15000, GL_MAP_WRITE_BIT_EXT | GL_MAP_INVALIDATE_BUFFER_BIT_EXT);
        GemCheckGLError();
        ibuf = glMapBufferRangeEXT(GL_ELEMENT_ARRAY_BUFFER, 0, 5000, GL_MAP_WRITE_BIT_EXT | GL_MAP_INVALIDATE_BUFFER_BIT_EXT);
        GemCheckGLError(); */
  //  } else {
        vbuf = glMapBufferRangeEXT(GL_ARRAY_BUFFER, 0, 15000, GL_MAP_WRITE_BIT_EXT);
        GemCheckGLError();
        ibuf = glMapBufferRangeEXT(GL_ELEMENT_ARRAY_BUFFER, 0, 5000, GL_MAP_WRITE_BIT_EXT);
        GemCheckGLError();
    //}
    
    
    GLuint vertOffset = 0;  // offsets into the mapped VBOs
    GLuint indexOffset = 0;

    for (int i=0; i<[shapes count]; i++) {
        GemShape *shape = (GemShape *)[shapes objectAtIndex:i];
        //GemLog(@"Rendering shape %@", shape.name);
        
        GLKMatrix3 finalTransform = GLKMatrix3Multiply(transform, shape.transform);
        
        shape.cumulativeTransform = finalTransform;
        
        unsigned int vertCount = shape.vertCount;
        unsigned int indexCount = shape.vertIndexCount;
       
        GLfloat *newVerts = (GLfloat *)malloc(vertCount * 3 * sizeof(GLfloat));
        
        transformVertices(newVerts, shape.verts, vertCount, finalTransform);
        
        GLfloat finalAlpha = alpha * shape.alpha;
        
        GemColoredVertex *vertData = (GemColoredVertex *)(vbuf + vertOffset); // offset pointer into VBO mapping
        
        // add our vertex data to our VBO
        for (int j=0; j<vertCount; j++) {
            vertData[j].position[0] = newVerts[j*3];
            vertData[j].position[1] = newVerts[j*3+1];
            vertData[j].position[2] = z;
            vertData[j].color[0] = shape.vertColor[j*4];
            vertData[j].color[1] = shape.vertColor[j*4+1];
            vertData[j].color[2] = shape.vertColor[j*4+2];
            vertData[j].color[3] = shape.vertColor[j*4+3] * finalAlpha;            
        }
        
        free(newVerts);
        
        GLushort *newIndex = (GLushort *)(ibuf + indexOffset); // offset pointer into VBO mapping
        
        GLushort vertIndexOffset = vertOffset / sizeof(GemColoredVertex);
        
        for (int j=0; j<indexCount; j++) {
            newIndex[j] = shape.vertIndex[j] + vertIndexOffset;
        }
        
        vertOffset += vertCount*sizeof(GemColoredVertex);
        indexOffset += indexCount*sizeof(GLushort);
        
    }
    
    
    
    glDisable(GL_CULL_FACE);
    
    glDrawElements(GL_TRIANGLE_STRIP, indexOffset / sizeof(GLushort), GL_UNSIGNED_SHORT, (void*)0);
    
    //GemCheckGLError();
    
    glUnmapBufferOES(GL_ARRAY_BUFFER);
    glUnmapBufferOES(GL_ELEMENT_ARRAY_BUFFER);
    
    //GemCheckGLError();
    
    glBindVertexArrayOES(0);
    
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
}


-(void)setupLineRendering {
    
    glGenBuffers(4, lineVBO);
    
    glBindBuffer(GL_ARRAY_BUFFER, lineVBO[0]);
    glBufferData(GL_ARRAY_BUFFER, 4096*sizeof(GLfloat), NULL, GL_DYNAMIC_DRAW);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, lineVBO[1]);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, 8096*sizeof(GLushort), NULL, GL_DYNAMIC_DRAW);
    
    glBindBuffer(GL_ARRAY_BUFFER, lineVBO[2]);
    glBufferData(GL_ARRAY_BUFFER, 4096*sizeof(GLfloat), NULL, GL_DYNAMIC_DRAW);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, lineVBO[3]);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, 8096*sizeof(GLushort), NULL, GL_DYNAMIC_DRAW);
    
    glGenVertexArraysOES(1, &lineVAO);
    glBindVertexArrayOES(lineVAO);
    
    lineShaderManager = [[GemLineShaderManager alloc] init];
    [lineShaderManager loadShaders];
    
    glUseProgram(lineShaderManager.program);
    
    GLKMatrix4 modelViewProjectionMatrix = computeModelViewProjectionMatrix(YES);
    
    glUniformMatrix4fv(uniforms_line[UNIFORM_PROJECTION_LINE], 1, 0, modelViewProjectionMatrix.m);
    glEnableVertexAttribArray(ATTRIB_VERTEX_LINE);
    glEnable(GL_DEPTH_TEST);
    glDepthFunc(GL_LEQUAL);
    
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    
    glBindVertexArrayOES(0);
}


-(void)setupRectangleRendering {
    
    glGenVertexArraysOES(1, &rectangleVAO);
    glBindVertexArrayOES(rectangleVAO);
    
    glGenBuffers(4, rectangleVBO);
    glBindBuffer(GL_ARRAY_BUFFER, rectangleVBO[0]);
    glBufferData(GL_ARRAY_BUFFER, 5512*sizeof(GemColoredVertex), NULL, GL_DYNAMIC_DRAW);
    
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, rectangleVBO[1]);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, 5512*sizeof(GLushort), NULL, GL_DYNAMIC_DRAW);
    
    /*glBindBuffer(GL_ARRAY_BUFFER, rectangleVBO[2]);
    glBufferData(GL_ARRAY_BUFFER, 5512*sizeof(GemColoredVertex), NULL, GL_DYNAMIC_DRAW);
    
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, rectangleVBO[3]);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, 5512*sizeof(GLushort), NULL, GL_DYNAMIC_DRAW);*/
    
    rectangleShaderManager = [[GeminiRectangleShaderManager alloc] init];
    [rectangleShaderManager loadShaders];
    
    glUseProgram(rectangleShaderManager.program);
    
    
    glEnableVertexAttribArray(ATTRIB_VERTEX_RECTANGLE);
    glEnableVertexAttribArray(ATTRIB_COLOR_RECTANGLE);
    glVertexAttribPointer(ATTRIB_VERTEX_RECTANGLE, 3, GL_FLOAT, GL_FALSE, sizeof(GemColoredVertex), (GLvoid *)0);
    
    glVertexAttribPointer(ATTRIB_COLOR_RECTANGLE, 4, GL_FLOAT, GL_FALSE,
                          sizeof(GemColoredVertex), (GLvoid*) (sizeof(float) * 3));
    
    GLKMatrix4 modelViewProjectionMatrix = computeModelViewProjectionMatrix(YES);
    
    glUniformMatrix4fv(uniforms_rectangle[UNIFORM_PROJECTION_RECTANGLE], 1, 0, modelViewProjectionMatrix.m);
   
    glEnable(GL_DEPTH_TEST);
    glDepthFunc(GL_LEQUAL);
    
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    
    glBindVertexArrayOES(0);
}

-(void)setupSpriteRendering {
    
    glGenBuffers(4, spriteVBO);
    
    glBindBuffer(GL_ARRAY_BUFFER, spriteVBO[0]);
    glBufferData(GL_ARRAY_BUFFER, 32000*sizeof(GLfloat), NULL, GL_DYNAMIC_DRAW);
    
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, spriteVBO[1]);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, 32000*sizeof(GLushort), NULL, GL_DYNAMIC_DRAW);
    
    glBindBuffer(GL_ARRAY_BUFFER, spriteVBO[2]);
    glBufferData(GL_ARRAY_BUFFER, 32000*sizeof(GLfloat), NULL, GL_DYNAMIC_DRAW);
    
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, spriteVBO[3]);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, 32000*sizeof(GLushort), NULL, GL_DYNAMIC_DRAW);
    
    glGenVertexArraysOES(1, &spriteVAO);
    glBindVertexArrayOES(spriteVAO);
    
    spriteBatches = [[NSMutableDictionary alloc] initWithCapacity:1];
    
    spriteShaderManager = [[GemSpriteShaderManager alloc] init];
    [spriteShaderManager loadShaders];
    
    glUseProgram(spriteShaderManager.program);
        
    glEnableVertexAttribArray(ATTRIB_VERTEX_SPRITE);
    glEnableVertexAttribArray(ATTRIB_COLOR_SPRITE);
    glEnableVertexAttribArray(ATTRIB_TEXCOORD_SPRITE);
    
    GLKMatrix4 modelViewProjectionMatrix = computeModelViewProjectionMatrix(YES);
    
    glUniformMatrix4fv(uniforms_sprite[UNIFORM_PROJECTION_SPRITE], 1, 0, modelViewProjectionMatrix.m);
    
    glEnable(GL_DEPTH_TEST);
    glDepthFunc(GL_LEQUAL);
    
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    
    glBindVertexArrayOES(0);
}


-(void)setupGL {
    
    [self setupLineRendering];
    [self setupRectangleRendering];
    [self setupSpriteRendering];
    physicsShapes = [NSMutableArray arrayWithCapacity:1];
}

-(id) initWithLuaState:(lua_State *)luaState {
    self = [super init];
    if (self) {

        [self setupGL];
        
    }
    
    return self;
}



// vector functions



@end
