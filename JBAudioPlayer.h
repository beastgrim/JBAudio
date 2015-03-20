//
//  JBAudioPlayer.h
//  Multiplication Table
//
//  Created by Евгений Богомолов on 06.12.14.
//  Copyright (c) 2014 JustGood. All rights reserved.
//

#import <Foundation/Foundation.h>

@class JBAudioPlayer;
@protocol JBAudioPlayerDelegate <NSObject>
@optional
-(void)audioPlayerDidFinishPlaying:(JBAudioPlayer*)player;

@end

@interface JBAudioPlayer : NSObject

@property (nonatomic, weak) id<JBAudioPlayerDelegate> delegate;

@property (atomic, retain) NSMutableArray * queue;
@property (nonatomic) float                 speed;

- (void)playFileAtPath:(NSString*)path;
- (void)playFileFromData:(NSData *)data;

@end
