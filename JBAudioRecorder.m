//
//  JBAudioRecorder.m
//  Multiplication Table
//
//  Created by Евгений Богомолов on 07.12.14.
//  Copyright (c) 2014 JustGood. All rights reserved.
//

#import "JBAudioRecorder.h"
#import <AVFoundation/AVFoundation.h>

#define kDefaultRecordsPath     @"/records"
#define kDefaultRecordFileName  @"/record"


@interface JBAudioRecorder () <AVAudioRecorderDelegate> {
    AVAudioRecorder         *recorder;
    NSTimer                 *updatePowerSignal;
    BOOL                    mayStop;
}

@end
@implementation JBAudioRecorder

- (instancetype)init
{
    self = [super init];

    [recorder setDelegate:self];

    _autoPauseRecord = NO;
    _autoStartRecord = NO;
    
    return self;
}

- (void)setAutoPauseRecord:(BOOL)autoPauseRecord
{
    NSLog(@"setAutoPauseRecord");
    _autoPauseRecord = autoPauseRecord;
}

- (void)startRecordAtPath:(NSString *)path
{
    NSURL *url;
    if (!path) {
        url = [[[self applicationDocumentsDirectory] URLByAppendingPathComponent:kDefaultRecordsPath] URLByAppendingPathComponent:kDefaultRecordFileName];
    } else {
        url = [NSURL fileURLWithPath:path];
    }
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    NSError *err;
    [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    [audioSession setActive:YES error:&err];
    if (err) {
        NSLog(@"Error set audio session %@", err);
    }
    
    //Force current audio out through speaker
    UInt32 routeSpeaker = kAudioSessionOverrideAudioRoute_Speaker;
    AudioSessionSetProperty(kAudioSessionProperty_OverrideCategoryDefaultToSpeaker, sizeof(routeSpeaker), &routeSpeaker);

    NSError *error;
    
    // Recording settings
    NSMutableDictionary *settings = [NSMutableDictionary dictionary];
    
    [settings setValue: [NSNumber numberWithInt:kAudioFormatLinearPCM] forKey:AVFormatIDKey];
    [settings setValue: [NSNumber numberWithFloat:8000.0] forKey:AVSampleRateKey];
    [settings setValue: [NSNumber numberWithInt: 1] forKey:AVNumberOfChannelsKey];
    [settings setValue: [NSNumber numberWithInt:16] forKey:AVLinearPCMBitDepthKey];
    [settings setValue: [NSNumber numberWithBool:NO] forKey:AVLinearPCMIsBigEndianKey];
    [settings setValue: [NSNumber numberWithBool:NO] forKey:AVLinearPCMIsFloatKey];
    [settings setValue:  [NSNumber numberWithInt: AVAudioQualityMin] forKey:AVEncoderAudioQualityKey];
    
    NSString *pathToSave;
    if (path) {
        pathToSave = path;
    } else {
        pathToSave = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingString:@"/tempRecord.wav"];

    }
    _writePath = url.path;
    
    mayStop = NO;
    // Create recorder
    recorder = [[AVAudioRecorder alloc] initWithURL:url settings:settings error:&error];
    if (error) {
        NSLog(@"Error init recorder");
    }
    [recorder prepareToRecord];
    [recorder record];
    [self.delegate audioRecorderDidStartRecord:self];

    if (_autoPauseRecord) {
        [recorder setMeteringEnabled:YES];
        updatePowerSignal = [NSTimer scheduledTimerWithTimeInterval:.5 target:self selector:@selector(updatePowerSignal:) userInfo:nil repeats:YES];
    }
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
