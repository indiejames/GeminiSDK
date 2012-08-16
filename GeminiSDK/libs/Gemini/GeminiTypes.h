//
//  GeminiTypes.h
//  Gemini
//
//  Created by James Norton on 5/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#ifndef Gemini_GeminiTypes_h
#define Gemini_GeminiTypes_h

typedef struct {
    GLfloat position[3];
    GLfloat color[4];
} GemColoredVertex;

typedef struct {
    GLfloat position[3];
    GLfloat color[4];
    GLfloat texCoord[2];
} GemTexturedVertex;




#endif
