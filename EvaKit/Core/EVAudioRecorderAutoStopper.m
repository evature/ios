//
//  EVAudioRecorderAutoStopper.m
//  EvaKit
//
//  Created by Yegor Popovych on 8/3/15.
//  Copyright (c) 2015 Evature. All rights reserved.
//

#import "EVAudioRecorderAutoStopper.h"

@interface EVAudioRecorderAutoStopper () {
    dispatch_source_t _timer;
    double _minVolume;
    double _lowPassResultsPeak;
    unsigned int _silentMoments;
    unsigned int _noisyMoments;
    unsigned int _totalMoments;
    BOOL _startSilenceDetection;
    NSTimeInterval _timeBeforeStop;
}

- (void)calculateData;

@end

@implementation EVAudioRecorderAutoStopper

- (instancetype)initWithDelegate:(id<EVAudioRecorderAutoStopperDelegate>)delegate {
    self = [super init];
    if (self != nil) {
        self.delegate = delegate;
        _timer = nil;
    }
    return self;
}

- (void)startWithMaxTime:(NSTimeInterval)maxTime {
    _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
    NSTimeInterval interval = self.levelSampleTime;
    if (_timer)
    {
        dispatch_source_set_timer(_timer, dispatch_time(DISPATCH_TIME_NOW, interval * NSEC_PER_SEC), interval * NSEC_PER_SEC, (1ull * NSEC_PER_SEC) / 10);
        dispatch_source_set_event_handler(_timer, ^{
            [self calculateData];
        });
        dispatch_resume(_timer);
    }
    _minVolume = DBL_MAX;
    _lowPassResultsPeak = 0.0;
    _silentMoments = 0;
    _startSilenceDetection = NO;
    _totalMoments = 0;
    _noisyMoments = 0;
    _timeBeforeStop = maxTime;
}

- (void)stop {
    if (_timer) {
        dispatch_source_cancel(_timer);
        dispatch_release(_timer);
        _timer = nil;
    }
}

- (void)calculateData {
    _totalMoments++;
    
    _timeBeforeStop -= self.levelSampleTime;
    if (_timeBeforeStop < 0.0) {
        [self.delegate stopperTimeStopEvent:self];
        return;
    }
    
    float peakPower;
    float averagePower;
    [self.delegate currentPeakPower:&peakPower andAveragePower:&averagePower];
    
    double lowPassResults = pow(10, (0.05 * averagePower));
    
    if (lowPassResults < _minVolume) {
        _minVolume = lowPassResults;
    }
    
    if (lowPassResults>_lowPassResultsPeak) { // Take new peak
        _lowPassResultsPeak = lowPassResults;
        _silentMoments = 0;
    }
    
    if([[self delegate] respondsToSelector:@selector(stopperVoiceLevelPeak:andVoiceLevelAverage:)]){
        [[self delegate] stopperVoiceLevelPeak:peakPower andVoiceLevelAverage:averagePower];
    }
    
    if (!_startSilenceDetection && _totalMoments > (self.preRecordingTime/self.levelSampleTime)) {
        if (lowPassResults >  MIN(10*_minVolume, 0.8)) {
            _noisyMoments++;
            if (_noisyMoments >= self.minNoiseTime/self.levelSampleTime) {
                _startSilenceDetection = TRUE;
            }
        } else {
            _noisyMoments = 0;
        }
    }
    
    // not using "else" here because the flag could be just set to true in the previous 'if' block
    if (_startSilenceDetection) {
        if ((lowPassResults-_minVolume) < 0.2*(_lowPassResultsPeak-_minVolume)) {
            _silentMoments++;
        } else {
            _silentMoments = 0;
        }
        if (_silentMoments >= self.silentStopRecordTime/self.levelSampleTime) {
            [self.delegate stopperSilenceStopEvent:self];
        }
    }
}

@end
