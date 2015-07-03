//
//  JBAudioPlayer.m
//  Multiplication Table
//
//  Created by Евгений Богомолов on 06.12.14.
//  Copyright (c) 2014 JustGood. All rights reserved.
//

#import "JBAudioPlayer.h"
#import <AVFoundation/AVFoundation.h>

@interface JBAudioPlayer () <AVAudioPlayerDelegate>

@property (nonatomic, strong) AVAudioPlayer           * player;

@end

@implementation JBAudioPlayer

@synthesize player;

@synthesize delegate;
@synthesize queue;
@synthesize speed;

- (instancetype)init
{
    self = [super init];
    queue = [[NSMutableArray alloc] init];
    speed = 1;
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:NULL];
    [audioSession overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:NULL];
    
    return self;
}

#pragma mark - Base
- (NSTimeInterval)prepareFileAtPath:(NSString *)path {
    NSError *err;
    
    NSURL *fileURL = [[NSURL alloc] initFileURLWithPath:path];
    NSData * data = [[NSData alloc] initWithContentsOfURL:fileURL];

    player = [[AVAudioPlayer alloc] initWithData:data error:&err];
    player.delegate = self;
    
    if (err) {
        NSLog(@"Error init file");
    } else {
        if ([player prepareToPlay]) {
            [player setDelegate: self];
            player.enableRate = YES;
            [player setRate:speed];
            NSLog(@"JBAudioPlayer prepare data %ld", [queue.firstObject length]);
        } else {
            NSLog(@"Error prepare file");
            [queue removeObjectAtIndex:0];
            [self playNextAudio];
        }
    }
    self.readyToPlay = YES;
    return player.duration;
}
- (void)play {
    [player play];
}
- (void)playFileAtPath:(NSString *)path
{
    NSURL *fileURL = [[NSURL alloc] initFileURLWithPath:path];
    NSData * data = [[NSData alloc] initWithContentsOfURL:fileURL];
    if (!data) {
        NSLog(@"Error playFileAtPath data = nil");
        return;
    }
    [queue addObject:data];
    
    if (queue.count == 1) {
        [self playNextAudio];
    }
}

- (void)playFileFromData:(NSData *)data
{
    [queue addObject:data];
    
    if (queue.count == 1) {
        [self playNextAudio];
    }
}

- (NSTimeInterval)pause {
    [player pause];
    return player.currentTime;
}

- (void)playAtTime:(NSTimeInterval)time {
    [self seekToTime:time];
    [player play];
}
- (void)seekToTime:(NSTimeInterval)time {
    if (player.isPlaying) {
        [player pause];
    }
    [player setCurrentTime:time];
}
- (NSTimeInterval) currentTime {
    return player.currentTime;
}
- (NSTimeInterval) duration {
    return player.duration;
}
- (void)playNextAudio
{
    if (!queue || !queue.count) {
        [self.delegate audioPlayerDidFinishPlaying:self];
//        NSLog(@"Error playNextAudio, no queue");
        return;
    }
    
    if (player) {
        [player stop];
    }

    NSError *err;
    player = [[AVAudioPlayer alloc] initWithData:[queue firstObject] error:&err];
    player.delegate = self;
    
    if (err) {
        NSLog(@"Error init file");
    } else {
        if ([player prepareToPlay]) {
            [player setDelegate: self];
            player.enableRate = YES;
            [player setRate:speed];
            [player play];
            NSLog(@"JBAudioPlayer play data %ld", [queue.firstObject length]);
        } else {
            NSLog(@"Error play file");
            [queue removeObjectAtIndex:0];
            [self playNextAudio];
        }
    }
}

#pragma mark - AudioPlayer Delegate
-(void)audioPlayerBeginInterruption:(AVAudioPlayer *)player
{
    
}

-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
//    NSLog(@"audioPlayerDidFinishPlaying %d", flag);
    if (queue.count) {
        [queue removeObjectAtIndex:0];
    }
    [self playNextAudio];
}
- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error {
    NSLog(@"audioPlayerDecodeErrorDidOccur %@", error);
}

@end
