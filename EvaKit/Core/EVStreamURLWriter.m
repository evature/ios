//
//  EVStreamURLWriter.m
//  EvaKit
//
//  Created by Yegor Popovych on 8/5/15.
//  Copyright (c) 2015 Evature. All rights reserved.
//

#import "EVStreamURLWriter.h"
#import "EVLogger.h"

@interface NSStream (BoundPairAdditions)
+ (void)createBoundInputStream:(NSInputStream **)inputStreamPtr outputStream:(NSOutputStream **)outputStreamPtr bufferSize:(NSUInteger)bufferSize;
@end

@implementation NSStream (BoundPairAdditions)

+ (void)createBoundInputStream:(NSInputStream **)inputStreamPtr outputStream:(NSOutputStream **)outputStreamPtr bufferSize:(NSUInteger)bufferSize
{
    CFReadStreamRef     readStream;
    CFWriteStreamRef    writeStream;
    
    if ((inputStreamPtr == NULL) || (outputStreamPtr == NULL)) {
        EV_LOG_ERROR(@"Binding streams are null");
        return;
    }
    
    readStream = NULL;
    writeStream = NULL;
    
    CFStreamCreateBoundPair(
                            NULL,
                            ((inputStreamPtr  != nil) ? &readStream : NULL),
                            ((outputStreamPtr != nil) ? &writeStream : NULL),
                            (CFIndex) bufferSize
                            );
    
    if (inputStreamPtr != NULL) {
        *inputStreamPtr  = CFBridgingRelease(readStream);
    }
    if (outputStreamPtr != NULL) {
        *outputStreamPtr = CFBridgingRelease(writeStream);
    }
}

@end


@interface EVStreamURLWriter () <NSURLConnectionDataDelegate> {
    BOOL _streamOpened;
    BOOL _connectionError;
}

@property (nonatomic, strong) NSURLConnection* connection;
@property (nonatomic, strong) NSOutputStream* dataStream;

@end

@implementation EVStreamURLWriter

@synthesize errorHandler;

- (instancetype)initWithURL:(NSURL*)anURL
                    headers:(NSDictionary*)headers
                 bufferSize:(NSUInteger)bufferSize
          connectionTimeout:(NSTimeInterval)timeout
                   delegate:(id<EVStreamURLWriterDelegate>)delegate {
    self = [super init];
    if (self != nil) {
        self.delegate = delegate;
        NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:anURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:timeout];
        [request setHTTPMethod:@"POST"];
        
        for (NSString* header in headers) {
            [request addValue:headers[header] forHTTPHeaderField:header];
        }
        
        NSInputStream* consStream;
        NSOutputStream* prodStream;
        [NSStream createBoundInputStream:&consStream outputStream:&prodStream bufferSize:bufferSize];
        if (consStream == nil) {
            EV_LOG_ERROR(@"Stream Writer nil consumer stream");
            return nil;
        }
        
        if (prodStream == nil) {
            EV_LOG_ERROR(@"Stream Writer nil producer stream");
            return nil;
        }
        
        _streamOpened = NO;
        self.dataStream = prodStream;
        _connectionError = NO;
        
        [request setHTTPBodyStream:consStream];
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            self.connection = [NSURLConnection connectionWithRequest:request delegate:self];
        });
    }
    return self;
}


- (void)dealloc {
    self.connection = nil;
    self.dataStream = nil;
    [super dealloc];
}

- (void)producer:(id<EVDataProducer>)producer hasNewData:(NSData*)data {
    if (!_streamOpened && !_connectionError) {
        [_dataStream open];
        _streamOpened = YES;
        //Wait for opening
        usleep(200);
    }
    size_t wrote = 0;
    size_t length = [data length];
    const uint8_t* bytes = [data bytes];
    while (!_connectionError && wrote < length) {
        //Wait for space in stream
        while(!_connectionError && !_dataStream.hasSpaceAvailable) usleep(100);
        //Write so many how we can. Save how many we wrote
        if (!_connectionError) {
            wrote += [_dataStream write:(bytes+wrote) maxLength:(length-wrote)];
        }
    }
}

- (void)cancel {
    [self.connection cancel];
    if (_streamOpened) {
        [_dataStream close];
        _streamOpened = NO;
    }
    self.dataStream = nil;
    self.connection = nil;
}

- (void)producerStarted:(id<EVDataProducer>)producer {
    // Do nothing.
}

- (void)producerFinished:(id<EVDataProducer>)producer {
    if (_streamOpened) {
        _streamOpened = NO;
        [_dataStream close];
    }
}


#pragma mark === NSURLCconnectionDelegate methods ===
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    _connectionError = YES;
    self.connection = nil;
    [self.errorHandler provider:self gotAnError:error];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.delegate streamWriter:self gotResponseData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    self.connection = nil;
    [self.delegate streamWriterFinished:self];
}

@end
