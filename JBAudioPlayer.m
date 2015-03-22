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
    
    return self;
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
    [queue removeObjectAtIndex:0];
    [self playNextAudio];
}
- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error {
    NSLog(@"audioPlayerDecodeErrorDidOccur %@", error);
}

@end
