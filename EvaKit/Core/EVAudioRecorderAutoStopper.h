//
//  EVAudioRecorderAutoStopper.h
//  EvaKit
//
//  Created by Yegor Popovych on 8/3/15.
//  Copyright (c) 2015 Evature. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@protocol EVAudioRecorderAutoStopperDelegate;

@interface EVAudioRecorderAutoStopper : NSObject

@property (nonatomic, assign) id<EVAudioRecorderAutoStopperDelegate> delegate;

@property (nonatomic, assign) NSTimeInterval minNoiseTime;  // must have noise for at least this much time to start considering silence
@property (nonatomic, assign) NSTimeInterval preRecordingTime; // will start listening to noise/silence only after this time
@property (nonatomic, assign) NSTimeInterval levelSampleTime; // time of audio sample for level
@property (nonatomic, assign) NSTimeInterval silentStopRecordTime; // time of silence for record stop

- (instancetype)initWithDelegate:(id<EVAudioRecorderAutoStopperDelegate>) delegate;

- (void)startWithMaxTime:(NSTimeInterval)maxTime;
- (void)stop;

@end


@protocol EVAudioRecorderAutoStopperDelegate <NSObject>

// Provide this for obtaining sound power
- (void)currentPeakPower:(float*)peakPower andAveragePower:(float*)averagePower;

- (void)stopperTimeStopEvent:(EVAudioRecorderAutoStopper*)stopper;
- (void)stopperSilenceStopEvent:(EVAudioRecorderAutoStopper*)stopper;

@optional
- (void)stopperVoiceLevelPeak:(float)peakLevel andVoiceLevelAverage:(float)averageLevel;

@end