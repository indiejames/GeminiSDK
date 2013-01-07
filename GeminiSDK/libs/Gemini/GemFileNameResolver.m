//
//  FileNameResolver.m
//  GeminiSDK
//
//  Created by James Norton on 9/16/12.
//
//

#import "GemFileNameResolver.h"
#import "Gemini.h"

// used by Lua
char **gem_suffixes;
int gem_suffix_count;


@interface GemFileNameResolver () {
    NSMutableArray *suffixes;
}
@end

@implementation GemFileNameResolver

-(id)initForWidth:(float)w Height:(float)h ContentScale:(float)scale Settings:(NSDictionary *)settings {
    self = [super init];
    
    if (self) {
        w = w * scale;
        h = h * scale;
        suffixes = [[NSMutableArray alloc] initWithCapacity:1];
        
        NSDictionary *resSettings = [settings objectForKey:[NSString stringWithFormat:@"%dx%d",(int)w,(int)h]];
        
        if (resSettings != nil) {
            
            NSArray *tmpSuffixes = [resSettings objectForKey:@"suffixes"];
            [suffixes addObjectsFromArray:tmpSuffixes];
        }
        
        gem_suffix_count = [suffixes count] + 1;
        gem_suffixes = (char **)malloc(gem_suffix_count * sizeof(char *));
        for (int i=0; i<gem_suffix_count-1; i++) {
            gem_suffixes[i] = (char *)malloc([(NSString *)[suffixes objectAtIndex:i] length] + 1);
            strcpy(gem_suffixes[i], [((NSString *)[suffixes objectAtIndex:i]) UTF8String]);
        }
        gem_suffixes[gem_suffix_count-1] = (char *)malloc(strlen("")+1);
        strcpy(gem_suffixes[gem_suffix_count-1], "");
    }
    
    return self;
}

// choose a file with suffix based on resolution of current device
-(NSString *)resolveNameForFile:(NSString *)fileName ofType:(NSString *)type {
   
    if ([suffixes count] > 0) {
        for (int i=0; i<[suffixes count]; i++) {
            NSString *suffix = [suffixes objectAtIndex:i];
            NSString *tmpFileName = [fileName stringByAppendingString:suffix];
            NSString *localizedPath = [[NSBundle mainBundle] pathForResource:tmpFileName ofType:type];
            if (localizedPath != nil) {
                fileName = tmpFileName;
                break;
            }
            
        }
    }
    
    return fileName;
}

// choose a file with suffix based on resolution of current device
-(NSString *)resolveNameForFile:(NSString *)fileName {
    NSString *suffix = [fileName stringByDeletingPathExtension];
    NSString *ext = [fileName pathExtension];
    return [self resolveNameForFile:suffix ofType:ext];
}

@end
