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

+ (NSURL*) wavToFlac:(NSURL *)wavPath
{
    NSURL * appDir = [self applicationDocumentsDirectory];
    NSURL * writeURL = [appDir URLByAppendingPathComponent:@"temp"];
    
    NSString *flacFileWithoutExtension = writeURL.path;
    NSString *waveFile = wavPath.path;
    
    int interval_seconds = 0;
    char** flac_files = (char**) malloc(sizeof(char*) * 1024);
    
    int conversionResult = convertWavToFlac([waveFile UTF8String], [flacFileWithoutExtension UTF8String], interval_seconds, flac_files);
    
    if (conversionResult) {
        return nil;
    }
    
    return [writeURL URLByAppendingPathExtension:@"flac"];
}

#pragma mark - Utils
+ (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "FM.CoreData" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
