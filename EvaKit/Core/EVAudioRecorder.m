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

//#define MIN_BUFFER_SIZE 32768
#define MIN_BUFFER_SIZE 8000

@interface EVAudioRecorder () {
    AudioQueueRef _audioQueue;
    AudioQueueBufferRef _audioBuffer;
    BOOL _autoStop;
    dispatch_source_t _timer;
}


- (AudioStreamBasicDescription)audioFormatDescription;
- (BOOL)startAudioQueue:(AudioStreamBasicDescription)format;
- (void)stopAudioQueue;

@end

void AudioInputCallback(void* inUserData, AudioQueueRef inAQ, AudioQueueBufferRef inBuffer, const AudioTimeStamp* inStartTime,UInt32 inNumberPacketDescriptions, const AudioStreamPacketDescription *inPacketDescs) {
    EVAudioRecorder* recorder = (EVAudioRecorder*)inUserData;
    if (inNumberPacketDescriptions > 0) {
        NSData* data = [NSData dataWithBytes:inBuffer->mAudioData length:inBuffer->mAudioDataByteSize];
        [recorder propagateHasNewData:data];
    }
    AudioQueueEnqueueBuffer(inAQ, inBuffer, 0, NULL);
}

@implementation EVAudioRecorder


- (id)initWithErrorHandler:(id<EVErrorHandler>)errorHandler {
    self = [super initWithOperationChainLength:30 andName:@"AudioRecorder" andErrorHandler:errorHandler];
    if (self != nil) {
        _audioQueue = nil;
        _audioBuffer = nil;
        _timer = nil;
        self.audioBufferSize = 0; //Set default buffer
        [self setAVSessionWithRecord:NO];
    }
    return self;
}

- (void)dealloc {
    [self setAVSessionWithRecord:NO];
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
    audioBufferSize = audioBufferSize > MIN_BUFFER_SIZE ? audioBufferSize : MIN_BUFFER_SIZE;
    _audioBufferSize = audioBufferSize;
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
            EV_LOG_ERROR(@"Failed to setCategory AVAudioSessionCategoryRecord for AVAudioSession! %@", error);
            [self.errorHandler node:self gotAnError:error];
        }
    }
    else {
        EV_LOG_DEBUG(@"Setting session to PlayAndRecord");
        [session setCategory:AVAudioSessionCategoryPlayAndRecord  withOptions:AVAudioSessionCategoryOptionDefaultToSpeaker | AVAudioSessionCategoryOptionAllowBluetooth error:&error];
        if (error != nil) {
            EV_LOG_ERROR(@"Failed to setCategory AVAudioSessionCategoryPlayAndRecord for AVAudioSession! %@", error);
            [self.errorHandler node:self gotAnError:error];
        }
    }
}


- (void)startRecordingWithAutoStop:(BOOL)autoStop {
    if (!self.isRecording) {
        _autoStop = autoStop;
        //// @@@@@@@@@@@@
        NSError* error = nil;
        [self setAVSessionWithRecord:YES];
        [[AVAudioSession sharedInstance] setActive:YES error:&error];
        if (error != nil) {
            EV_LOG_ERROR(@"Failed to setActive:YES for AVAudioSession! %@", error);
            [self.errorHandler node:self gotAnError:error];
        }
        if ([self startAudioQueue:[self audioFormatDescription]]) {
            self.isRecording = YES;
            [self propagateProducerStarted];
            [self.delegate recorderStartedRecording:self];
            EV_LOG_INFO(@"Started to record");
        }
        
        /// @@@@@@@@@@@
//        self.isRecording = YES;
//        [self propagateProducerStarted];
//        [self.delegate recorderStartedRecording:self];
//        EV_LOG_INFO(@"Started to record");
//        _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
//        NSTimeInterval interval = 0.05; //  should be 0.25 because 8000 bytes = 4000 samples = 0.25 second,   but made x5 faster to save time
//        if (_timer)
//        {
//            FILE *fp = fopen([[[NSBundle bundleForClass:[self class]] pathForResource:@"white_noise_test" ofType:@"raw"] UTF8String], "r");
//            dispatch_source_set_timer(_timer, dispatch_time(DISPATCH_TIME_NOW, interval * NSEC_PER_SEC), interval * NSEC_PER_SEC, (1ull * NSEC_PER_SEC) / 10);
//            dispatch_source_set_event_handler(_timer, ^{
//                int NN = 800;
//                short buf[NN];
//                fread (buf, 1, NN, fp);
//                if (feof (fp)) {
//                    [self stopRecording];
//                }
//                else {
//                    NSData* data = [NSData dataWithBytes:buf length:NN];
//                    [self propagateHasNewData:data];
//                }
//            });
//            dispatch_resume(_timer);
//        }

    }
}

