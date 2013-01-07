//
//  GemText.m
//  GeminiSDK
//
//  Created by James Norton on 1/3/13.
//
//

#import "GemText.h"
#import "Gemini.h"
#import "GemCharSet.h"


@implementation GemText {
    GemCharSet *charSet;
    NSString *text;
    GLfloat *verts;
    GLKVector2 *texCoord;
}

@synthesize charSet;
@synthesize verts;
@synthesize texCoord;

-(id) initWithLuaState:(lua_State *)luaState font:(NSString *)font {
    self = [super initWithLuaState:luaState LuaKey:GEMINI_TEXT_LUA_KEY];
    
    if (self) {
        charSet = [[Gemini shared].fontManager fontWithName:font];
        assert(charSet != nil);
    }
    
    return self;
}

-(void)dealloc {
    free(verts);
    free(texCoord);
}

-(void)setFont:(NSString *)font {
    charSet = [[Gemini shared].fontManager fontWithName:font];
    if (text != nil) {
        [self computeVertices];
    }
}

-(NSString *)text {
    return text;
}

-(void)setText:(NSString *)txt {
    text = txt;
    if (charSet != nil) {
        [self computeVertices];
    }
}

-(GLfloat)width {
    GLfloat w = 0;
    for (int i=0; i<[text length]; i++) {
        unichar code = [text characterAtIndex:i];
        GemCharRenderInfo rinfo = [charSet renderInfoForChar:code];
        if (i<[text length]-1 || code == 32) {
            // spaces (code 32) have width 0 so we use xadvance for them even if they are
            // the last character in the text
            w += rinfo.xAdvance;
            // kerning
            unichar nextCode = [text characterAtIndex:i+1];
            NSNumber *kerning = [charSet kerningForFirst:code second:nextCode];
            if (kerning != nil) {
                w += [kerning floatValue];
            }
        } else {
            // last character in the text 
            w += (rinfo.offsets.x + rinfo.dimensions.x);
        }
        
    }
    
    return w;
}

-(void)computeVertices {
    verts = (GLfloat *)realloc(verts, [text length] * 4 * 3 * sizeof(GLfloat));
    texCoord = (GLKVector2 *)realloc(texCoord, [text length] * 4 * sizeof(GLKVector2));
    
    assert(verts != 0);
    assert(texCoord != 0);
    
    GLfloat x0 = self.x - self.width / 2.0;
    GLfloat y0 = self.y + self.charSet.lineHeight / 2.0;
    //GLfloat y0 = self.y;
    GLfloat xpos = x0;
    GLfloat ypos;
    for (int i=0; i<[text length]; i++) {
        unichar code = [text characterAtIndex:i];
        if (code == 44) {
            GemLog(@"OK");
        }
        GemCharRenderInfo rinfo = [charSet renderInfoForChar:code];
        xpos = xpos + rinfo.offsets.x;
        //ypos = y0 - rinfo.offsets.y;
        ypos = y0 - rinfo.offsets.y - rinfo.dimensions.y / 2.0;
        
        verts[i*12] = xpos;
        verts[i*12+1] = ypos;
        verts[i*12+2] = 1.0;
        verts[i*12+3] = xpos + rinfo.dimensions.x;
        verts[i*12+4] = ypos;
        verts[i*12+5] = 1.0;
        verts[i*12+6] = xpos;
        verts[i*12+7] = ypos + rinfo.dimensions.y;
        verts[i*12+8] = 1.0;
        verts[i*12+9] = xpos + rinfo.dimensions.x;
        verts[i*12+10] = ypos + rinfo.dimensions.y;
        verts[i*12+11] = 1.0;
        
        texCoord[i*4].x = rinfo.texCoord.x;
        texCoord[i*4].y = rinfo.texCoord.y;
        texCoord[i*4+1].x = rinfo.texCoord.z;
        texCoord[i*4+1].y = rinfo.texCoord.y;
        texCoord[i*4+2].x = rinfo.texCoord.x;
        texCoord[i*4+2].y = rinfo.texCoord.w;
        texCoord[i*4+3].x = rinfo.texCoord.z;
        texCoord[i*4+3].y = rinfo.texCoord.w;
        
        
        if (i<[text length]-1) {
            // spaces (code 32) have width 0 so we use xadvance for them even if they are
            // the last character in the text
            xpos += rinfo.xAdvance;
            
            // kerning
            unichar nextCode = [text characterAtIndex:i+1];
            NSNumber *kerning = [charSet kerningForFirst:code second:nextCode];
            if (kerning != nil) {
                xpos += [kerning floatValue];
            }

        }
        
    }
}

@end
