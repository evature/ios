//
//  EVAudioDataStreamer.m
//  EvaKit
//
//  Created by Yegor Popovych on 8/5/15.
//  Copyright (c) 2015 Evature. All rights reserved.
//

#import "EVAudioDataStreamer.h"
#import "EVStreamURLWriter.h"
#import "EVLogger.h"


@interface EVAudioDataStreamer () <EVStreamURLWriterDelegate>

@property (nonatomic, strong, readwrite) NSMutableData* responseData;

@end

@implementation EVAudioDataStreamer

- (instancetype)initWithOperationChainLength:(NSUInteger)length {
    self = [super initWithOperationChainLength:length];
    if (self != nil) {
        self.responseData = [NSMutableData data];
        self.httpBufferSize = 0;
        self.connectionTimeout = 10.0f;
    }
    return self;
}

-  (void)dealloc {
    [self.dataConsumer release];
    self.dataConsumer = nil;
    self.responseData = nil;
    self.webServiceURL = nil;
    [super dealloc];
}

- (void)setHttpBufferSize:(NSUInteger)httpBufferSize {
    httpBufferSize = httpBufferSize > 32768 ? httpBufferSize : 32768;
    _httpBufferSize = httpBufferSize;
}

- (void)producerStarted:(id<EVDataProducer>)producer {
    [self.responseData setLength:0];
    
    EV_LOG_DEBUG(@"Starting request to URL: %@", self.webServiceURL);
   
    EVStreamURLWriter* streamWriter = [[EVStreamURLWriter alloc] initWithURL:self.webServiceURL
                                                                     headers:@{
                                                                               @"Expect": @"100-continue",
                                                                               @"Transfer-Encoding": @"chunked",
                                                                               @"Content-Type": [NSString stringWithFormat:@"audio/x-flac;rate=%u", self.sampleRate]
                                                                               }
                                                                  bufferSize:self.httpBufferSize
                                                           connectionTimeout:self.connectionTimeout
                                                                    delegate:self];
    self.dataConsumer = streamWriter;
    if (streamWriter == nil) {
        [self.errorHandler provider:self gotAnError:[NSError errorWithCode:EVAudioDataStreamerCreateErrorCode andDescription:@"Can't create stream writer"]];
    } else {
        streamWriter.errorHandler = self.errorHandler;
        [super producerStarted:producer];
    }
}

- (void)cancel {
    [super cancel];
    [(EVStreamURLWriter*)self.dataConsumer cancel];
}


- (NSData*)processData:(NSData*)data error:(NSError**)error {
    return data;
}


- (void)streamWriter:(EVStreamURLWriter*)writer gotResponseData:(NSData*)data {
    EV_LOG_DEBUG("StreamWriter got some response");
    [data retain];
    dispatch_async(self.operationQueue, ^{
        [self.responseData appendData:data];
        [data release];
    });
}

- (void)streamWriter:(EVStreamURLWriter *)writer gotAnError:(NSError*)error {
    EV_LOG_DEBUG(@"StreamWriter got an error: %@", error);
    [error retain];
    dispatch_async(self.operationQueue, ^{
        [error autorelease];
        [self.errorHandler provider:self gotAnError:error];
        [self.dataConsumer release];
        self.dataConsumer = nil;
    });
}

- (void)streamWriterFinished:(EVStreamURLWriter *)writer {
    dispatch_async(self.operationQueue, ^{
        [self.dataConsumer release];
        self.dataConsumer = nil;
        NSError* error = nil;
        NSDictionary* json = [NSJSONSerialization JSONObjectWithData:self.responseData options:kNilOptions error:&error];
        if (error != nil) {
            EV_LOG_ERROR("Can't read json: %@", error);
            [self.errorHandler provider:self gotAnError:error];
        } else {
            [self.delegate audioDataStreamerFinished:self withResponse:json];
        }
        [self.responseData setLength:0];
    });
}

@end
