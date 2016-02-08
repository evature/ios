//
//  EVAudioRecorder.m
//  EvaKit
//
//  Created by Yegor Popovych on 7/30/15.
//  Copyright (c) 2015 Evature. All rights reserved.
//

#import "EVAudioRecorder.h"
#import <dispatch/dispatch.h>
#import <AVFoundation/AVFoundation.h>
#import "NSError+EVA.h"
#import "EVLogger.h"
#import "EVApplication.h"


@interface EVAudioRecorder () {
    AudioQueueRef _audioQueue;
    AudioQueueBufferRef _audioBuffer;
    BOOL _autoStop;
}

@property (nonatomic, strong) EVAudioRecorderAutoStopper* autoStopper;

- (AudioStreamBasicDescription)audioFormatDescription;
- (BOOL)startAudioQueue:(AudioStreamBasicDescription)format;
- (void)stopAudioQueue;
- (void)stopRecordingNoDelegate;

@end

void AudioInputCallback(void* inUserData, AudioQueueRef inAQ, AudioQueueBufferRef inBuffer, const AudioTimeStamp* inStartTime,UInt32 inNumberPacketDescriptions, const AudioStreamPacketDescription *inPacketDescs) {
    EVAudioRecorder* recorder = (EVAudioRecorder*)inUserData;
    if (inNumberPacketDescriptions > 0) {
        NSData* data = [NSData dataWithBytes:inBuffer->mAudioData length:inBuffer->mAudioDataByteSize];
        [recorder.dataProviderDelegate provider:recorder hasNewData:data];
    }
    AudioQueueEnqueueBuffer(inAQ, inBuffer, 0, NULL);
}

@implementation EVAudioRecorder

@synthesize dataProviderDelegate;
@dynamic minNoiseTime;
@dynamic preRecordingTime;
@dynamic levelSampleTime;
@dynamic silentStopRecordTime;

- (id)init {
    self = [super init];
    if (self != nil) {
        _audioQueue = nil;
        _audioBuffer = nil;
        self.audioBufferSize = 0; //Set default buffer
        self.autoStopper = [[[EVAudioRecorderAutoStopper alloc] initWithDelegate:self] autorelease];
        [self setAVSessionWithRecord:NO];
    }
    return self;
}

- (void)dealloc {
    [self setAVSessionWithRecord:NO];
    self.autoStopper = nil;
    [self stopAudioQueue];
    [super dealloc];
}

- (AudioStreamBasicDescription)audioFormatDescription {
    AudioStreamBasicDescription audioFormat;
    audioFormat.mFormatID         = self.audioFormat;
    audioFormat.mSampleRate       = self.audioSampleRate;
    audioFormat.mChannelsPerFrame = self.audioNumberOfChannels;
    audioFormat.mBitsPerChannel   = self.audioBitsPerSample;
    audioFormat.mFramesPerPacket  = 1;
    audioFormat.mBytesPerFrame    = audioFormat.mChannelsPerFrame * audioFormat.mBitsPerChannel/8;
    audioFormat.mBytesPerPacket   = audioFormat.mBytesPerFrame * audioFormat.mFramesPerPacket;
    audioFormat.mFormatFlags      = self.audioFormatFlags;
    return audioFormat;
}

- (void)setAudioBufferSize:(UInt32)audioBufferSize {
    audioBufferSize = audioBufferSize > 32768 ? audioBufferSize : 32768; //32Kb buffer
    _audioBufferSize = audioBufferSize;
}

- (void)startRecording:(NSTimeInterval)maxRecordingTime {
    [self startRecording:maxRecordingTime withAutoStop:YES];
}

/*
 - (void)setAVSession {
     EV_LOG_DEBUG(@"Setting session to Play and Record");
     AVAudioSession *session = [AVAudioSession sharedInstance];
     NSError *error = nil;
 
     [session setCategory:AVAudioSessionCategoryPlayAndRecord withOptions:AVAudioSessionCategoryOptionDefaultToSpeaker | AVAudioSessionCategoryOptionAllowBluetooth error:&error];
     if (error != nil) {
         EV_LOG_ERROR(@"Failed to setCategory for AVAudioSession! %@", error);
     }
     [session setMode:AVAudioSessionModeVoiceChat error:&error];
     if (error != nil) {
         EV_LOG_ERROR(@"Failed to setMode for AVAudioSession! %@", error);
     }
     [session overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:&error];
     if (error != nil) {
         EV_LOG_ERROR(@"Failed to override output for AVAudioSession! %@", error);
     }
 }
*/


