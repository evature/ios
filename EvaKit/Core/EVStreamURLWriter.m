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

int streamWriters = 0;
int streamWritersDealloced = 0;

@implementation EVStreamURLWriter


- (instancetype)initWithURL:(NSURL*)anURL
                    headers:(NSDictionary*)headers
                 bufferSize:(NSUInteger)bufferSize
          connectionTimeout:(NSTimeInterval)timeout
                   delegate:(id<EVStreamURLWriterDelegate>)delegate {
    
    streamWriters++;
    NSString *name = [NSString stringWithFormat:@"StreamWriter-%d", streamWriters];
    self = [super initWithName:name andErrorHandler:delegate];
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
        
        EV_LOG_INFO(@"URLWriter:  prod=%x cons=%x", (unsigned int)prodStream, (unsigned int)consStream);
        _streamOpened = NO;
        self.dataStream = prodStream;
        _connectionError = NO;
        
        [request setHTTPBodyStream:consStream];
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            self.connection = [NSURLConnection connectionWithRequest:request delegate:self];
        });
    }
    EV_LOG_DEBUG(@"%@ initialized", self.name);
    return self;
}


- (void)dealloc {
    streamWritersDealloced++;
    EV_LOG_DEBUG(@"Deallocated StreamWriters %d", streamWritersDealloced);
    self.connection = nil;
    self.dataStream = nil;
    [super dealloc];
}


- (void)producer:(EVDataProducer*)producer hasNewData:(NSData*)data {
    EV_LOG_DEBUG(@"%@ Has new data of length %lu from %@", self.name, (unsigned long)[data length], producer.name);
    if (!_streamOpened && !_connectionError) {
        [_dataStream open];
        _streamOpened = YES;
        //Wait for opening
        usleep(200);
        EV_LOG_DEBUG(@"Stream %x opened", (unsigned int)_dataStream);
    }

    size_t wrote = 0;
    size_t length = [data length];
    const uint8_t* bytes = [data bytes];
    while (!_connectionError && wrote < length && _streamOpened) {
        //Wait for space in stream
        while(!_connectionError && !_dataStream.hasSpaceAvailable) {
            EV_LOG_INFO(@"no space avail");
            usleep(100);
        }
        //Write so many how we can. Save how many we wrote
        if (!_connectionError) {
            wrote += [_dataStream write:(bytes+wrote) maxLength:(length-wrote)];
            if (wrote < length) {
                EV_LOG_INFO(@"wrote = %lu  length= %lu", wrote, length);
            }
        }
    }
}

- (void)cancel {
    [super cancel];
    [self.connection cancel];
    if (_streamOpened) {
        _streamOpened = NO;
        [_dataStream close];
        EV_LOG_DEBUG(@"Stream %x closed", (unsigned int)_dataStream);
    }
    self.dataStream = nil;
    self.connection = nil;
}

- (void)producerFinished:(EVDataProducer*)producer {
    if (_streamOpened) {
        _streamOpened = NO;
        [_dataStream close];
    }
}


#pragma mark === NSURLCconnectionDelegate methods ===
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    _connectionError = YES;
    self.connection = nil;
    [self.errorHandler node:self gotAnError:error];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.delegate streamWriter:self gotResponseData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    self.connection = nil;
    [self.delegate streamWriterFinished:self];
}

@end
