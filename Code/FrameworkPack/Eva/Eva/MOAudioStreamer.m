


//
//  MOAudioStreamer.h
//
//  Created by moath othman on 5/22/13.
//  Under MIT License
//

#import "MOAudioStreamer.h"

#include <sys/socket.h>
#include <unistd.h>

#include <CFNetwork/CFNetwork.h>
#include "Common.h"
#include "Eva.h"

#pragma mark * Utilities
#define ext @"flac"
#define USING_SYNC 0


// A category on NSStream that provides a nice, Objective-C friendly way to create
// bound pairs of streams.

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
    
#if defined(__MAC_OS_X_VERSION_MIN_REQUIRED) && (__MAC_OS_X_VERSION_MIN_REQUIRED < 1070)
#error If you support Mac OS X prior to 10.7, you must re-enable CFStreamCreateBoundPairCompat.
#endif
#if defined(__IPHONE_OS_VERSION_MIN_REQUIRED) && (__IPHONE_OS_VERSION_MIN_REQUIRED < 50000)
#error If you support iOS prior to 5.0, you must re-enable CFStreamCreateBoundPairCompat.
#endif
    
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

#pragma mark * audiostreamer

enum {
    kPostBufferSize = 1024*32
};


@interface MOAudioStreamer () < NSStreamDelegate,RecorderDelegate>


// Properties that don't need to be seen by the outside world.

@property (nonatomic, assign, readonly ) BOOL               wasStopped;

//@property (nonatomic, strong, readwrite) NSInputStream *    fileStream;
@property (nonatomic, strong, readwrite) NSOutputStream *   producerStream;
@property (nonatomic, strong, readwrite) NSInputStream *    consumerStream;
@property (nonatomic, assign, readwrite) uint8_t *          bufferOnHeap;
@property (nonatomic, assign, readwrite) size_t             bufferOffset;
@property (nonatomic, assign, readwrite) uint               framesSent;
@property (nonatomic, assign, readwrite) size_t             bufferLimit;
@property long totalSizeRead;
@property long totalSizeSent;


@end

@implementation MOAudioStreamer

@synthesize connection      = _connection;
//@synthesize fileStream      = _fileStream;
@synthesize producerStream  = _producerStream;
@synthesize consumerStream  = _consumerStream;
@synthesize bufferOnHeap    = _bufferOnHeap;
@synthesize bufferOffset    = _bufferOffset;
@synthesize framesSent      = _framesSent;
@synthesize bufferLimit     = _bufferLimit;
@synthesize request;
#pragma mark * Status management

+ (MOAudioStreamer *)sharedInstance
{
    static MOAudioStreamer *sharedInstance = nil;
	if (sharedInstance == nil)
	{
		sharedInstance = [[MOAudioStreamer alloc] init];
        sharedInstance->orderToStop = NO;
	}
	return sharedInstance;
}


// These methods are used by the core transfer code to update the UI.



#pragma mark * Core transfer code

// This is the code that actually does the networking.

- (BOOL)wasStopped
{
    return  orderToStop;
}

- (BOOL)openConsumerStream
{
    NSStreamStatus status = [self.consumerStream streamStatus];
    if (status == NSStreamStatusNotOpen) {
        DLog(@"Opening consumer stream");
        [self.consumerStream open];
        
        int waitForOpen = 0;
        NSStreamStatus status = [self.consumerStream streamStatus];
        while (status < NSStreamStatusOpen) {
            waitForOpen++;
            if (waitForOpen > 250) {
                NSLog(@"Connection failed to open");
                [self stopSendWithStatus:@"Connection failed to open"];
                return FALSE;
            }
            DLog(@"-- Waiting for consumer to open %u", status);
            usleep(10000);
            status = [self.consumerStream streamStatus];
        }
    }

    status = [self.consumerStream streamStatus];
    return status >= NSStreamStatusOpen;
}

void (^iterateProduceData)();

