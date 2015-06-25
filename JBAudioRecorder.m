//
//  JBAudioRecorder.m
//  Multiplication Table
//
//  Created by Евгений Богомолов on 07.12.14.
//  Copyright (c) 2014 JustGood. All rights reserved.
//

#import "JBAudioRecorder.h"
#import <AVFoundation/AVFoundation.h>

#define kDefaultRecordsPath     @"records/"
#define kDefaultRecordFileName  @"record.m4a"


@interface JBAudioRecorder () <AVAudioRecorderDelegate> {
    AVAudioRecorder         *recorder;
    NSTimer                 *updatePowerSignal;
    BOOL                    mayStop;
}

@end
@implementation JBAudioRecorder {
    JBAudioRecorderCallback     _callback;
}

- (instancetype)init
{
    self = [super init];

    _defaultUrl = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:kDefaultRecordsPath];

    [recorder setDelegate:self];

    _autoPauseRecord = NO;
    _autoStartRecord = NO;
    
    return self;
}

- (void)startRecordAtPath:(NSString *)path
{
    NSURL *url;
    if (!path) {
        url = [_defaultUrl URLByAppendingPathComponent:kDefaultRecordFileName];
    } else {
        url = [NSURL fileURLWithPath:path];
    }
    [[NSFileManager defaultManager] createDirectoryAtURL:[[self applicationDocumentsDirectory] URLByAppendingPathComponent:kDefaultRecordsPath] withIntermediateDirectories:YES attributes:nil error:nil];
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    NSError *err;
    [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    [audioSession setActive:YES error:&err];
    if (err) {
        NSLog(@"Error set audio session %@", err);
    }
    
    //Force current audio out through speaker
//    UInt32 routeSpeaker = kAudioSessionOverrideAudioRoute_Speaker;
//    AudioSessionSetProperty(kAudioSessionProperty_OverrideCategoryDefaultToSpeaker, sizeof(routeSpeaker), &routeSpeaker);

    NSError *error;
    
    // Recording wav settings
//    NSMutableDictionary *settings = [NSMutableDictionary dictionary];
//    [settings setValue: [NSNumber numberWithInt:kAudioFormatMPEG4AAC] forKey:AVFormatIDKey];
//    [settings setValue: [NSNumber numberWithFloat:8000.0] forKey:AVSampleRateKey];
//    [settings setValue: [NSNumber numberWithInt: 1] forKey:AVNumberOfChannelsKey];
//    [settings setValue: [NSNumber numberWithInt:16] forKey:AVLinearPCMBitDepthKey];
//    [settings setValue: [NSNumber numberWithBool:NO] forKey:AVLinearPCMIsBigEndianKey];
//    [settings setValue: [NSNumber numberWithBool:NO] forKey:AVLinearPCMIsFloatKey];
//    [settings setValue: [NSNumber numberWithInt: AVAudioQualityMin] forKey:AVEncoderAudioQualityKey];
    // Recording m4a settings
    NSDictionary *recordSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [NSNumber numberWithInt: kAudioFormatMPEG4AAC], AVFormatIDKey,
                                    [NSNumber numberWithFloat:16000.0], AVSampleRateKey,
                                    [NSNumber numberWithInt: 1], AVNumberOfChannelsKey,
                                    nil];
    
//    NSString *pathToSave;
//    if (path) {
//        pathToSave = path;
//    } else {
//        pathToSave = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingString:@"/tempRecord.wav"];
//
//    }
//    _writePath = url.path;
//    NSLog(@"write path %@", _writePath);
    
    mayStop = NO;
    // Create recorder
    recorder = [[AVAudioRecorder alloc] initWithURL:url settings:recordSettings error:&error];
    if (error) {
        NSLog(@"Error init recorder %@", error);
        return;
    }
    [recorder prepareToRecord];
    [recorder record];
    [self.delegate audioRecorderDidStartRecord:self];

    [recorder setMeteringEnabled:YES];
    if (_autoPauseRecord) {
        updatePowerSignal = [NSTimer scheduledTimerWithTimeInterval:.5 target:self selector:@selector(updatePowerSignal:) userInfo:nil repeats:YES];
    }
}

- (void)startRecordAtPath:(NSString *)path autoCompletion:(void (^)(NSURL *))completion {
    
    self.autoPauseRecord = YES;
    self.autoStartRecord = NO;
    _callback = completion;
    
    [self startRecordAtPath:path];
}

- (void)continueRecordAtPath:(NSString *)path {
    NSLog(@"continueRecordAtPath %@", path);
}

- (void)updatePowerSignal:(NSTimer*)timer
{
    [recorder updateMeters];
    float power = [recorder peakPowerForChannel:0];
//    NSLog(@"updatePowerSignal %f", power);

    if (power > _threshold && recorder.recording == NO) {
        if (_autoStartRecord) {
            [recorder record];
            [self.delegate audioRecorderDidStartRecord:self];
        }
    } else if (power < _threshold && recorder.recording == YES) {
        if (_autoPauseRecord && _autoStartRecord && mayStop) {
            [recorder stop];
            [self.delegate audioRecorderDidAutoPauseRecord:self];
        } else if (_autoPauseRecord && ! _autoStartRecord && mayStop) {
            [self stopRecord];
            [self.delegate audioRecorderDidAutoStopRecord:self];
            if (_callback) {
                _callback(recorder.url);
            }
        }
            
    } else if (power >_threshold && recorder.recording) {
        mayStop = YES;
    }
}

-(NSURL*)stopRecord
{
    [updatePowerSignal invalidate];
    [recorder stop];
    
    return recorder.url;
}

#pragma mark - Base
- (NSTimeInterval)currentTime {
    return recorder.currentTime;
}
- (float)signalPower {
    // power from ~ -60 to -5 db
    float power = [recorder peakPowerForChannel:0];
    
    return 1.0 - ((-1*power - 5)*2)/100.0;
}

#pragma mark - Utils
- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "FM.CoreData" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

#pragma mark - AudioRecorder Delegate
-(void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag
{
    NSLog(@"audioRecorderDidFinishRecording");
}
@end
