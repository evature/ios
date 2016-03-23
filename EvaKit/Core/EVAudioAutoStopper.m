//
//  EVAudioAutoStopper.m
//  EvaKit
//
//

#import "EVAudioAutoStopper.h"
#import "../ThirdParty/webrtc-vad/webrtc/common_audio/vad/include/webrtc_vad.h"
#import "EVLogger.h"



#define LOG_VAD  false



@interface EVAudioAutoStopper () {
    dispatch_source_t _timer;
    double _minVolume;
    double _lowPassResultsPeak;
    unsigned int _silentMoments;
    unsigned int _noisyMoments;
    unsigned int _totalMoments;
    unsigned int _frameDetectedSpeechStart;
    BOOL _startSilenceDetection;
    float silentStopRecordTime;
    BOOL _doneVAD;
    NSTimeInterval _timeBeforeStop;
    int16_t *_leftOverChunk;
    int _leftOverSamples;
    VadInst *_vadHandle;
}


- (void)calculateData;

@end

@implementation EVAudioAutoStopper

- (instancetype)initWithDelegate:(id<EVAutoStopperDelegate>)delegate {
    self = [super initWithName:@"AutoStopper" andErrorHandler:delegate];
    if (self != nil) {
        self.delegate = delegate;
        _timer = nil;
        _leftOverChunk = malloc(sizeof(int16_t) * SAMPLES_PER_VAD_FRAME);
        _leftOverSamples = 0;
        _vadMode = 1;
        _vadHandle = NULL;
        WebRtcVad_Create (&_vadHandle);
        if (_vadHandle == NULL) {
            [self.errorHandler node:self gotAnError:[NSError errorWithCode:EVVadError andDescription:@"Can't create VAD"]];
        }
        int err = WebRtcVad_ValidRateAndFrameLength(SAMPLE_RATE, SAMPLES_PER_VAD_FRAME);
        if (err) {
            [self.errorHandler node:self gotAnError:[NSError errorWithCode:EVVadError andDescription:@"Bad VAD frame - must be 10/20/30ms long"]];
        }
    }
    return self;
}


- (void)cancel {
    [super cancel];
    if (_timer) {
        dispatch_source_cancel(_timer);
        dispatch_release(_timer);
        _timer = nil;
    }
}

-(void)producerFinished:(EVDataProducer*)producer {
    if (_timer) {
        dispatch_source_cancel(_timer);
        dispatch_release(_timer);
        _timer = nil;
    }
    [super producerFinished:producer];
}

-(void)dealloc {
    if (_timer) {
        dispatch_source_cancel(_timer);
        dispatch_release(_timer);
        _timer = nil;
    }
     WebRtcVad_Free (_vadHandle);
    free(_leftOverChunk);
    _leftOverChunk = nil;
    [super dealloc];
}

-(void)producerStarted:(EVDataProducer*)producer {
#if LOG_VAD
    EV_LOG_DEBUG(@"> > > VAD INIT T0=%f  T1=%f  V0=%f  V1=%f  mode=%lu", _timeT0, _timeT1, _silentPeriodValueAtT0, _silentPeriodValueAtT1,  (long) _vadMode);
#endif
    int err = WebRtcVad_Init(_vadHandle);
    if (err) {
        [self.errorHandler node:self gotAnError:[NSError errorWithCode:EVVadError andDescription:@"Can't initialize VAD"]];
        return;
    }
    err = WebRtcVad_set_mode(_vadHandle, (int)_vadMode);
    if (err) {
        [self.errorHandler node:self gotAnError:[NSError errorWithCode:EVVadError andDescription:@"Failed setting VAD Aggressive mode"]];
        return;
    }
    silentStopRecordTime = 0;
    NSTimeInterval interval = self.levelSampleTime;
    if (interval > 0) {
        _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
        if (_timer)
        {
            dispatch_source_set_timer(_timer, dispatch_time(DISPATCH_TIME_NOW, interval * NSEC_PER_SEC), interval * NSEC_PER_SEC, (1ull * NSEC_PER_SEC) / 10);
            dispatch_source_set_event_handler(_timer, ^{
                [self calculateData];
            });
            dispatch_resume(_timer);
        }
    }
    _minVolume = DBL_MAX;
    _lowPassResultsPeak = 0.0;
    _silentMoments = 0;
    _startSilenceDetection = NO;
    _totalMoments = 0;
    _noisyMoments = 0;
    _doneVAD = NO;
    _timeBeforeStop = self.maxRecordingTime;
    [super producerStarted:producer];
}

