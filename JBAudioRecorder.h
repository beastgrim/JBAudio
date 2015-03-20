//
//  JBAudioRecorder.h
//  Multiplication Table
//
//  Created by Евгений Богомолов on 07.12.14.
//  Copyright (c) 2014 JustGood. All rights reserved.
//

#import <Foundation/Foundation.h>
@class JBAudioRecorder;
@protocol JBAudioRecorderDelegate <NSObject>

- (void) audioRecorderDidAutoPauseRecord:(JBAudioRecorder*)recorder;
- (void) audioRecorderDidStartRecord:(JBAudioRecorder*)recorder;
- (void) audioRecorderDidAutoStopRecord:(JBAudioRecorder*)recorder;

@end

@interface JBAudioRecorder : NSObject

@property (nonatomic, assign)   id<JBAudioRecorderDelegate> delegate;

typedef void (^JBAudioRecorderCallback)(NSURL * completion);

@property (nonatomic, readonly) NSURL       *   defaultUrl;

@property (nonatomic)           float           threshold;
@property (nonatomic)           BOOL            autoPauseRecord;
@property (nonatomic)           BOOL            autoStartRecord;

- (void)startRecordAtPath:(NSString*)path;
- (void)startRecordAtPath:(NSString*)path autoCompletion:(void(^) (NSURL * url))completion;
- (NSURL*)stopRecord;

@end