- (void)stopRecording {
    //@@@@@@@@@@@
    [self stopAudioQueue];
    if (_timer) {
        dispatch_source_cancel(_timer);
        dispatch_release(_timer);
        _timer = nil;
    }
    
    //    NSError* error = nil;
//    [[AVAudioSession sharedInstance] setActive:NO error:&error];
//    if (error != nil) {
//        EV_LOG_ERROR(@"Failed to setActive:NO for AVAudioSession! %@", error);
//        [self.dataProviderDelegate provider:self gotAnError:error];
//    }
    [self setAVSessionWithRecord:NO];
    self.isRecording = NO;
    [self propagateProducerFinished];
}



- (BOOL)startAudioQueue:(AudioStreamBasicDescription)format {
    OSStatus result = AudioQueueNewInput(&format, AudioInputCallback, self, CFRunLoopGetMain(), NULL, 0, &_audioQueue);
    if (result != 0) {
        EV_LOG_ERROR(@"ERROR: Error %d on AudioQueueNewInput", (int)result);
        [self.errorHandler node:self gotAnError:[NSError errorWithCode:result andDescription:@"ERROR: Error on AudioQueueNewInput"]];
        return NO;
    }
    
    UInt32 trueValue = true;
    AudioQueueSetProperty(_audioQueue, kAudioQueueProperty_EnableLevelMetering, &trueValue, sizeof (UInt32));
    
    result = AudioQueueAllocateBuffer(_audioQueue, self.audioBufferSize, &_audioBuffer);
    if (result != 0) {
        EV_LOG_ERROR(@"ERROR: Error %d on AudioQueueAllocateBuffer", (int)result);
        [self.errorHandler node:self gotAnError:[NSError errorWithCode:result andDescription:@"ERROR: Error on AudioQueueAllocateBuffer"]];
        [self stopAudioQueue];
        return NO;
    }
    result = AudioQueueEnqueueBuffer(_audioQueue, _audioBuffer, 0, NULL);
    if (result != 0) {
        AudioQueueFreeBuffer(_audioQueue, _audioBuffer);
        [self stopAudioQueue];
        EV_LOG_ERROR(@"ERROR: Error %d on AudioQueueEnqueueBuffer", (int)result);
        [self.errorHandler node:self gotAnError:[NSError errorWithCode:result andDescription:@"ERROR: Error on AudioQueueEnqueueBuffer"]];
        return NO;
    }
    result = AudioQueueStart(_audioQueue, NULL);
    if (result != 0) {
        EV_LOG_ERROR(@"ERROR: Error %d on AudioQueueStart", (int)result);
        [self.errorHandler node:self gotAnError:[NSError errorWithCode:result andDescription:@"ERROR: Error on AudioQueueStart"]];
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


- (void)cancel {
   // dispatch_async(dispatch_get_main_queue(), ^{
    [super cancel];
    [self stopRecording];
   // });
}

#pragma mark ==== Audio Stopper Delegate

- (void)provideCurrentPeakPower:(float*)peakPower andAveragePower:(float*)averagePower {
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



@end
