//
//  EVStreamURLWriter.m
//  EvaKit
//
//  Created by Yegor Popovych on 8/5/15.
//  Copyright (c) 2015 Evature. All rights reserved.
//

#import "EVStreamURLWriter.h"

@interface NSStream (BoundPairAdditions)
+ (void)createBoundInputStream:(NSInputStream **)inputStreamPtr outputStream:(NSOutputStream **)outputStreamPtr bufferSize:(NSUInteger)bufferSize;
@end

@implementation NSStream (BoundPairAdditions)

+ (void)createBoundInputStream:(NSInputStream **)inputStreamPtr outputStream:(NSOutputStream **)outputStreamPtr bufferSize:(NSUInteger)bufferSize
{
    CFReadStreamRef     readStream;
    CFWriteStreamRef    writeStream;
    
    if ((inputStreamPtr == NULL) || (outputStreamPtr == NULL)) {
        NSLog(@"CRITICAL ERROR:  binding streams are null");
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


@interface EVStreamURLWriter () <NSURLConnectionDataDelegate>

@property (nonatomic, strong) NSURLConnection* connection;
@property (nonatomic, strong) NSOutputStream* dataStream;

@end

@implementation EVStreamURLWriter

- (instancetype)initWithURL:(NSURL*)anURL
                    headers:(NSDictionary*)headers
                 bufferSize:(NSUInteger)bufferSize
                   delegate:(id<EVStreamURLWriterDelegate>)delegate
                  debugMode:(BOOL)isDebug; {
    self = [super init];
    if (self != nil) {
        self.isDebugMode = isDebug;
        self.delegate = delegate;
        NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:anURL];
        [request setHTTPMethod:@"POST"];
        
        for (NSString* header in headers) {
            [request addValue:headers[header] forHTTPHeaderField:header];
        }
        
        NSInputStream* consStream;
        NSOutputStream* prodStream;
        [NSStream createBoundInputStream:&consStream outputStream:&prodStream bufferSize:bufferSize];
        if (consStream == nil) {
            if (isDebug) {
                NSLog(@"CRITICAL ERROR: Stream Writer nil consumer stream");
            }
            return nil;
        }
        
        if (prodStream == nil) {
            if (isDebug) {
                 NSLog(@"CRITICAL ERROR: Stream Writer nil producer stream");
            }
            return nil;
        }
        
        self.dataStream = prodStream;
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

- (void)provider:(id<EVDataProvider>)provider hasNewData:(NSData*)data {
    size_t writed = 0;
    size_t length = [data length];
    const uint8_t* bytes = [data bytes];
    while (writed < length) {
        //Wait for space in stream
        while(!_dataStream.hasSpaceAvailable) usleep(100);
        //Write so many how we can. Save how many we writed
        writed += [_dataStream write:(bytes+writed) maxLength:(length-writed)];
    }
}

- (void)provider:(id<EVDataProvider>)provider gotAnError:(NSError*)error {
    [self.connection cancel];
    [_dataStream close];
    self.dataStream = nil;
    self.connection = nil;
}

- (void)providerStarted:(id<EVDataProvider>)provider {
    [_dataStream open];
}
- (void)providerFinished:(id<EVDataProvider>)provider {
    [_dataStream close];
}


#pragma mark === NSURLCconnectionDelegate methods ===
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    self.connection = nil;
    [self.delegate streamWriter:self gotAnError:error];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.delegate streamWriter:self gotResponseData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [self.delegate streamWriterFinished:self];
}

@end
