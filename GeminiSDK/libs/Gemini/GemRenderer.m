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
#import "GemSprite.h"
#import "GemLayer.h"
#import "LGeminiDisplay.h"
#import "GemSpriteBatch.h"
#import "GemGLKViewController.h"

#define LINE_BUFFER_CHUNK_SIZE (512)

#define SPRITE_BATCH_CHUNK_SIZE (64)


BOOL bufferCreated = NO;
GLfloat lineWidth[512];
GLuint lineCount = 0;

GLfloat posVerts[12];
GLfloat newPosVerts[12];
GLKVector3 vectorArray[1024];

GLuint rectangleVBO[4];
GLuint lineVBO[4];
GLuint spriteVBO[4];

GemColoredVertex *blendedRectangles;
GemColoredVertex *unblendedRectangles;

GLuint ringBufferOffset = 0;
GLuint lineRingBufferOffset = 0;
GLuint spriteRingBufferOffset = 0;

@implementation GemRenderer

//
// apply a transform to a set of vertices.  
// the ouput array should be preallocated to the same size as the input array
//
static void transformVertices(GLfloat *outVerts, GLfloat *inVerts, GLuint vertCount, GLKMatrix3 transform){
    
    // create an array of vectors from our input data
   // GLKVector3 *vectorArray = (GLKVector3 *)malloc(vertCount * sizeof(GLKVector3));
    /*for (GLuint i = 0; i<vertCount; i++) {
        vectorArray[i] = GLKVector3MakeWithArray(inVerts + 3*i); 
    }*/
    
    memcpy(vectorArray, inVerts, vertCount * sizeof(GLKVector3));
    
    GLKMatrix3MultiplyVector3Array(transform, vectorArray, vertCount);
    
    memcpy(outVerts, vectorArray, vertCount * sizeof(GLKVector3));
    
    /*for (GLuint i = 0; i<vertCount; i++) {
        
        outVerts[i*3] = vectorArray[i].x;
        outVerts[i*3+1] = vectorArray[i].y;
        outVerts[i*3+2] = vectorArray[i].z;
        
    }*/
    
    //free(vectorArray);
    
}

-(void)render {
    NSArray *blendedLayers = [self renderUnblendedLayers];
    [self renderBlendedLayers:blendedLayers];
    glBindVertexArrayOES(0);
}

// render layers from front to back to minimize overdraw
-(NSArray *)renderUnblendedLayers {
    glDisable(GL_BLEND);
    glDepthMask(GL_TRUE);
    NSMutableArray *blendedLayers = [[[NSMutableArray alloc] initWithCapacity:1] autorelease];
    
    NSMutableDictionary *stage = (NSMutableDictionary *)[stages objectForKey:activeStage];
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
    glEnable(GL_BLEND);
    glDepthMask(GL_FALSE);
    for (int i=0; i<[layers count]; i++) {
        
        NSObject *obj = [layers objectAtIndex:i];
        if (obj.class == NSValue.class) {
            // this is a callback layer
            void(*callback)(void) = (void (*)(void))[(NSValue *)obj pointerValue];
            callback();
        } else {
            // a display group layer
            GemLayer *layer = (GemLayer *)obj;
            
            GLKMatrix3 transform = GLKMatrix3Identity;
            
            glBlendFunc(layer.sourceBlend, layer.destBlend);
            
            [self renderDisplayGroup:layer forLayer:layer.index withAlpha:1.0 transform:transform];
            
        }
        
        if ([spriteBatches count] > 0) {
            [self renderSpriteBatches];
        }

        
    }
}