- (void)setAVSessionWithRecord:(BOOL)isRecord {
    AVAudioSession *session = [AVAudioSession sharedInstance];
    NSError *error = nil;
    if (isRecord) {
        EV_LOG_DEBUG(@"Setting session to Record");
        
        [session setCategory:AVAudioSessionCategoryRecord withOptions:AVAudioSessionCategoryOptionAllowBluetooth error:&error];
        if (error != nil) {
            EV_LOG_ERROR(@"Failed to setCategory for AVAudioSession! %@", error);
        }
    }
    else {
        EV_LOG_DEBUG(@"Setting session to PlayAndRecord");
        [session setCategory:AVAudioSessionCategoryPlayAndRecord  withOptions:AVAudioSessionCategoryOptionDefaultToSpeaker | AVAudioSessionCategoryOptionAllowBluetooth error:&error];
        if (error != nil) {
            EV_LOG_ERROR(@"Failed to setCategory for AVAudioSession! %@", error);
        }
    }
}


- (void)startRecording:(NSTimeInterval)maxRecordingTime withAutoStop:(BOOL)autoStop {
    if (!self.isRecording) {
        _autoStop = autoStop;
        NSError* error = nil;
        [self setAVSessionWithRecord:YES];
        [[AVAudioSession sharedInstance] setActive:YES error:&error];
        if (error != nil) {
            EV_LOG_ERROR(@"Failed to setActive:YES for AVAudioSession! %@", error);
            [self.dataProviderDelegate provider:self gotAnError:error];
        }
        if ([self startAudioQueue:[self audioFormatDescription]]) {
            self.isRecording = YES;
            [self.dataProviderDelegate providerStarted:self];
            [self.autoStopper startWithMaxTime:maxRecordingTime];
            [self.delegate recorderStartedRecording:self];
        }
    }
}

- (void)stopRecordingNoDelegate {
    [self.autoStopper stop];
    [self stopAudioQueue];
//    NSError* error = nil;
//    [[AVAudioSession sharedInstance] setActive:NO error:&error];
//    if (error != nil) {
//        EV_LOG_ERROR(@"Failed to setActive:NO for AVAudioSession! %@", error);
//        [self.dataProviderDelegate provider:self gotAnError:error];
//    }
    [self setAVSessionWithRecord:NO];
    self.isRecording = NO;
    [self.dataProviderDelegate providerFinished:self];
}

- (void)stopRecording {
    [self stopRecordingNoDelegate];
    [self.delegate recorderFinishedRecording:self];
}

- (void)cancelRecording {
    [self.dataProviderDelegate provider:self gotAnError:[NSError errorWithCode:EVAudioRecorderCancelledErrorCode andDescription:@"Cancelled"]];
    [self stopRecordingNoDelegate];
}

