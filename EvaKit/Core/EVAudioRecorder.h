//
//  EVAudioRecorder.h
//  EvaKit
//
//  Created by Yegor Popovych on 7/30/15.
//  Copyright (c) 2015 Evature. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreAudio/CoreAudioTypes.h>
#import "EVDataProvider.h"
#import "EVAudioRecorderAutoStopper.h"
#import "NSError+EVA.h"

#define EVAudioRecorderCancelledErrorCode ERROR_STR_TO_CODE("EARD")

@class EVAudioRecorder;

@protocol EVAudioRecorderDelegate <NSObject>

- (void)recorderStartedRecording:(EVAudioRecorder*)recorder;
- (void)recorderFinishedRecording:(EVAudioRecorder *)recorder;
- (void)recorder:(EVAudioRecorder*)recorder peakVolumeLevel:(float)peakLevel andAverageVolumeLevel:(float)averageLevel;

@end

@interface EVAudioRecorder : NSObject <EVDataProvider, EVAudioRecorderAutoStopperDelegate>

@property (nonatomic, assign) UInt32 audioBufferSize;

@property (nonatomic, assign) AudioFormatID audioFormat;
@property (nonatomic, assign) AudioFormatFlags audioFormatFlags;
@property (nonatomic, assign) Float64 audioSampleRate;
@property (nonatomic, assign) UInt32 audioNumberOfChannels;
@property (nonatomic, assign) UInt32 audioBitsPerSample;

@property (nonatomic, assign) NSTimeInterval minNoiseTime;  // must have noise for at least this much time to start considering silence
@property (nonatomic, assign) NSTimeInterval preRecordingTime; // will start listening to noise/silence only after this time
@property (nonatomic, assign) NSTimeInterval levelSampleTime; // time of audio sample for level meter
@property (nonatomic, assign) NSTimeInterval silentStopRecordTime; // time of silence for record stop

@property (nonatomic, assign) BOOL isRecording;

@property (nonatomic, assign) id<EVAudioRecorderDelegate> delegate;


- (void)startRecording:(NSTimeInterval)maxRecordingTime;
- (void)startRecording:(NSTimeInterval)maxRecordingTime withAutoStop:(BOOL)autoStop;
- (void)stopRecording;
- (void)cancelRecording;

@end