-(void)renderDisplayGroup:(GemDisplayGroup *)group forLayer:(int)layer withAlpha:(GLfloat)alpha transform:(GLKMatrix3)transform {
    
    if (!group.isVisible) {
        return;
    }
    
    NSMutableArray *lines = [NSMutableArray arrayWithCapacity:1];
    NSMutableArray *rectangles = [NSMutableArray arrayWithCapacity:1];
    
    GLKMatrix3 cumulTransform = GLKMatrix3Multiply(transform, group.transform);
    GLfloat groupAlpha = group.alpha;
    GLfloat cumulAlpha = groupAlpha * alpha;
    
    for (int i=0; i<[group.objects count]; i++) {
        
        GemDisplayObject *gemObj = (GemDisplayObject *)[group.objects objectAtIndex:i];
        if (!gemObj.isVisible) {
            continue;
        }
        if (gemObj.class == GemDisplayGroup.class) {
            // recursion
            [self renderDisplayGroup:(GemDisplayGroup *)gemObj forLayer:layer withAlpha:cumulAlpha transform:cumulTransform];
            
        } else if(gemObj.class == GemLine.class){
            // TODO - sort all lines by line properties so they can be batched
            [lines addObject:gemObj];
            
        } else if(gemObj.class == GemSprite.class){
            [self renderSprite:(GemSprite *)gemObj withLayer:layer alpha:cumulAlpha transform:cumulTransform];
                                    
        } else if(gemObj.class == GemRectangle.class){
            //[self renderRectangle:((GeminiRectangle *)gemObj) withLayer:layer alpha:cumulAlpha transform:transform];
            [rectangles addObject:gemObj];
        }
        
    }
    
    if ([lines count] > 0) {
        [self renderLines:lines layerIndex:layer alpha:cumulAlpha tranform:cumulTransform];
    }
    if ([rectangles count] > 0) {
       [self renderRectangles:rectangles withLayer:layer alpha:cumulAlpha transform:cumulTransform];
    }
    
    
}

-(void)renderSpriteBatches {
    glBindVertexArrayOES(spriteVAO);
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
        //glDrawElements(GL_TRIANGLE_STRIP, 10, GL_UNSIGNED_SHORT, (void*)0);
        
        free(index);
    }
  

    [spriteBatches removeAllObjects];
}

-(void)renderSprite:(GemSprite *)sprite withLayer:(int)layerIndex alpha:(GLfloat)alpha transform:(GLKMatrix3)transform {
    
    GLKMatrix3 finalTransform = GLKMatrix3Multiply(transform, sprite.transform);
        
    GLfloat z = ((GLfloat)(layerIndex)) / 256.0 - 0.5;
    
    transformVertices(posVerts, sprite.frameCoords, 4, finalTransform);
    
    GemSpriteBatch *sprites = (GemSpriteBatch *)[spriteBatches objectForKey:sprite.textureInfo];
    if (sprites == nil) {
        sprites = [[[GemSpriteBatch alloc] initWithCapacity:SPRITE_BATCH_CHUNK_SIZE] autorelease];
        [spriteBatches setObject:sprites forKey:sprite.textureInfo];
        
    }
    
    GemTexturedVertex *spriteVerts = [sprites getPointerForInsertion];
    
    GLKVector4 texCoord = sprite.textureCoord;
    
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
        spriteVerts[i].color[3] = sprite.alpha;
        spriteVerts[i].texCoord[0] = (i == 0 || i == 1) ? texCoordX : texCoordZ;
        spriteVerts[i].texCoord[1] = (i == 0 || i == 2) ? texCoordY : texCoordW;
    }
    
    //free(posVerts);
    
}


-(void)renderLines:(NSArray *)lines layerIndex:(int)layerIndex alpha:(GLfloat)alpha tranform:(GLKMatrix3 ) transform {
    
    glBindVertexArrayOES(lineVAO);
    
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
        
        glUniform4f(uniforms_line[UNIFORM_COLOR_LINE], line.color.r, line.color.g, line.color.b, line.color.a * line.alpha);
       
        [self renderLine:line withLayer:layerIndex alpha:alpha transform:transform];
        
    }
}

-(void)renderLine:(GemLine *)line withLayer:(int)layerIndex alpha:(GLfloat)alpha transform:(GLKMatrix3)transform {
    
    GLfloat z = ((GLfloat)(layerIndex)) / 256.0 - 0.5;
    //[line computeVertices:layerIndex];
    
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
    
    free(newVerts);
}

-(void)renderRectangleBatch {
    
}

