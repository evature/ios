//
//  EVAudioConvertionOperation.m
//  EvaKit
//
//  Created by Yegor Popovych on 7/31/15.
//  Copyright (c) 2015 Evature. All rights reserved.
//

#import "EVAudioConvertionOperation.h"
#import <libFlac/libFlac.h>
#import "NSError+EVA.h"
#import "EVLogger.h"
#include <CoreFoundation/CFByteOrder.h>



@interface EVAudioConvertionOperation () {
    FLAC__StreamEncoder *_encoder;
    FLAC__int32 *_flacBuffer;
    BOOL _finished;
}

@property (nonatomic, strong) NSMutableData* currentEncodedData;

@end

FLAC__StreamEncoderWriteStatus part_encoded(const FLAC__StreamEncoder *encoder, const FLAC__byte buffer[], size_t bytes, unsigned samples, unsigned current_frame, void *client_data) {
    EVAudioConvertionOperation* op = (EVAudioConvertionOperation*)client_data;
    
    [op.currentEncodedData appendBytes:buffer length:bytes];
    
    return FLAC__STREAM_ENCODER_WRITE_STATUS_OK;
}

@implementation EVAudioConvertionOperation

- (id)initWithErrorHandler:(id<EVErrorHandler>)errorHandler {
    self = [super initWithOperationChainLength:20 andName:@"AudioConversion" andErrorHandler:errorHandler];
    if (self != nil) {
        self.numberOfChannels = 1;
        self.currentEncodedData = nil;
        [self setFlacBufferMaxSamples:0]; //Init default buffer
    }
    return self;
}

- (void)dealloc {
    self.currentEncodedData = nil;
    if (_encoder != NULL) FLAC__stream_encoder_delete(_encoder);
    if (_flacBuffer != NULL) free(_flacBuffer);
    [super dealloc];
}

- (void)setFlacBufferMaxSamples:(unsigned int)flacBufferMaxSamples {
    dispatch_sync(self.operationQueue, ^{
        unsigned int newSize = flacBufferMaxSamples > 32000 ? flacBufferMaxSamples : 32000; //32000 samples min
        if (_flacBufferMaxSamples != newSize) {
            if (_flacBuffer != NULL) free(_flacBuffer);
            _flacBuffer = malloc(sizeof(FLAC__int32)*self.numberOfChannels*newSize);
        }
        _flacBufferMaxSamples = newSize;
    });
}

- (void)producerStarted:(EVDataProducer*)producer {
    [super producerStarted:producer];
    
    _finished = NO;
    
//    dispatch_async(self.operationQueue, ^{
        _encoder = FLAC__stream_encoder_new();
        self.currentEncodedData = [NSMutableData new];
        [self.currentEncodedData release];
        
        FLAC__stream_encoder_set_verify(_encoder, ([EVLogger logger].logLevel == EVLoggerLogLevelDebug));
        FLAC__stream_encoder_set_compression_level(_encoder, 5);
        FLAC__stream_encoder_set_channels(_encoder, self.numberOfChannels);
        FLAC__stream_encoder_set_bits_per_sample(_encoder, self.bitsPerSample);
        FLAC__stream_encoder_set_sample_rate(_encoder, self.sampleRate);
        FLAC__stream_encoder_set_total_samples_estimate(_encoder, self.sampleRate * self.maxRecordingTime);
        FLAC__stream_encoder_set_blocksize(_encoder, 0);
        FLAC__StreamEncoderInitStatus init_status = FLAC__stream_encoder_init_stream(_encoder, part_encoded, NULL,NULL,NULL, (void*)self);
        
        if (init_status != FLAC__STREAM_ENCODER_INIT_STATUS_OK) {
            EV_LOG_ERROR(@"ERROR: FLAC Failed to initialize encoder: %s", FLAC__StreamEncoderInitStatusString[init_status]);
            [self.errorHandler node:self gotAnError:[NSError errorWithCode:init_status andDescription:[NSString stringWithUTF8String:FLAC__StreamEncoderInitStatusString[init_status]]]];
            self.currentEncodedData = nil;
        } else {
            if ([self.currentEncodedData length] > 0) {
                [self propagateHasNewData:[NSData dataWithData:self.currentEncodedData]];
                [self.currentEncodedData setLength:0];
            }
        }
    //});

}

- (void)producerFinished:(EVDataProducer*)producer {
//    dispatch_sync(self.operationQueue, ^{
    _finished = YES;
        if (_encoder != NULL) {
            FLAC__stream_encoder_finish(_encoder);
            if ([self.currentEncodedData length] > 0) {
                [self propagateHasNewData:[NSData dataWithData:self.currentEncodedData]];
            }
            FLAC__stream_encoder_delete(_encoder);
            _encoder = NULL;
        }
        self.currentEncodedData = nil;
        
//    });
    [super producerFinished:producer];
}

- (void)cancel {
    [super cancel];
    _finished = YES;
    FLAC__stream_encoder_delete(_encoder);
    _encoder = NULL;
    
}

- (NSData*)processData:(NSData*)data error:(NSError**)error {
    if (_finished) {
        EV_LOG_INFO(@"Encoder asked to process data after finished");
        return nil;
    }
    EV_LOG_DEBUG(@"Audio Conversion new data of length %lu", (unsigned long)[data length]);
    FLAC__bool ok = true;
    unsigned int samplesLeft = (unsigned)([data length] / (self.numberOfChannels * self.bitsPerSample / 8)); //Calculate number of samples in data
    const uint8_t* buffer = [data bytes];
    uint offset = 0;
    while(ok && samplesLeft) {
        unsigned int samples = samplesLeft > _flacBufferMaxSamples ? _flacBufferMaxSamples : samplesLeft;
        
        unsigned int i;
        if (CFByteOrderGetCurrent() != OSLittleEndian) {
            for(i = 0; i < samples * self.numberOfChannels; i++) {
                /* inefficient but simple and works on big- or little-endian machines */
                _flacBuffer[i] = (FLAC__int32)(((FLAC__int16)(FLAC__int8)buffer[offset + 1] << 8) | (FLAC__int16)buffer[offset]);
                offset += 2;
            }
        }
        else {
            // convert 16bit array to 32bit array
            int16_t* arr16 = (int16_t*) buffer;
            for(i = 0; i < samples * self.numberOfChannels; i++) {
                _flacBuffer[i] = (FLAC__int32)(arr16[offset]);
                offset++;
            }
        }
        
        /* feed samples to encoder */
        ok = FLAC__stream_encoder_process_interleaved(_encoder, _flacBuffer, samples);
        if (!ok) {
            FLAC__StreamEncoderState state = FLAC__stream_encoder_get_state(_encoder);
            EV_LOG_ERROR(@"ERROR: Flac error on encoding: %s", FLAC__StreamEncoderStateString[state]);
            *error = [NSError errorWithCode:state andDescription:[NSString stringWithUTF8String:FLAC__StreamEncoderStateString[state]]];
            self.currentEncodedData = nil;
            return nil;
        }
        
        samplesLeft -= samples;
    }
    data = [NSData dataWithData:self.currentEncodedData];
    [self.currentEncodedData setLength:0];
    return data;
}

@end