- (BOOL)startAudioQueue:(AudioStreamBasicDescription)format {
    OSStatus result = AudioQueueNewInput(&format, AudioInputCallback, self, CFRunLoopGetMain(), NULL, 0, &_audioQueue);
    if (result != 0) {
        EV_LOG_ERROR(@"ERROR: Error %d on AudioQueueNewInput", (int)result);
        [self.dataProviderDelegate provider:self gotAnError:[NSError errorWithCode:result andDescription:@"ERROR: Error on AudioQueueNewInput"]];
        return NO;
    }
    
    UInt32 trueValue = true;
    AudioQueueSetProperty(_audioQueue, kAudioQueueProperty_EnableLevelMetering, &trueValue, sizeof (UInt32));
    
    result = AudioQueueAllocateBuffer(_audioQueue, self.audioBufferSize, &_audioBuffer);
    if (result != 0) {
        EV_LOG_ERROR(@"ERROR: Error %d on AudioQueueAllocateBuffer", (int)result);
        [self.dataProviderDelegate provider:self gotAnError:[NSError errorWithCode:result andDescription:@"ERROR: Error on AudioQueueAllocateBuffer"]];
        [self stopAudioQueue];
        return NO;
    }
    result = AudioQueueEnqueueBuffer(_audioQueue, _audioBuffer, 0, NULL);
    if (result != 0) {
        AudioQueueFreeBuffer(_audioQueue, _audioBuffer);
        [self stopAudioQueue];
        EV_LOG_ERROR(@"ERROR: Error %d on AudioQueueEnqueueBuffer", (int)result);
        [self.dataProviderDelegate provider:self gotAnError:[NSError errorWithCode:result andDescription:@"ERROR: Error on AudioQueueEnqueueBuffer"]];
        return NO;
    }
    result = AudioQueueStart(_audioQueue, NULL);
    if (result != 0) {
        EV_LOG_ERROR(@"ERROR: Error %d on AudioQueueStart", (int)result);
        [self.dataProviderDelegate provider:self gotAnError:[NSError errorWithCode:result andDescription:@"ERROR: Error on AudioQueueStart"]];
        [self stopAudioQueue];
        return NO;
    }
    return YES;
}

- (void)stopAudioQueue {
    if (_audioQueue != nil) {
        AudioQueueStop(_audioQueue, true);
        AudioQueueDispose(_audioQueue, false);
        _audioQueue = nil;
        _audioBuffer = nil;
    }
}

- (void)stopDataProvider {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self stopRecordingNoDelegate];
    });
}

#pragma mark ==== Audio Stopper Delegate

- (void)stopperSilenceStopEvent:(EVAudioRecorderAutoStopper*)stopper {
    if (_autoStop) {
        [self stopRecording];
    }
}

- (void)stopperTimeStopEvent:(EVAudioRecorderAutoStopper *)stopper {
    [self stopRecording];
}

- (void)currentPeakPower:(float*)peakPower andAveragePower:(float*)averagePower {
    *peakPower = -150.0f;
    *averagePower = 0.0f;
    
    UInt32 dataSize = sizeof(AudioQueueLevelMeterState) * self.audioNumberOfChannels;
    AudioQueueLevelMeterState *levels = (AudioQueueLevelMeterState*)malloc(dataSize);
    OSStatus rc = AudioQueueGetProperty(_audioQueue, kAudioQueueProperty_CurrentLevelMeterDB, levels, &dataSize);
    
    if (rc == 0) {
        *peakPower = levels[0].mPeakPower;
        *averagePower = levels[0].mAveragePower;
    }
    
    free(levels);
}

- (void)stopperVoiceLevelPeak:(float)peakLevel andVoiceLevelAverage:(float)averageLevel {
    if (self.delegate != nil) {
        [self.delegate recorder:self peakVolumeLevel:peakLevel andAverageVolumeLevel:averageLevel];
    }
}

#pragma mark === Audio Stopper Properties ===

- (NSTimeInterval)minNoiseTime {
    return self.autoStopper.minNoiseTime;
}

- (void)setMinNoiseTime:(NSTimeInterval)minNoiseTime {
    self.autoStopper.minNoiseTime = minNoiseTime;
}

- (NSTimeInterval)preRecordingTime {
    return self.autoStopper.preRecordingTime;
}

- (void)setPreRecordingTime:(NSTimeInterval)preRecordingTime {
    self.autoStopper.preRecordingTime = preRecordingTime;
}

- (NSTimeInterval)levelSampleTime {
    return self.autoStopper.levelSampleTime;
}

- (void)setLevelSampleTime:(NSTimeInterval)levelSampleTime {
    self.autoStopper.levelSampleTime = levelSampleTime;
}

- (NSTimeInterval)silentStopRecordTime {
    return self.autoStopper.silentStopRecordTime;
}

- (void)setSilentStopRecordTime:(NSTimeInterval)silentStopRecordTime {
    self.autoStopper.silentStopRecordTime = silentStopRecordTime;
}

@end