- (void)processVADChunk:(int16_t*)chunk {
    if (_doneVAD) {
        return;
    }
    _totalMoments++;
    
    int vad = WebRtcVad_Process (_vadHandle, 16000, chunk, SAMPLES_PER_VAD_FRAME);
#if LOG_VAD
    EV_LOG_DEBUG(@">>>>>>>> VAD %d: %@    noise=%d, silence=%d,  silenceNeeded=%f", _totalMoments, vad ? @"SPEECH!" : @"silence",  _noisyMoments, _silentMoments, silentStopRecordTime );
        
        if (_totalMoments > (self.preRecordingTime/VAD_FRAME_TIMESLICE) && _totalMoments <= 1+(self.preRecordingTime/VAD_FRAME_TIMESLICE)) {
            EV_LOG_DEBUG(@"> > > > Waited enough time from start, looking for speech!");
        }
#endif
    
    if (!_startSilenceDetection && _totalMoments > (self.preRecordingTime/VAD_FRAME_TIMESLICE)) {
        if (vad) {
            _noisyMoments++;
            if (_noisyMoments >= self.minNoiseTime/VAD_FRAME_TIMESLICE) {
                _startSilenceDetection = TRUE;
                _frameDetectedSpeechStart = _totalMoments;
#if LOG_VAD
                    EV_LOG_DEBUG(@"> > > > Found enough consecutive speech! looking for silence");
#endif
            }
        } else {
            _noisyMoments = 0;
        }
    }
    
    // not using "else" here because the flag could be just set to true in the previous 'if' block
    if (_startSilenceDetection) {
        if (vad) {
            _noisyMoments++;
            _silentMoments = 0;
            if (_noisyMoments > 3) {
                _frameDetectedSpeechStart = _totalMoments;
            }
        } else {
            _noisyMoments = 0;
            _silentMoments++;
            float curTime = (_totalMoments- _frameDetectedSpeechStart) * VAD_FRAME_TIMESLICE;
            if (curTime < _timeT0) {
                silentStopRecordTime = _silentPeriodValueAtT0;
            }
            else if (curTime > _timeT1) {
                silentStopRecordTime = _silentPeriodValueAtT1;
            }
            else {
                // linear from T0 to T1
                silentStopRecordTime = _silentPeriodValueAtT0 + (_silentPeriodValueAtT1 - _silentPeriodValueAtT0) * (curTime - _timeT0) / (_timeT1 - _timeT0);
            }
            
            if (_silentMoments >= silentStopRecordTime/VAD_FRAME_TIMESLICE) {
                _doneVAD = true;
#if LOG_VAD
                EV_LOG_DEBUG(@"> > > > Found enough consecutive silence! done with VAD!");
#endif
                [self.delegate stopperSilenceStopEvent:self stoppedAtFrame:_totalMoments];
            }
        }
        
    }
}


- (NSData*)processData:(NSData*)data error:(NSError**)error {
    if (_doneVAD) {
#if LOG_VAD
        EV_LOG_DEBUG(@"> > > > Continued to get data after VAD is done - data of size %lu", (unsigned long)[data length]);
#endif
        return nil;
    }
//    int8_t* dataBytes = (int8_t*)[data bytes];
//    int16_t *buffer = (int16_t*)malloc([data length]);
//    // convert data endianess
//    unsigned int i;
//    for(i = 0; i < [data length];) {
//        /* inefficient but simple and works on big- or little-endian machines */
//        buffer[i] = (((int16_t)(int8_t)dataBytes[i + 1] << 8) | (int16_t)dataBytes[i]);
//        i += 2;
//    }
    int16_t *buffer = (int16_t*)[data bytes];
    
    
    // WebRTC Vad expects chunks of 160 samples,  1 channel, 16bits signed per sample

    NSUInteger samplesLeft = [data length]/sizeof(int16_t);
    int16_t* buf = buffer;
    
    if (_leftOverSamples > 0) {
        int samplesToFill = SAMPLES_PER_VAD_FRAME - _leftOverSamples;
        memcpy(_leftOverChunk+_leftOverSamples, buf, sizeof(int16_t)*samplesToFill);
        [self processVADChunk:_leftOverChunk];
        _leftOverSamples = 0;
        buf += samplesToFill;
        samplesLeft -= samplesToFill;
    }
    while (samplesLeft > SAMPLES_PER_VAD_FRAME) {
        [self processVADChunk:buf];
        buf += SAMPLES_PER_VAD_FRAME;
        samplesLeft -= SAMPLES_PER_VAD_FRAME;
    }
    _leftOverSamples = (int)samplesLeft;
    memcpy(_leftOverChunk, buf, sizeof(int16_t)*_leftOverSamples);
    
//    NSData *result = [NSData dataWithBytes:buffer length:[data length]];
//    free(buffer);
//    return result;
    return data;
}

- (void)calculateData {
    if (_doneVAD) {
        return;
    }
    
    _timeBeforeStop -= self.levelSampleTime;
    if (_timeBeforeStop < 0.0) {
        [self.delegate stopperTimeStopEvent:self];
        return;
    }
    
    float peakPower;
    float averagePower;
    [self.delegate provideCurrentPeakPower:&peakPower andAveragePower:&averagePower];
    /*
    double lowPassResults = pow(10, (0.05 * averagePower));
    
    if (lowPassResults < _minVolume) {
        _minVolume = lowPassResults;
    }
    
    if (lowPassResults>_lowPassResultsPeak) { // Take new peak
        _lowPassResultsPeak = lowPassResults;
        _silentMoments = 0;
    }*/
    
    if([[self delegate] respondsToSelector:@selector(visualizePeakVolumeLevel:andAverageVolumeLevel:)]){
        [[self delegate] visualizePeakVolumeLevel:peakPower andAverageVolumeLevel:averagePower];
    }
    
    
    /*
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
    } */
}

@end
