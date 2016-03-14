//
//  EVAudioRecorderAutoStopper.h
//  EvaKit
//
//  Created by Yegor Popovych on 8/3/15.
//  Copyright (c) 2015 Evature. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "EVAudioChainOperation.h"
#import "NSError+EVA.h"

#define SAMPLE_RATE  16000

// WebRTC Vad accepts 10ms, 20ms, or 30ms frames
#define VAD_FRAME_TIMESLICE  (0.010f)
#define SAMPLES_PER_VAD_FRAME  ((int)(SAMPLE_RATE * VAD_FRAME_TIMESLICE))


#define EVVadError ERROR_STR_TO_CODE("EVAD")

@protocol EVAutoStopperDelegate;

@interface EVAudioAutoStopper : EVAudioChainOperation

@property (nonatomic, assign) id<EVAutoStopperDelegate> delegate;

@property (nonatomic, assign) NSTimeInterval minNoiseTime;  // must have noise for at least this much time to start considering silence
@property (nonatomic, assign) NSTimeInterval preRecordingTime; // will start listening to noise/silence only after this time
@property (nonatomic, assign) NSTimeInterval levelSampleTime; // time of audio sample for level
@property (nonatomic, assign) NSTimeInterval maxRecordingTime;


// silentStopRecordTime - required consecutive "silent" frames to stop the recording
// this changes linearly from ValueAtT0 to ValueAtT1,
@property (nonatomic, assign) NSTimeInterval silentPeriodValueAtT0; //
@property (nonatomic, assign) NSTimeInterval silentPeriodValueAtT1; // time of silence for record stop
@property (nonatomic, assign) NSTimeInterval timeT0; // time of silence for record stop
@property (nonatomic, assign) NSTimeInterval timeT1; // time of silence for record stop


@property (atomic, assign) NSInteger vadMode;

- (instancetype)initWithDelegate:(id<EVAutoStopperDelegate>) delegate;

- (NSData*)processData:(NSData*)data error:(NSError**)error;
- (void)producerStarted:(EVDataProducer *)producer;

@end


@protocol EVAutoStopperDelegate <EVErrorHandler>

// Provide this for obtaining sound power
- (void)provideCurrentPeakPower:(float*)peakPower andAveragePower:(float*)averagePower;

- (void)stopperTimeStopEvent:(EVAudioChainOperation*)stopper;
- (void)stopperSilenceStopEvent:(EVAudioChainOperation*)stopper stoppedAtFrame:(int)frame;

@optional
- (void)visualizePeakVolumeLevel:(float)peakLevel andAverageVolumeLevel:(float)averageLevel;
@end