- (void)startSend
{
    
    self.totalSizeRead=0;
    self.totalSizeSent=0;
    
    NSString *documentsDirectory = [NSString stringWithFormat:@"%@",self.recordingPath];
    DLog(@"documentsDirectory is %@",documentsDirectory);
    
    fullPathToFilex = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@",self.fileToSaveName,ext ]];
    
#if DEBUG
    NSNumber *              fileLengthNum;
    fileLengthNum = (NSNumber *) [[[NSFileManager defaultManager] attributesOfItemAtPath:fullPathToFilex error:NULL] objectForKey:NSFileSize];
    if (fileLengthNum == NULL) {
        DLog(@"Error?  Null file size, path: %@   (not error if first run)", fullPathToFilex);
    }
    else {
        DLog(@"Start to send: file size %@ fullpath is %@",fileLengthNum,fullPathToFilex);
    }
#endif
    

    // Open a stream for the file we're going to send.  We open this stream
    // straight away because there's no need to delay.

//    DLog(@"Initializing file stream! 1");
//    self.fileStream = [[NSInputStream alloc] initWithFileAtPath:fullPathToFilex]; // [NSInputStream inputStreamWithFileAtPath:fullPathToFilex];
//    
//    [self.fileStream open];
    
    
    // Open producer/consumer streams.  We open the producerStream straight
    // away.  We leave the consumerStream alone; NSURLConnection will deal
    // with it.
    
    
    NSInputStream *         consStream;
    NSOutputStream *        prodStream;

    [NSStream createBoundInputStream:&consStream outputStream:&prodStream bufferSize:[[Eva sharedInstance] getHttpBufferSize]];
    
    if (consStream == nil) {
        NSLog(@"CRITICAL ERROR: nil consumer stream");
        return;
    }
    
    if (prodStream == nil) {
        NSLog(@"CRITICAL ERROR: nil producer stream");
        return;
    }
    
    self.consumerStream = consStream;
    self.producerStream = prodStream;

    [self.consumerStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];

    
    self.producerStream.delegate = self;
    [self.producerStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [self.producerStream open];
    
    
    [Recorder sharedInstance].delegate = self;
    

    NSString *urlString=[NSString stringWithFormat: @"%@",self.webServiceURL];
    
    
    
    request = (NSMutableURLRequest*)[self postRequestWithURL:urlString data:nil fileName:nil];
    [request setTimeoutInterval:1280];
    
    //here is an important step instead of attach data as apost data to the body you attak an inout stream
    //which is in its turn attached to an output stream that takes its data from fileStream
    
    [request setHTTPBodyStream:self.consumerStream];
    
    self.connection = [NSURLConnection connectionWithRequest:request delegate:self];
    
    [self.connection start];
    
    //create the thread to call the streamer
     
    //dispatch_queue_t highPriQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
    
    _streamDispatch = dispatch_queue_create(
                                            "AUDIO STREAM queue",
                                            DISPATCH_QUEUE_SERIAL);
    dispatch_set_target_queue(_streamDispatch, NULL);//highPriQueue);

    iterateProduceData= ^{
        //while (!orderToStop) {
        [self produceData];
        if (!orderToStop) {
            dispatch_async(_streamDispatch, iterateProduceData);
        }
        //}
    };
    
    orderToStop=NO;
    dispatch_async(_streamDispatch, iterateProduceData);
    
    
    
//    CFReadStreamRef readStream;
//    CFWriteStreamRef writeStream;
//    NSURL *website = [NSURL URLWithString:urlString];
//    
//    CFStreamCreatePairWithSocketToHost(NULL, (__bridge CFStringRef)[website host], 80, &readStream, &writeStream);
//    
//    NSInputStream *inputStream = (__bridge_transfer NSInputStream *)readStream;
//    NSOutputStream *outputStream = (__bridge_transfer NSOutputStream *)writeStream;
//    [inputStream setDelegate:self];
//    [outputStream setDelegate:self];
//    [inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
//    [outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
//    [inputStream open];
//    [outputStream open];
    
    /* Store a reference to the input and output streams so that
     they don't go away.... */
//    self.producerStream = outputStream;
//    self.consumerStream = inputStream;
    
    DLog(@" **** sendDidStart **** ");
}


- (void)stopSendWithStatus:(NSString *)statusString
{
    DLog(@"##### cancel send with status: %@",statusString);
    if ([Recorder sharedInstance]!=nil) {
        [[Recorder sharedInstance] stopRecording];
    }
    
    StopSignal=YES;

    if (self.bufferOnHeap) {
        free(self.bufferOnHeap);
        self.bufferOnHeap = NULL;
    }
    //self.buffer = NULL;
    self.bufferOffset = 0;
    self.bufferLimit  = 0;
    self.framesSent  = 0;
    if (self.connection != nil) {
        [self.connection cancel];
        self.connection = nil;
    }
    //    self.bodyPrefixData = nil;
    if (self.producerStream != nil) {
        self.producerStream.delegate = nil;
        [self.producerStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        [self.producerStream close];
        self.producerStream = nil;
    }
    self.consumerStream = nil;
}


/****
 *  Read data from encoded file  - send it to http
 *  write in chunks until written size is less than chunk size, or until no new data is available
 *  sleep for 10ms if no data is available
 *****/
- (void) produceData {
    @synchronized(self){
        BOOL repeat= YES;
        while (repeat) {
            // Check to see if we've run off the end of our buffer.  If we have,
            // work out the next buffer of data to send.
            
            if (self.bufferOnHeap == NULL) {
                self.bufferOnHeap = malloc(kPostBufferSize);
                self.bufferLimit = 0;
            }

            // if bufferOffset equals to bufferLimit it means we transmitted everything
            // we read already - time to read some more
            if (self.bufferOffset == self.bufferLimit) {
                
                // read from file - continue where we last stopped
                NSFileHandle *fHandle;
                fHandle = [NSFileHandle fileHandleForReadingAtPath:soundFilePath];
                [fHandle seekToFileOffset:  self.totalSizeRead];
                
                NSData *data = [fHandle readDataOfLength:kPostBufferSize];
                [fHandle closeFile];

                NSInteger   bytesRead = [data length];
//#if DEBUG_MODE_FOR_EVA
//                    if (bytesRead > 20) {
//                        bytesRead = 20+arc4random_uniform(bytesRead-20);
//                    }
//#endif
                if (bytesRead > kPostBufferSize) {
                    NSLog(@"CRITICAL ERROR  bytesRead > kPostBufferSize");
                    return;
                }
                
                if (self.bufferOnHeap==NULL) {
                    NSLog(@"CRITICAL ERROR: no buffer allocated");
                    return;
                }
                
                // copy data from NSData to heap allocated buffer
                memcpy(self.bufferOnHeap, [data bytes], bytesRead);
                
        
                if (bytesRead <= 0) {
                    
                    if (bytesRead < 0) {
                        NSLog(@"ERROR: Failed to read from encoded file %d", bytesRead);
                        [self stopSendWithStatus:@"File read error"];
                    }
                    
                    if ([[Recorder sharedInstance] recording] == NO) {
                        StopSignal = true;
                    }

                    // read zero bytes from file - no new encoded data - check if stop signal
                    if ( StopSignal) {
                        if (self.bufferOnHeap != NULL) {
                            free(self.bufferOnHeap);
                            self.bufferOnHeap = NULL;
                        }
                        self.bufferOffset = 0;
                        self.bufferLimit = 0;
                        
                        orderToStop = YES;
                        DLog(@"----> Streamer: Closing: total size read: %li    total size written %li", self.totalSizeRead, self.totalSizeSent);
                        
                        if (self.producerStream != nil) {
                            DLog(@"closing the producer stream");
                            // We set our delegate callback to nil because we don't want to
                            // be called anymore for this stream.  However, we can't
                            // remove the stream from the runloop (doing so prevents the
                            // URL from ever completing) and nor can we nil out our
                            // stream reference (that causes all sorts of wacky crashes).
                            //
                            // +++ Need bug numbers for these problems.
                            
                            self.producerStream.delegate = nil;
                            // [self.producerStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
                            [self.producerStream close];
                            if (self.streamerDelegate &&[self.streamerDelegate respondsToSelector:@selector(MOAudioStreamerDidFinishStreaming:)]) {
                                [self.streamerDelegate MOAudioStreamerDidFinishStreaming:self];
                            }
                        }

                    }
                    else {
                        // no new encoded data, and not time to stop yet - sleep a bit
                        //DLog(@"----> Streamer:  No data available - GOING TO SLEEP----");
                        usleep(10000);
                    }
                    return;
                }
                
                NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:soundFilePath error:nil];
                NSNumber *fileLengthNum = (NSNumber *) [fileAttributes objectForKey:NSFileSize];
                DLog(@"----> Streamer: Read %li bytes from file, file size is %@", (long)bytesRead, fileLengthNum);

                self.bufferOffset = 0;
                self.totalSizeRead += bytesRead;
                self.bufferLimit  = bytesRead;
            }
            else {
                DLog(@"----> Streamer: Continuing to transmit previous read data, offset at %zu,  limit at %zu  ---", self.bufferOffset, self.bufferLimit);
            }
                
            // Send the next chunk of data in our buffer.
            if (self.bufferOffset >= self.bufferLimit) {
                NSLog(@"CRITICAL ERROR: expected bufferOffset to be less than limit");
                if (self.streamerDelegate &&[self.streamerDelegate respondsToSelector:@selector(MOAudioStreamerDidFailed:message:)]) {
                    [self.streamerDelegate MOAudioStreamerDidFailed:self message:NSLocalizedString(@"network write error", nil)];
                }
                
                [self stopSendWithStatus:@"Network write error"];
                return;
            }
            
            int maxlength = self.bufferLimit - self.bufferOffset;

            NSStreamStatus status1 = [self.producerStream streamStatus];
            NSStreamStatus status2 = [self.consumerStream streamStatus];
            DLog(@"----> Streamer: Just before writing to producer  Prod stat= %u    Cons stat= %u", status1, status2);
            
            NSInteger bytesWritten = [self.producerStream write:&self.bufferOnHeap[self.bufferOffset] maxLength:maxlength];
            
            DLog(@"----> Streamer Sent %d bytes to HTTP, maxLen=%d", bytesWritten, maxlength);
            
            if (bytesWritten <= 0) {
                NSLog(@"Error! failed to write to HTTP");
                if (self.streamerDelegate &&[self.streamerDelegate respondsToSelector:@selector(MOAudioStreamerDidFailed:message:)]) {
                    [self.streamerDelegate MOAudioStreamerDidFailed:self message:NSLocalizedString(@"network write error", nil)];
                }
                
                [self stopSendWithStatus:@"Network write error"];
                return;
            }
            // sent some - so now need to wait for HasSpaceAvail event
            
    //        NSStreamStatus consumerStatus = [self.consumerStream streamStatus];
    //        if (consumerStatus < NSStreamStatusOpen) {
    //            bool isOpen = [self openConsumerStream];
    //            if (!isOpen) {
    //                if (self.streamerDelegate &&[self.streamerDelegate respondsToSelector:@selector(MOAudioStreamerDidFailed:message:)]) {
    //                    [self.streamerDelegate MOAudioStreamerDidFailed:self message:NSLocalizedString(@"network write error", nil)];
    //                }
    //                
    //                [self stopSendWithStatus:@"Failed to open connection"];
    //            }
    //        }
            
            if (bytesWritten < maxlength) {
                // wrote less bytes then we wanted - the upload isn't fast enough
                DLog(@"------ Streamer -  written %d bytes, wanted to send %d", bytesWritten, maxlength);
                usleep(10000); 
            }
            
            
            if (maxlength < kPostBufferSize) {
                // read less than maximum from file - the reading is faster than the writing
                repeat = NO;
                DLog(@"----Streamer: Sent less than maximum ----");
                usleep(10000);
            }
            
            self.bufferOffset  += bytesWritten;
            self.totalSizeSent += bytesWritten;
            self.framesSent++;
            DLog(@"----> Streamer Frame %u,  total size read: %li    total size written %li", self.framesSent, self.totalSizeRead, self.totalSizeSent);
        }
    }
    
    
}






#pragma mark connection Delegate

- (void)connection:willSendRequestForAuthenticationChallenge
{
    DLog(@"connection:willSendRequestForAuthenticationChallenge");
}


- (void)connection:(NSURLConnection *)theConnection didReceiveResponse:(NSURLResponse *)response
// A delegate method called by the NSURLConnection when the request/response
// exchange is complete.  We look at the response to check that the HTTP
// status code is 2xx.  If it isn't, we fail right now.
{
    
    // DLog(@"did receive response");
    if (self.connection) {
        
        
#pragma unused(theConnection)
        NSHTTPURLResponse * httpResponse;
        
        // assert(theConnection == self.connection);
        
        httpResponse = (NSHTTPURLResponse *) response;
        assert( [httpResponse isKindOfClass:[NSHTTPURLResponse class]] );
        DLog(@"httpresponse for streamer header is %@",[httpResponse allHeaderFields]);
        if ((httpResponse.statusCode / 100) != 2) {
            DLog(@"HTTP error");
            [self stopSendWithStatus:[NSString stringWithFormat:@"HTTP error %zd", (ssize_t) httpResponse.statusCode]];
        }
        else {
            //[self stopSendWithStatus:@"RECIVED RESPONSE WITH NO ERROR"]; // NEW - 4/9/13
        }
        

    }//end of self.connection if
    
    [self.streamerDelegate MOAudioStreamerConnection:self theConnection:theConnection didReceiveResponse:response]; //NEW
}

- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode
{
    if (aStream == self.producerStream) {
        switch(eventCode) {
            case NSStreamEventNone:
                DLog(@"None event for producer");
                break;
            case NSStreamEventErrorOccurred:
                DLog(@"Error at producer stream delegate");
                break;
            case NSStreamEventOpenCompleted:
                DLog(@"Producer Open at stream delegate");
                break;
                
            case NSStreamEventHasSpaceAvailable:
                DLog(@"Producer has space available");
                break;
                
            case NSStreamEventHasBytesAvailable:
                DLog(@"Has bytes available for producer stream?");
                break;
                
            case NSStreamEventEndEncountered:
            {
                DLog(@"Producer Stream closed");
                [self.producerStream close];
                [self.producerStream removeFromRunLoop:[NSRunLoop currentRunLoop]
                                               forMode:NSDefaultRunLoopMode];
                //[self.consumerStream release];
                self.producerStream = nil; // stream is ivar, so reinit it
                break;
            }

        }
    }
    else if (aStream == self.consumerStream) {
        
        switch(eventCode) {
            case NSStreamEventNone:
                DLog(@"None event for consumer ");
                break;
                
            case NSStreamEventErrorOccurred:
                DLog(@"Error at consumer stream delegate");
                break;
                
            case NSStreamEventHasSpaceAvailable:
                DLog(@"Has space available for consumer stream?");
                break;
                
            case NSStreamEventOpenCompleted:
                DLog(@"Consumer Open at stream delegate");
                break;
                
            case NSStreamEventHasBytesAvailable: {
                uint8_t buf[1024];
                unsigned int len = [self.consumerStream read:buf maxLength:1024];
                DLog(@"Consumer has bytes available len = %u", len);
                if(len) {
                    NSData *data = [NSData dataWithBytes:buf length:len];
                    [self.streamerDelegate MOAudioStreamerConnection:self theConnection:self.connection didReceiveData:data];
                } else {
                    DLog(@"no buffer!");
                }
                break;
            }
                
            case NSStreamEventEndEncountered:
            {
                DLog(@"ConsumerStream closed");
                [self.consumerStream close];
                [self.consumerStream removeFromRunLoop:[NSRunLoop currentRunLoop]
                                  forMode:NSDefaultRunLoopMode];
                //[self.consumerStream release];
                self.consumerStream = nil;
                [self.streamerDelegate MOAudioStreamerConnectionDidFinishLoading:self theConnection:self.connection];
                break;
            }
        }
    }
    else {
        DLog(@"Not the right stream!");
    }
}




- (void)connection:(NSURLConnection *)theConnection didReceiveData:(NSData *)data
// A delegate method called by the NSURLConnection as data arrives.  The
// response data for a POST is only for useful for debugging purposes,
// so we just drop it on the floor.
{
#pragma unused(theConnection)
#pragma used(data)
    DLog(@"nscpnnection did receive data");
    if (self.connection) {
        
//        if (!responseData) {
//            //    DLog(@"response data is nilllll");
//            responseData=[NSMutableData new];
//        }
//        
//        [responseData appendData:data];
        
        // removed: 8/6/14
        //  [self stopSendWithStatus:@"RECIVED RESPONSE WITH NO ERROR"]; // NEW - 4/9/13
        // do nothing
        [self.streamerDelegate MOAudioStreamerConnection:self theConnection:theConnection didReceiveData:data];

    }else{
        DLog(@"self.connection audiostreamer.m is null");
    }

}

- (void)connection:(NSURLConnection *)theConnection didFailWithError:(NSError *)error
// A delegate method called by the NSURLConnection if the connection fails.
// We shut down the connection and display the failure.  Production quality code
// would either display or log the actual error.
{
    
    if (self.connection) {
        
#pragma unused(theConnection)
#pragma unused(error)
        //  assert(theConnection == self.connection);
        DLog(@"connection failed with error %@",error.description);
        [self stopSendWithStatus:@"Connection failed"];
        connectionError=error;
        
        if (self.streamerDelegate &&[self.streamerDelegate respondsToSelector:@selector(MOAudioStreamerDidFailed:message:)]) {
            [self.streamerDelegate MOAudioStreamerDidFailed:self message:connectionError.localizedDescription ];
        }
    }

    [self.streamerDelegate MOAudioStreamerConnection:self theConnection:theConnection didFailWithError:error]; // NEW
}

- (void)connectionDidFinishLoading:(NSURLConnection *)theConnection
// A delegate method called by the NSURLConnection when the connection has been
// done successfully.  We shut down the connection with a nil status, which
// causes the image to be displayed.
{
    if (self.connection) {
//        stopSendingStupidData=YES;
//#pragma unused(theConnection)
//        
//        if (giveMeResults ) {
//#if DEBUG_LOGS
//            DLog(@"lets see results");
//#endif
//            NSString *String =[[NSString alloc]initWithData:responseData encoding:NSUTF8StringEncoding];
//            //    [self.streamerDelegate MOAudioStreamerDidFinishRequest:theConnection withResponse:String];
//            if (!responseData) {
//                
//                if (self.streamerDelegate &&[self.streamerDelegate respondsToSelector:@selector(MOAudioStreamerDidFailed:message:)]) {
//                    [self.streamerDelegate MOAudioStreamerDidFailed:self message:NSLocalizedString(@"connection finished loading with no response", nil) ];
//                }
//            }else{
//                if (self.streamerDelegate &&[self.streamerDelegate respondsToSelector:@selector(MOAudioStreamerDidFinishRequest:withResponse:)]) {
//                    [self.streamerDelegate MOAudioStreamerDidFinishRequest:self theConnection:theConnection withResponse:String];
//                }else{
//#if DEBUG_LOGS
//                    DLog(@"it does not respond to selector streamdidFinishRequest");
//#endif
//                }
//            }
//            giveMeResults=NO;
//            
//        }
//        responseData=nil;
//#if DEBUG_THIS
//        #if DEBUG_LOGS
//        DLog(@"connection did data length ");
//#endif
//#endif
//        // assert(theConnection == self.connection);
        [self.streamerDelegate MOAudioStreamerConnectionDidFinishLoading:self theConnection:theConnection]; // NEW
        
        [self stopSendWithStatus:@"end connection"];
    }
}

#pragma mark * Actions
- (void)startStreamer:(float)maxRecordingTime;
{
#if DEBUG_LOGS
    DLog(@"startStreamer");
#endif
//    giveMeResults=YES;
    StopSignal=NO;
    
    [self setupNewRecordableFile:maxRecordingTime ];
    
    
    //[self performSelector:@selector(startSend) withObject:[NSNull null] afterDelay:0.5];//0.5];
    
    
    //[self performSelector:@selector(startSend) withObject:[NSNull null] ];
    
//    StopSignal=NO;
    
}
-(void)stopStreaming{
    DLog(@"Stop streaming");
    if ([Recorder sharedInstance] !=nil) {
        [[Recorder sharedInstance] stopRecording];
    }
    
    StopSignal=YES;
}


- (void)cancelStreaming
{
    [self stopSendWithStatus:@"Cancelled"];
}



#pragma mark * URL Request
NSString *fullPathToFilex;

-(NSURLRequest *)postRequestWithURL: (NSString *)url

                               data: (NSData *)aData
                           fileName: (NSString*)fileName
{
    // fileName=@"";
    aData=nil;
    
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestUseProtocolCachePolicy   timeoutInterval:240];
    
    [urlRequest setHTTPMethod:@"POST"];
    [urlRequest addValue:@"100-continue"  forHTTPHeaderField:@"Expect"];
    //[request setAllowsCellularAccess:YES];
    
    //NSString *myboundary = @"---------------------------14737809831466499882746641449";
    // NSString *contentType = [NSString stringWithFormat:@"audio/form-data; boundary=%@",myboundary];
    //[urlRequest addValue:contentType forHTTPHeaderField: @"Content-Type"];
    //[urlRequest addValue:@"Keep-Alive" forHTTPHeaderField:@"Connection"];
    [urlRequest addValue:@"audio/x-flac;rate=16000" forHTTPHeaderField:@"Content-Type"];
    
    [urlRequest addValue:@"chunked" forHTTPHeaderField:@"Transfer-Encoding"];
    //[urlRequest setValue:@"max-age=0" forHTTPHeaderField:@"Cache-Control"];
    
    //NSString *encodedEveryThing;
    
    /*MARK:you can ignore the following 2 line if you don't use Basic Authorization */
    //    encodedEveryThing = [self getEncodedHeader];
    //
    //    [urlRequest addValue:[NSString stringWithFormat:@"Basic %@",encodedEveryThing] forHTTPHeaderField:@"Authorization"];
    //
    //
    return urlRequest;
}

