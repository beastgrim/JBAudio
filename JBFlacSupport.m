//
//  JBFlacSupport.m
//  Over Task
//
//  Created by Евгений Богомолов on 19.03.15.
//  Copyright (c) 2015 Евгений Богомолов. All rights reserved.
//

#import "JBFlacSupport.h"
#include "wav_to_flac.h"

@implementation JBFlacSupport

- (NSString*) wavToFlac:(NSString*)wavPath
{
    NSString *appDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString* writePath = [appDir stringByAppendingFormat:@"/tempFlac"];
    
    NSString *flacFileWithoutExtension = writePath;
    NSString *waveFile = wavPath;
    
    int interval_seconds = 0;
    char** flac_files = (char**) malloc(sizeof(char*) * 1024);
    
    int conversionResult = convertWavToFlac([waveFile UTF8String], [flacFileWithoutExtension UTF8String], interval_seconds, flac_files);
    
    if (conversionResult) {
        return nil;
    }
    return [writePath stringByAppendingString:@".flac"];
}

@end