-(void)renderRectangles:(NSArray *)rectangles withLayer:(int)layerIndex alpha:(GLfloat)alpha transform:(GLKMatrix3)transform {
    
     GLfloat z = ((GLfloat)(layerIndex)) / 256.0 - 0.5;
    
    glBindVertexArrayOES(rectangleVAO);
    
    glUseProgram(rectangleShaderManager.program);
    
    glBindBuffer(GL_ARRAY_BUFFER, rectangleVBO[ringBufferOffset]);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, rectangleVBO[ringBufferOffset + 1]);
    
    if (ringBufferOffset == 0) {
        ringBufferOffset = 2;
    } else {
        ringBufferOffset = 0;
    }
    
    glVertexAttribPointer(ATTRIB_VERTEX_RECTANGLE, 3, GL_FLOAT, GL_FALSE, sizeof(GemColoredVertex), (GLvoid *)0);
    
    glVertexAttribPointer(ATTRIB_COLOR_RECTANGLE, 4, GL_FLOAT, GL_FALSE, 
                          sizeof(GemColoredVertex), (GLvoid*) (sizeof(float) * 3));
    
    
    GLuint vertOffset = 0;
    GLuint indexOffset = 0;
    
    GLfloat newVerts[36];
    GemColoredVertex vertData[12];
    GLushort newIndex[30];
    
    for (int i=0; i<[rectangles count]; i++) {
        GemRectangle *rectangle = (GemRectangle *)[rectangles objectAtIndex:i];
        GLKMatrix3 finalTransform = GLKMatrix3Multiply(transform, rectangle.transform);
        
        //GLfloat *newVerts = (GLfloat *)malloc(12*3*sizeof(GLfloat));
                
        unsigned int vertCount = 4;
        unsigned int indexCount = 6;
        if (rectangle.strokeWidth > 0) {
            vertCount = 12;
            indexCount = 30;
        }
        
        transformVertices(newVerts, rectangle.verts, vertCount, finalTransform);
        
        GLfloat finalAlpha = alpha * rectangle.alpha;
        
        //memcpy(newVerts, rectangle.verts, vertCount*3*sizeof(GLfloat));
        
        //ColoredVertex *vertData = (ColoredVertex *)malloc(vertCount*sizeof(ColoredVertex));
        
        
        for (int j=0; j<vertCount; j++) {
            vertData[j].position[0] = newVerts[j*3];
            vertData[j].position[1] = newVerts[j*3+1];
            vertData[j].position[2] = z;
            vertData[j].color[0] = rectangle.vertColor[j*4];
            vertData[j].color[1] = rectangle.vertColor[j*4+1];
            vertData[j].color[2] = rectangle.vertColor[j*4+2];
            vertData[j].color[3] = rectangle.vertColor[j*4+3] * finalAlpha;
        }
        
        //GLushort *newIndex = malloc(indexCount * sizeof(GLushort));
        
        GLushort vertIndexOffset = vertOffset / sizeof(GemColoredVertex);
        
        for (int j=0; j<indexCount; j++) {
            newIndex[j] = rectangle.vertIndex[j] + vertIndexOffset;
        }
        
        glBufferSubData(GL_ARRAY_BUFFER, vertOffset, vertCount*sizeof(GemColoredVertex), vertData);
        glBufferSubData(GL_ELEMENT_ARRAY_BUFFER, indexOffset, indexCount*sizeof(GLushort), newIndex);
        
        vertOffset += vertCount*sizeof(GemColoredVertex);
        indexOffset += indexCount*sizeof(GLushort);
       
    }
    
    glDrawElements(GL_TRIANGLES, indexOffset / sizeof(GLushort), GL_UNSIGNED_SHORT, (void*)0);

}


// add a new layer
-(void)addLayer:(GemLayer *)layer {
    NSLog(@"GeminiRenderer adding layer with index %d", layer.index);
    NSMutableDictionary *stage = (NSMutableDictionary *)[stages objectForKey:activeStage];
    [stage setObject:layer forKey:[NSNumber numberWithInt:layer.index]];
}


// add a display object to the default layer (layer 0)
-(void)addObject:(GemDisplayObject *)obj {
    NSLog(@"GeminiRenderer adding object");
    NSMutableDictionary *stage = (NSMutableDictionary *)[stages objectForKey:activeStage];
    // get the default layer on the stage
    NSNumber *layerIndex = [NSNumber numberWithInt:0];
    GemLayer *layerGroup = (GemLayer *)[stage objectForKey:layerIndex];
    // remove from previous layer (if any) first
    [obj.layer remove:obj];
    obj.layer = layerGroup;
    [layerGroup insert:obj];
    
}