-(void)removeRecordableFile{
    NSFileManager *fileManager=[NSFileManager defaultManager];
    
    
    NSString *dataPath= [NSString stringWithString: self.recordingPath];
    
    NSNumber *    fileLengthNum = (NSNumber *) [[[NSFileManager defaultManager] attributesOfItemAtPath:fullPathToFilex error:NULL] objectForKey:NSFileSize];
    // assert( [fileLengthNum isKindOfClass:[NSNumber class]] );
    if (fileLengthNum == NULL) {
        DLog(@"Error: Null file size!"); // could be ok if this is the first time
    }
    DLog(@"Removing: file size %@ fullpath is %@",fileLengthNum,fullPathToFilex);
    
    if ([fileManager removeItemAtPath:dataPath error:nil]) {
        DLog(@">>> Remove File Succesfully");
    }
}


-(void)setupNewRecordableFile:(float) maxRecordingTime{
    if (maxRecordingTime != -1) {
        DLog(@"Dbg: setup new file");
        [self removeRecordableFile];
        DLog(@"Dbg:  cleanedup last file");
    }
    NSFileManager *fileManager=[NSFileManager defaultManager];
    
    
    NSString *dataPath= [NSString stringWithString: self.recordingPath];
    
    if (![fileManager fileExistsAtPath:dataPath isDirectory:nil]) {
        
        BOOL success = [fileManager createDirectoryAtPath:dataPath withIntermediateDirectories:NO attributes:nil error:nil];
        DLog(@"success in creating recordedSounds Dir is: %i", success);
    }
    
    if (!self.fileToSaveName || [self.fileToSaveName isEqualToString:@""]) {
        self.fileToSaveName=@"temp";
    }
    
    soundFilePath = [NSString stringWithString: [dataPath
                                                 stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@",self.fileToSaveName,ext ]]];
    
    if ([Recorder sharedInstance]==nil || maxRecordingTime == -1) {
        return;
    }
    [Recorder sharedInstance].savedPath = soundFilePath;
    [Recorder sharedInstance].delegate = self;
    DLog(@"Dbg: Saving file to %@,  starting to record", soundFilePath);
    [[Recorder sharedInstance] startRecording: maxRecordingTime];
}


+ (NSThread *)networkThread {
    static NSThread *networkThread = nil;
    static dispatch_once_t oncePredicate;
    
    dispatch_once(&oncePredicate, ^{
        networkThread =
        [[NSThread alloc] initWithTarget:self
                                selector:@selector(networkThreadMain:)
                                  object:nil];
        [networkThread start];
    });
    
    return networkThread;
}

+ (void)networkThreadMain:(id)unused {
    do {
        @autoreleasepool {
            [[NSRunLoop currentRunLoop] run];
        }
    } while (YES);
}


#pragma mark RecorderDelegate
- (void)recorderMicLevelCallbackAverage: (float)averagePower andPeak: (float)peakPower{
#if DEBUG_THIS
    #if DEBUG_LOGS
        DLog(@"AudioStreamer - recorderMicLevelCallbackAverage:andPeak");
    #endif
#endif
    
    
    if([self.streamerDelegate respondsToSelector:@selector(MORecorderMicLevelCallbackAverage:andPeak:)]){
        
        [self.streamerDelegate MORecorderMicLevelCallbackAverage:averagePower andPeak:peakPower];
        
    }else{
#if DEBUG_LOGS
        DLog(@"Error: You haven't implemented MORecorderMicLevelCallbackAverage, It is a must. Please implement this one");
#endif
    }
    //- (void)MORecorderMicLevelCallbackAverage: (float)averagePower andPeak: (float)peakPower
}

-(float)averagePower{
    return [[Recorder sharedInstance] averagePower];
}

-(float)peakPower{
    return [[Recorder sharedInstance] peakPower];
}

- (void)recordFileWasCreated
{
    [self startSend];
}

@end
