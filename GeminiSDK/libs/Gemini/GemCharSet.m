//
//  GemCharSet.m
//  GeminiSDK
//
//  Created by James Norton on 1/3/13.
//
//

#import "GemCharSet.h"
#import "Gemini.h"
#import "GLUtils.h"

@implementation GemCharSet {
    GLfloat scale;
    GLfloat lineHeight;
    GLfloat base; // ? TODO - find out what this is for
    GLKTextureInfo *textureInfo;
    NSMutableDictionary *dataByCode;
    NSMutableDictionary *dataByCharacter;
    NSMutableDictionary *kerningPairs;
}

@synthesize scale;

-(id)initWithLuaState:(lua_State *)luaState fontInfo:(NSDictionary *)fontInfo {
    self = [super initWithLuaState:luaState LuaKey:GEMINI_CHARSET_LUA_KEY];
    
    if (self) {
        NSString *filename = [[fontInfo objectForKey:@"info"] objectForKey:@"file"];
        //filename = [[Gemini shared].fileNameResolver resolveNameForFile:filename];
        //textureInfo = [GLKTextureLoader textureWithContentsOfFile:filename options:nil error:nil];
        textureInfo = createTexture(filename);
        
        assert(textureInfo != nil);
        
        lineHeight = [[[fontInfo objectForKey:@"common"] objectForKey:@"lineHeight"] floatValue];
        base = [[[fontInfo objectForKey:@"common"] objectForKey:@"base"] floatValue];
        
        filename = [[Gemini shared].fileNameResolver resolveNameForFile:filename];
        scale = 1.0 / [[Gemini shared].fileNameResolver renderScaleForFile:filename];
        int kerningCounts = [[[fontInfo objectForKey:@"info"] objectForKey:@"kerningCounts"] intValue];
        
        dataByCode = [NSMutableDictionary dictionaryWithCapacity:1];
        dataByCharacter = [NSMutableDictionary dictionaryWithCapacity:1];
        kerningPairs = [NSMutableDictionary dictionaryWithCapacity:kerningCounts];
        
        // process char data
        GLfloat imgWidth = textureInfo.width;
        GLfloat imgHeight = textureInfo.height;
        NSMutableDictionary *charData = [fontInfo objectForKey:@"chars"];
        NSEnumerator *kenum = [charData keyEnumerator];
        id index;
        while ((index = [kenum nextObject])) {
            NSDictionary *cdata = [charData objectForKey:index];
            NSNumber *code = [cdata objectForKey:@"id"];
            //GemLog(@"code = %d", [code intValue]);
            NSString *character = [cdata objectForKey:@"letter"];
            GLfloat x = [[cdata objectForKey:@"x"] floatValue];
            GLfloat y = imgHeight - [[cdata objectForKey:@"y"] floatValue];
            GLfloat charWidth = [[cdata objectForKey:@"width"] floatValue];
            GLfloat charHeight = [[cdata objectForKey:@"height"] floatValue];
            
            GemCharRenderInfo renderInfo;
            GLfloat x0 = x / imgWidth;
            GLfloat x1 = (x + charWidth) / imgWidth;
            GLfloat y0 = (y - charHeight) / imgHeight;
            GLfloat y1 = y / imgHeight;
            
            renderInfo.texCoord.x = x0;
            renderInfo.texCoord.y = y0;
            renderInfo.texCoord.z = x1;
            renderInfo.texCoord.w = y1;
            
            
            renderInfo.dimensions.x = charWidth;
            renderInfo.dimensions.y = charHeight;
            
            renderInfo.offsets.x = [[cdata objectForKey:@"xoffset"] floatValue];
            renderInfo.offsets.y = [[cdata objectForKey:@"yoffset"] floatValue];
            renderInfo.xAdvance = [[cdata objectForKey:@"xadvance"] floatValue];
            
            NSData *renderData = [NSData dataWithBytes:&renderInfo length:sizeof(GemCharRenderInfo)];
           
            [dataByCode setObject:renderData forKey:code];
            [dataByCharacter setObject:renderData forKey:character];
            
            
        }
        
        // kerning pairs
        charData = [fontInfo objectForKey:@"kerning"];
        kenum = [charData keyEnumerator];
        while ((index = [kenum nextObject])) {
            NSDictionary *cdata = [charData objectForKey:index];
            NSNumber *first = [cdata objectForKey:@"first"];
            NSNumber *second = [cdata objectForKey:@"second"];
            NSNumber *amount = [cdata objectForKey:@"amount"];
            
            NSString *key = [NSString stringWithFormat:@"%@:%@", first, second];
            [kerningPairs setValue:amount forKey:key];
        }
        
    }
    
    return self;
}

-(GLKTextureInfo *)textureInfo {
    GLKTextureInfo *rval;
    
    rval =  textureInfo;
    
    return rval;
}

-(GLfloat)lineHeight {
    return  lineHeight * scale;
}

-(GLfloat)base {
    return base * scale;
}

-(GemCharRenderInfo)renderInfoForChar:(unichar)c {
    NSData *data = [dataByCode objectForKey:[NSNumber numberWithUnsignedShort:c]];
    GemCharRenderInfo rval;
    memcpy(&rval, [data bytes], sizeof(GemCharRenderInfo));
    
    // apply scaling if necessary
    if (scale != 1.0) {
        rval.dimensions.x = rval.dimensions.x * scale;
        rval.dimensions.y = rval.dimensions.y * scale;
        rval.offsets.x = rval.offsets.x * scale;
        rval.offsets.y = rval.offsets.y * scale;
        rval.xAdvance = rval.xAdvance * scale;
    }
    
    return rval;
}

-(NSNumber *)kerningForFirst:(unichar)first second:(unichar)second {
    NSString *key = [NSString stringWithFormat:@"%d:%d",first,second];
    return [kerningPairs objectForKey:key];
}

@end