// add a display object to a given layer of the currently active stage.  create the layer
// if it does not already exist
-(void)addObject:(GemDisplayObject *)obj toLayer:(int)layer {
    NSLog(@"GeminiRenderer adding object");
    NSMutableDictionary *stage = (NSMutableDictionary *)[stages objectForKey:activeStage];
    NSLog(@"GeminiRenderer found stage");
    // sort the layers from front to back
    GemLayer *layerGroup = (GemLayer *)[stage objectForKey:[NSNumber numberWithInt:layer]];
    NSLog(@"GeminiRenderer found layer");
    if (layerGroup == nil) {
        NSLog(@"GeminiRenderer layer is nil");
        layerGroup = [[[GemLayer alloc] initWithLuaState:((GemDisplayObject *)obj).L] autorelease];
        layerGroup.index = layer;
        NSLog(@"GeminiRenderer created new layer");
        [stage setObject:layerGroup forKey:[NSNumber numberWithInt:layer]];
    }
    NSLog(@"Inserting object into layer %d", layer);
    // remove from previous layer (if any) first
    [obj.layer remove:obj];
    obj.layer = layerGroup;
    [layerGroup insert:obj];
    
}

// allow the client to register a callback to render for a particular layer
-(void)addCallback:(void (*)(void))callback forLayer:(int)layer {
     NSMutableDictionary *stage = (NSMutableDictionary *)[stages objectForKey:activeStage];
    NSValue *sel = [NSValue valueWithPointer:callback];
    [stage setObject:sel forKey:[NSNumber numberWithInt:layer]];
}

-(void)setActiveStage:(NSString *)stage {
    if (activeStage != nil) {
        [activeStage release];
    }
    activeStage = [stage retain];
}

-(void)setupLineRendering {
    
    glGenBuffers(4, lineVBO);
    
    glBindBuffer(GL_ARRAY_BUFFER, lineVBO[0]);
    glBufferData(GL_ARRAY_BUFFER, 4096*sizeof(GLfloat), NULL, GL_DYNAMIC_DRAW);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, lineVBO[1]);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, 4096*sizeof(GLushort), NULL, GL_DYNAMIC_DRAW);
    
    glBindBuffer(GL_ARRAY_BUFFER, lineVBO[2]);
    glBufferData(GL_ARRAY_BUFFER, 4096*sizeof(GLfloat), NULL, GL_DYNAMIC_DRAW);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, lineVBO[3]);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, 4096*sizeof(GLushort), NULL, GL_DYNAMIC_DRAW);
    
    glGenVertexArraysOES(1, &lineVAO);
    glBindVertexArrayOES(lineVAO);
    
    lineShaderManager = [[GemLineShaderManager alloc] init];
    [lineShaderManager loadShaders];
    
    glUseProgram(lineShaderManager.program);
    
    GLKView *view = (GLKView *)((GemGLKViewController *)([Gemini shared].viewController)).view;
    
    
    GLfloat width = 960;
    GLfloat height = 640;
    
    GLfloat left = 0;
    GLfloat right = width;
    GLfloat bottom = 0;
    GLfloat top = height;
    
    GLKMatrix4 modelViewProjectionMatrix = GLKMatrix4Make(2.0/(right-left),0,0,0,0,2.0/(top-bottom),0,0,0,0,-1.0,0,-1.0,-1.0,-1.0,1.0);
    glUniformMatrix4fv(uniforms_line[UNIFORM_PROJECTION_LINE], 1, 0, modelViewProjectionMatrix.m);
    glEnableVertexAttribArray(ATTRIB_VERTEX_LINE);
    glEnable(GL_DEPTH_TEST);
    glDepthFunc(GL_LEQUAL);
    
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    
    glBindVertexArrayOES(0);
}

