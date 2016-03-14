//
//  EVAudioRecorder.h
//  EvaKit
//
//  Created by Yegor Popovych on 7/30/15.
//  Copyright (c) 2015 Evature. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreAudio/CoreAudioTypes.h>
#import "EVDataProducer.h"
#import "NSError+EVA.h"


@class EVAudioRecorder;

@protocol EVAudioRecorderDelegate <NSObject>

- (void)recorderStartedRecording:(EVAudioRecorder*)recorder;

@end

@interface EVAudioRecorder : EVDataProducer

@property (nonatomic, assign) UInt32 audioBufferSize;

@property (nonatomic, assign) AudioFormatID audioFormat;
@property (nonatomic, assign) AudioFormatFlags audioFormatFlags;
@property (nonatomic, assign) Float64 audioSampleRate;
@property (nonatomic, assign) UInt32 audioNumberOfChannels;
@property (nonatomic, assign) UInt32 audioBitsPerSample;


@property (nonatomic, assign) BOOL isRecording;


@property (nonatomic, assign) id<EVAudioRecorderDelegate> delegate;

- (id)initWithErrorHandler:(id<EVErrorHandler>)errorHandler;
- (void)startRecordingWithAutoStop:(BOOL)autoStop;
- (void)stopRecording;
- (void)provideCurrentPeakPower:(float*)peakPower andAveragePower:(float*)averagePower;
@end
