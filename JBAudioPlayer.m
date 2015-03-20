//
//  JBAudioPlayer.m
//  Multiplication Table
//
//  Created by Евгений Богомолов on 06.12.14.
//  Copyright (c) 2014 JustGood. All rights reserved.
//

#import "JBAudioPlayer.h"
#import <AVFoundation/AVFoundation.h>

@interface JBAudioPlayer () <AVAudioPlayerDelegate> {
    AVAudioPlayer           *player;
}
@end

@implementation JBAudioPlayer

@synthesize delegate;
@synthesize queue;
@synthesize speed;

- (instancetype)init
{
    self = [super init];
    queue = [[NSMutableArray alloc] init];
//    self addObserver:queue forKeyPath:arr options:<#(NSKeyValueObservingOptions)#> context:<#(void *)#>
    return self;
}

- (void)playFileAtPath:(NSString *)path
{
//    NSURL *fileURL = [[NSURL alloc] initFileURLWithPath: path];
    NSData *data = [[NSData alloc] initWithContentsOfFile:path];
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
        return;
    }
    
    if (player) {
        [player stop];
    }

    NSError *err;
    player = [[AVAudioPlayer alloc] initWithData:[queue firstObject] error:&err];

    if (err) {
        NSLog(@"Error init file");
    } else {
        if ([player prepareToPlay]) {
            [player setDelegate: self];
            player.enableRate = YES;
            [player setRate:speed];
            [player play];
            NSLog(@"JBAudioPleyer play data %ld", [queue.firstObject length]);
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
@end