-(void)setupRectangleRendering {
    
    glGenBuffers(4, rectangleVBO);
    glBindBuffer(GL_ARRAY_BUFFER, rectangleVBO[0]);
    glBufferData(GL_ARRAY_BUFFER, 512*sizeof(GemColoredVertex), NULL, GL_DYNAMIC_DRAW);
    
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, rectangleVBO[1]);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, 512*sizeof(GLushort), NULL, GL_DYNAMIC_DRAW);
    
    glBindBuffer(GL_ARRAY_BUFFER, rectangleVBO[2]);
    glBufferData(GL_ARRAY_BUFFER, 512*sizeof(GemColoredVertex), NULL, GL_DYNAMIC_DRAW);
    
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, rectangleVBO[3]);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, 512*sizeof(GLushort), NULL, GL_DYNAMIC_DRAW);

    
    
    glGenVertexArraysOES(1, &rectangleVAO);
    glBindVertexArrayOES(rectangleVAO);
    
    
    rectangleShaderManager = [[GeminiRectangleShaderManager alloc] init];
    [rectangleShaderManager loadShaders];
    
    glUseProgram(rectangleShaderManager.program);
    
    GLKView *view = (GLKView *)((GemGLKViewController *)([Gemini shared].viewController)).view;
    
    
    GLfloat width = 960;
    GLfloat height = 640;
    
    GLfloat left = 0;
    GLfloat right = width;
    GLfloat bottom = 0;
    GLfloat top = height;
    
    
    
    
    glEnableVertexAttribArray(ATTRIB_VERTEX_RECTANGLE);
    glEnableVertexAttribArray(ATTRIB_COLOR_RECTANGLE);
    
    
    
    GLKMatrix4 modelViewProjectionMatrix = GLKMatrix4Make(2.0/(right-left),0,0,0,0,2.0/(top-bottom),0,0,0,0,-1.0,0,-1.0,-1.0,-1.0,1.0);
    glUniformMatrix4fv(uniforms_rectangle[UNIFORM_PROJECTION_RECTANGLE], 1, 0, modelViewProjectionMatrix.m);
   
    //glEnableVertexAttribArray(ATTRIB_VERTEX_RECTANGLE);
    //glEnableVertexAttribArray(ATTRIB_COLOR_RECTANGLE);
    
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
    
    GLKView *view = (GLKView *)((GemGLKViewController *)([Gemini shared].viewController)).view;
    
    
    GLfloat width = 960;
    GLfloat height = 640;
    
    GLfloat left = 0;
    GLfloat right = width;
    GLfloat bottom = 0;
    GLfloat top = height;
    
    glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer);
    glEnableVertexAttribArray(ATTRIB_VERTEX_SPRITE);
    glEnableVertexAttribArray(ATTRIB_COLOR_SPRITE);
    glEnableVertexAttribArray(ATTRIB_TEXCOORD_SPRITE);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, indexBuffer);
    
    
    GLKMatrix4 modelViewProjectionMatrix = GLKMatrix4Make(2.0/(right-left),0,0,0,0,2.0/(top-bottom),0,0,0,0,-1.0,0,-1.0,-1.0,-1.0,1.0);
    glUniformMatrix4fv(uniforms_sprite[UNIFORM_PROJECTION_SPRITE], 1, 0, modelViewProjectionMatrix.m);
    
    
    glEnable(GL_DEPTH_TEST);
    glDepthFunc(GL_LEQUAL);
    
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    
    //glEnable(GL_TEXTURE_2D);
    
    glBindVertexArrayOES(0);
}


-(void)setupGL {
    
    [self setupLineRendering];
    [self setupRectangleRendering];
    [self setupSpriteRendering];
}

-(id) initWithLuaState:(lua_State *)luaState {
    self = [super init];
    if (self) {
        //L = luaState;
        stages = [[NSMutableDictionary alloc] initWithCapacity:1];
        // add a default stage
        NSMutableDictionary *defaultStage = [[NSMutableDictionary alloc] initWithCapacity:1];
        [stages setObject:defaultStage forKey:DEFAULT_STAGE_NAME];
        [self setActiveStage:DEFAULT_STAGE_NAME];
        [defaultStage release];
        [self setupGL];
        
    }
    
    return self;
}

-(void) dealloc {
    // TODO - objects shouldn't be dealloc'ed here - they should be removed in Lua
    NSArray *keys = [stages allKeys];
    for (int i=0; i<[keys count]; i++) {
        //NSString *stageKey = (NSString *)[keys objectAtIndex:i];
        
    }
    
    
    [super dealloc];
    
}

// vector functions



@end
