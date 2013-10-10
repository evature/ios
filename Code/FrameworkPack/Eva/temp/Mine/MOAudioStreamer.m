 


//
//  MOAudioStreamer.h
//
//  Created by moath othman on 5/22/13.
//  Under MIT License
//

#import "MOAudioStreamer.h"

#import "NetworkManager.h"

#include <sys/socket.h>
#include <unistd.h>

#include <CFNetwork/CFNetwork.h>

#pragma mark * Utilities
#define ext @"flac"
#define USING_SYNC 0

#define DEBUG_THIS TRUE//FALSE


static void CFStreamCreateBoundPairCompat(
                                          CFAllocatorRef      alloc,
                                          CFReadStreamRef *   readStreamPtr,
                                          CFWriteStreamRef *  writeStreamPtr,
                                          CFIndex             transferBufferSize
                                          )
// This is a drop-in replacement for CFStreamCreateBoundPair that is necessary because that
// code is broken on iOS versions prior to iOS 5.0 <rdar://problem/7027394> <rdar://problem/7027406>.
// This emulates a bound pair by creating a pair of UNIX domain sockets and wrapper each end in a
// CFSocketStream.  This won't give great performance, but it doesn't crash!
{
#pragma unused(transferBufferSize)
    int                 err;
    Boolean             success;
    CFReadStreamRef     readStream;
    CFWriteStreamRef    writeStream;
    int                 fds[2];
    
    assert(readStreamPtr != NULL);
    assert(writeStreamPtr != NULL);
    
    readStream = NULL;
    writeStream = NULL;
    
    // Create the UNIX domain socket pair.
    
    err = socketpair(AF_UNIX, SOCK_STREAM, 0, fds);
    if (err == 0) {
        
        CFStreamCreatePairWithSocket(alloc, fds[0], &readStream,  NULL);
        CFStreamCreatePairWithSocket(alloc, fds[1], NULL, &writeStream);
        
        // If we failed to create one of the streams, ignore them both.
        
        if ( (readStream == NULL) || (writeStream == NULL) ) {
            if (readStream != NULL) {
                CFRelease(readStream);
                readStream = NULL;
            }
            if (writeStream != NULL) {
                CFRelease(writeStream);
                writeStream = NULL;
            }
        }
        assert( (readStream == NULL) == (writeStream == NULL) );
        
        // Make sure that the sockets get closed (by us in the case of an error,
        // or by the stream if we managed to create them successfull).
          
        if (readStream == NULL) {
            err = close(fds[0]);
            assert(err == 0);
            err = close(fds[1]);
            assert(err == 0);
        } else {
            success = CFReadStreamSetProperty(readStream, kCFStreamPropertyShouldCloseNativeSocket, kCFBooleanTrue);
            assert(success);
            success = CFWriteStreamSetProperty(writeStream, kCFStreamPropertyShouldCloseNativeSocket, kCFBooleanTrue);
            assert(success);
        }
    }
    
    *readStreamPtr = readStream;
    *writeStreamPtr = writeStream;
}

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
    
    assert( (inputStreamPtr != NULL) || (outputStreamPtr != NULL) );
    
    readStream = NULL;
    writeStream = NULL;
    
#if defined(__MAC_OS_X_VERSION_MIN_REQUIRED) && (__MAC_OS_X_VERSION_MIN_REQUIRED < 1070)
#error If you support Mac OS X prior to 10.7, you must re-enable CFStreamCreateBoundPairCompat.
#endif
#if defined(__IPHONE_OS_VERSION_MIN_REQUIRED) && (__IPHONE_OS_VERSION_MIN_REQUIRED < 50000)
#error If you support iOS prior to 5.0, you must re-enable CFStreamCreateBoundPairCompat.
#endif
    
    if (NO) {
        CFStreamCreateBoundPairCompat(
                                      NULL,
                                      ((inputStreamPtr  != nil) ? &readStream : NULL),
                                      ((outputStreamPtr != nil) ? &writeStream : NULL),
                                      (CFIndex) bufferSize
                                      );
    } else {
        CFStreamCreateBoundPair(
                                NULL,
                                ((inputStreamPtr  != nil) ? &readStream : NULL),
                                ((outputStreamPtr != nil) ? &writeStream : NULL),
                                (CFIndex) bufferSize
                                );
    }
    
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
    kPostBufferSize = 2048//2048
};

 
@interface MOAudioStreamer () < NSStreamDelegate,RecorderDelegate>


// Properties that don't need to be seen by the outside world.

@property (nonatomic, assign, readonly ) BOOL               isSending;

@property (nonatomic, copy,   readwrite) NSData *           bodyPrefixData;
@property (nonatomic, strong, readwrite) NSInputStream *    fileStream;
@property (nonatomic, copy,   readwrite) NSData *           bodySuffixData;
@property (nonatomic, strong, readwrite) NSOutputStream *   producerStream;
@property (nonatomic, strong, readwrite) NSInputStream *    consumerStream;
@property (nonatomic, assign, readwrite) const uint8_t *    buffer;
@property (nonatomic, assign, readwrite) uint8_t *          bufferOnHeap;
@property (nonatomic, assign, readwrite) size_t             bufferOffset;
@property (nonatomic, assign, readwrite) size_t             bufferLimit;

@end

@implementation MOAudioStreamer

@synthesize connection      = _connection;
@synthesize bodyPrefixData  = _bodyPrefixData;
@synthesize fileStream      = _fileStream;
@synthesize bodySuffixData  = _bodySuffixData;
@synthesize producerStream  = _producerStream;
@synthesize consumerStream  = _consumerStream;
@synthesize buffer          = _buffer;
@synthesize bufferOnHeap    = _bufferOnHeap;
@synthesize bufferOffset    = _bufferOffset;
@synthesize bufferLimit     = _bufferLimit;
@synthesize expectingTimeOut=_expectingTimeOut,userName,password;
@synthesize request;
#pragma mark * Status management

+ (MOAudioStreamer *)sharedInstance
{
    static MOAudioStreamer *sharedInstance = nil;
	if (sharedInstance == nil)
	{
		sharedInstance = [[MOAudioStreamer alloc] init];
	}
	return sharedInstance;
}


// These methods are used by the core transfer code to update the UI.

- (void)sendDidStart
{
#if    DEBUG_THIS
    NSLog(@" **** sendDidStart **** ");
#endif
     [[NetworkManager sharedInstance] didStartNetworkOperation];
}

- (void)sendDidStopWithStatus:(NSString *)statusString
{
    if (statusString == nil) {
        statusString = @"POST succeeded";
    }
     [[NetworkManager sharedInstance] didStopNetworkOperation];
}

#pragma mark * Core transfer code

// This is the code that actually does the networking.

- (BOOL)isSending
{
    return (self.connection != nil);
}
 

- (void)startSend 
{
    sleptAlready = NO; // NEW
    
    
    NSNumber *              fileLengthNum;
    unsigned long long      bodyLength;
    NSInputStream *         consStream;
    NSOutputStream *        prodStream;
    
     
    
    
    self.bodyPrefixData = [NSData data];
    assert(self.bodyPrefixData != nil);
    self.bodySuffixData = [NSData data];
    assert(self.bodySuffixData != nil);
    
    NSString *documentsDirectory = [NSString stringWithFormat:@"%@",self.recordingPath]; //self.recordingPath
#if DEBUG_THIS
    NSLog(@"documentsDirectory is %@",documentsDirectory);
#endif
    
    fullPathToFilex = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@",self.fileToSaveName,ext ]];
    
    fileLengthNum = (NSNumber *) [[[NSFileManager defaultManager] attributesOfItemAtPath:fullPathToFilex error:NULL] objectForKey:NSFileSize];
   // assert( [fileLengthNum isKindOfClass:[NSNumber class]] );
#if DEBUG_THIS
    NSLog(@"file size %@ fullpath is %@",fileLengthNum,fullPathToFilex);
#endif
    
    bodyLength =
    (unsigned long long) [self.bodyPrefixData length]
    + [fileLengthNum unsignedLongLongValue]
    + (unsigned long long) [self.bodySuffixData length];
    
    // Open a stream for the file we're going to send.  We open this stream
    // straight away because there's no need to delay.
    
    
    NSRunLoop *myRunLoop=[NSRunLoop currentRunLoop];
    
    NSData *data=[[NSData alloc]initWithContentsOfFile:fullPathToFilex];
    
    
    self.fileStream = [NSInputStream inputStreamWithFileAtPath:fullPathToFilex];
    

    
    [self.fileStream scheduleInRunLoop:myRunLoop forMode:NSDefaultRunLoopMode];
    
     assert(self.fileStream != nil);
    
    [self.fileStream open];
    
    // Open producer/consumer streams.  We open the producerStream straight
    // away.  We leave the consumerStream alone; NSURLConnection will deal
    // with it.
    
    [NSStream createBoundInputStream:&consStream outputStream:&prodStream bufferSize:32768];
  
     assert(consStream != nil);
     assert(prodStream != nil);
    
     self.consumerStream = consStream;
     self.producerStream = prodStream;
    
     self.producerStream.delegate = self;
    [self.producerStream scheduleInRunLoop:myRunLoop forMode:NSDefaultRunLoopMode];
    [self.producerStream open];
    
    self.recorder.delegate = self; ///// NEEWWWWWWW ///
    
     // [myRunLoop run];
    // Set up our state to send the body prefix first.
    
    self.buffer      = [self.bodyPrefixData bytes];
    self.bufferLimit = [self.bodyPrefixData length];
    
    // Open a connection for the URL, configured to POST the file.
    //api.hafizquran.com
    
    //self.webServiceURL = [NSString stringWithFormat:@"%@/%@?site_code=%@&api_key=%@",GOOGLE_API_URL,@"1.0",@"thack",@"thack-london-june-2012"];
    //NSLog(@"URL: %@",self.webServiceURL);
    
    NSString *urlString=[NSString stringWithFormat: @"%@",self.webServiceURL];
    
    request = (NSMutableURLRequest*)[self postRequestWithURL:urlString data:data fileName:nil];
    [request setTimeoutInterval:10];//1280]; // Need to put server response timeout here.
    
  //  assert(request != nil);
    /*here is an important step instead of attach data as apost data to the body you attak an inout stream
     * which is in its turn attached to an output stream that takes its data from fileStream
     */
    [request setHTTPBodyStream:self.consumerStream];
    
      self.connection = [NSURLConnection connectionWithRequest:request delegate:self];
     
    [self.producerStream open];
    
    /*create the thread to call the streamer */

     dispatch_queue_t highPriQueue =
    dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
    
    _streamDispatch = dispatch_queue_create(
                                            "AUDIO STREAM queue",
                                            DISPATCH_QUEUE_SERIAL);
    dispatch_set_target_queue(_streamDispatch, highPriQueue);
    stopSendingStupidData=NO;
    
    
    dispatch_async(_streamDispatch, ^{
        
        while (!orderToStop) {
            
            [self streamHandler:nil handleEvent:NSStreamEventHasSpaceAvailable];
            
        }
     });
    
     orderToStop=NO;
    
  
    
    [self sendDidStart];
    // }
}

- (void)stopSendWithStatus:(NSString *)statusString
{
#if DEBUG_THIS
    NSLog(@"status is %@",statusString);
#endif
    
    if (self.bufferOnHeap) {
        free(self.bufferOnHeap);
        self.bufferOnHeap = NULL;
    }
    self.buffer = NULL;
    self.bufferOffset = 0;
    self.bufferLimit  = 0;
    if (self.connection != nil) {
        [self.connection cancel];
        self.connection = nil;
    }                               
    self.bodyPrefixData = nil;
    if (self.producerStream != nil) {
        self.producerStream.delegate = nil;
        [self.producerStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        [self.producerStream close];
        self.producerStream = nil;
    }
    self.consumerStream = nil;
    if (self.fileStream != nil) {
        [self.fileStream close];
        self.fileStream = nil;
    }
    self.bodySuffixData = nil;
    [self sendDidStopWithStatus:statusString];
}
- (void)streamHandler:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode{
    @synchronized(aStream){
            //    NSLog(@"stream in handeleEvenis %@ ]n is there any buffers left %i",aStream.description,1333);
                 
                static NSInteger fullsize=0;
                 // assert(aStream == self.producerStream);
                
                switch (eventCode) {
                    case NSStreamEventOpenCompleted: {
                        NSLog(@"producer stream opened");
                    } break;
                    case NSStreamEventHasBytesAvailable: {
                        assert(NO);     // should never happen for the output stream
                    } break;
                    case NSStreamEventHasSpaceAvailable: {
                        //            if (StopSignal) {
                        //                break;
                        //            }
                        
                     //   NSLog(@"\n****NSStreamEventHasSpaceAvailable***");
                        // Check to see if we've run off the end of our buffer.  If we have,
                        // work out the next buffer of data to send.
                        
                        
                        
#if DEBUG_THIS
                        NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:soundFilePath error:nil];
                        NSLog(@"file size - %@", [fileAttributes objectForKey:NSFileSize]);
#endif
                        
                        if (self.bufferOffset == self.bufferLimit) {
#if DEBUG_THIS
                            NSLog(@"run off the end of our buffer");
#endif
                            // See if we're transitioning from the prefix to the file data.
                            // If so, allocate a file buffer.
                            
                            if (self.bodyPrefixData != nil) {
                                
                                self.bodyPrefixData = nil;
                                assert(self.bufferOnHeap == NULL);
                                self.bufferOnHeap = malloc(kPostBufferSize);
                                assert(self.bufferOnHeap != NULL);
                                self.buffer = self.bufferOnHeap;
                                
                                self.bufferOffset = 0;
                                self.bufferLimit  = 0;
                            }
                            
                            // If we still have file data to send, read the next chunk.
                            
                            if (self.fileStream != nil) {
                                NSInteger   bytesRead;
                                
                                bytesRead = [self.fileStream read:self.bufferOnHeap maxLength:kPostBufferSize];
                                
                                if (bytesRead == -1) {
                                    [self stopSendWithStatus:@"File read error"];
                                } else if (bytesRead != 0) {
#if DEBUG_THIS
                                    NSLog(@"bytes read == %li",(long)bytesRead);
#endif
                                    self.bufferOffset = 0;
                                    self.bufferLimit  = bytesRead;
                                    
                                    if (bytesRead<kPostBufferSize) {
                                     
                                       // if (!StopSignal && !sleptAlready) {
                                            NSLog(@"----GOING TO SLEEP----");
                                            //sleep(1);
                                            //sleptAlready = YES;
                                        NSInteger sleepRetVal = usleep(1000000); // /4); // LESS THAN 1 SEC MAKES LOTS OF ISSUES...
                                            NSLog(@"sleep return value = %d",sleepRetVal);
                                        
                                        //}
                                        
                                        //   usleep(1000000);
                                        //                isWaitingBuffers=YES;
                                        //  [self performSelector:@selector(retryRead:) withObject:self.producerStream afterDelay:0];
                                        
                                    }
                                }
                                else {
                                    
                                    if ( StopSignal) {
                                        //
                                        //                             [self performSelector:@selector(retryRead:) withObject:self.producerStream afterDelay:0];
                                        //
                                        //                           //  [self stream:self.producerStream handleEvent:NSStreamEventHasSpaceAvailable];
                                        //                         }else{
                                        // If we hit the end of the file, transition to sending the
                                        // suffix.
#if DEBUG_THIS
                                        NSLog(@"we hit the end of the file");
#endif
                                        [self.fileStream close];
                                        self.fileStream = nil;
                                        
                                        assert(self.bufferOnHeap != NULL);
                                        free(self.bufferOnHeap);
                                        self.bufferOnHeap = NULL;
                                        self.buffer       = [self.bodySuffixData bytes];
                                        
                                        self.bufferOffset = 0;
                                        self.bufferLimit  = [self.bodySuffixData length];
                                        
                                        //[self cleanLastRecordFile]; // NEW - 4/9/13
                                    }
                                }
                            }
                            
                            // If we've failed to produce any more data, we close the stream
                            // to indicate to NSURLConnection that we're all done.  We only do
                            // this if producerStream is still valid to avoid running it in the
                            // file read error case.
                            
                            if ( (self.bufferOffset == self.bufferLimit) && (self.producerStream != nil) ) {
                                NSLog(@"close the producer stream");
                                // We set our delegate callback to nil because we don't want to
                                // be called anymore for this stream.  However, we can't
                                // remove the stream from the runloop (doing so prevents the
                                // URL from ever completing) and nor can we nil out our
                                // stream reference (that causes all sorts of wacky crashes).
                                //
                                // +++ Need bug numbers for these problems.
                                if (StopSignal) {
                                    NSLog(@"close the producer stream got  a stop signal");
                                    orderToStop=YES;
                                    
                                    self.producerStream.delegate = nil;
                                    // [self.producerStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
                                    [self.producerStream close];
                                    if (self.streamerDelegate &&[self.streamerDelegate respondsToSelector:@selector(MOAudioStreamerDidFinishStreaming:)]) {
                                        [self.streamerDelegate MOAudioStreamerDidFinishStreaming:self];
                                    }
                                    
                                   ///// [self removeRecordableFile]; // NEW //
                                   // [self cleanLastRecordFile]; // NEW - 4/9/13
                                    
                                }
                                // self.producerStream = nil;
                            }
                        }
                        
                        // Send the next chunk of data in our buffer.
                        
                        if (self.bufferOffset != self.bufferLimit) {
                            NSInteger   bytesWritten;
                            //                bytesWritten = [self.producerStream write:&self.buffer[self.bufferOffset] maxLength:self.bufferLimit - self.bufferOffset];
                            int maxlengt;
                           /* if (StopSignal) {
                                maxlengt=(self.bufferLimit - self.bufferOffset);
                            }else{
                                maxlengt=1;
                            }*/
                            
                            //maxlengt = 1; /// DEBUG /////
                               maxlengt=(self.bufferLimit - self.bufferOffset);
                            //assert(maxlengt!=0);
                           // if (self.buffer != nil) {
                                bytesWritten = [self.producerStream write:&self.buffer[self.bufferOffset] maxLength:maxlengt];
                           // }else{
                           //     bytesWritten =0;
                           // }
                            
                            
                            if (bytesWritten <= 0) {
                                if (self.streamerDelegate &&[self.streamerDelegate respondsToSelector:@selector(MOAudioStreamerDidFailed:message:)]) {
                                    [self.streamerDelegate MOAudioStreamerDidFailed:self message:NSLocalizedString(@"network write error", nil)];
                                }
                                [self stopSendWithStatus:@"Network write error"];
                            } else {
                                self.bufferOffset += bytesWritten;
                            }
                            fullsize+=bytesWritten;
                            NSLog(@"sendding the next chunk buffer offset is %li max length is %li",(long)fullsize,self.bufferLimit - self.bufferOffset);
                            
                        }
                    } break;
                    case NSStreamEventErrorOccurred: {
                        #if DEBUG_THIS
                        NSLog(@"producer stream error %@", [aStream streamError]);
#endif
                        [self stopSendWithStatus:@"Stream open error"];
                    } break;
                    case NSStreamEventEndEncountered: {
                        // assert(NO);     // should never happen for the output stream
                    } break;
                    default: {
                        assert(NO);
                    } break;
                }
                
            }
                
        
    

}

 


#pragma mark connection Delegate

- (void)connection:(NSURLConnection *)theConnection didReceiveResponse:(NSURLResponse *)response
// A delegate method called by the NSURLConnection when the request/response
// exchange is complete.  We look at the response to check that the HTTP
// status code is 2xx.  If it isn't, we fail right now.
{

    // NSLog(@"did receive response");
    if (self.connection) {
         
    
#pragma unused(theConnection)
    NSHTTPURLResponse * httpResponse;
    
   // assert(theConnection == self.connection);
    
    httpResponse = (NSHTTPURLResponse *) response;
    assert( [httpResponse isKindOfClass:[NSHTTPURLResponse class]] );
        NSLog(@"httpresponse for streamer header is %@",[httpResponse allHeaderFields]);
    if ((httpResponse.statusCode / 100) != 2) {
        NSLog(@"HTTP error");
        [self stopSendWithStatus:[NSString stringWithFormat:@"HTTP error %zd", (ssize_t) httpResponse.statusCode]];
    }
    else {
        //[self stopSendWithStatus:@"RECIVED RESPONSE WITH NO ERROR"]; // NEW - 4/9/13
     }
       
    
}//end of self.connection if
    [self.streamerDelegate MOAudioStreamerConnection:theConnection didReceiveResponse:response]; //NEW
}

- (void)connection:(NSURLConnection *)theConnection didReceiveData:(NSData *)data
// A delegate method called by the NSURLConnection as data arrives.  The
// response data for a POST is only for useful for debugging purposes,
// so we just drop it on the floor.
{
#pragma unused(theConnection)
#pragma used(data)
    #if DEBUG_THIS
     NSLog(@"nscpnnection did receive data");
#endif
    if (self.connection) {

        if (!responseData) {
     //    NSLog(@"response data is nilllll");
        responseData=[NSMutableData new];
        }
    
        [responseData appendData:data];
 
        [self stopSendWithStatus:@"RECIVED RESPONSE WITH NO ERROR"]; // NEW - 4/9/13
    // do nothing
        
    }else{
        NSLog(@"self.connection audiostreamer.m is null");
    }
    [self.streamerDelegate MOAudioStreamerConnection:theConnection didReceiveData:data]; // NEW
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
   // NSLog(@"connection failed with error %@",error.description);
    [self stopSendWithStatus:@"Connection failed"];
    connectionError=error;
    
    if (self.streamerDelegate &&[self.streamerDelegate respondsToSelector:@selector(MOAudioStreamerDidFailed:message:)]) {
        [self.streamerDelegate MOAudioStreamerDidFailed:self message:connectionError.localizedDescription ];
    }
    }
    [self.streamerDelegate MOAudioStreamerConnection:theConnection didFailWithError:error]; // NEW
}

- (void)connectionDidFinishLoading:(NSURLConnection *)theConnection
// A delegate method called by the NSURLConnection when the connection has been
// done successfully.  We shut down the connection with a nil status, which
// causes the image to be displayed.
{
    if (self.connection) {
        stopSendingStupidData=YES;
#pragma unused(theConnection)
    
    if (giveMeResults ) {
        NSLog(@"lets see results");
    NSString *String =[[NSString alloc]initWithData:responseData encoding:NSUTF8StringEncoding];
        //    [self.streamerDelegate MOAudioStreamerDidFinishRequest:theConnection withResponse:String];
        if (!responseData) {
          
            if (self.streamerDelegate &&[self.streamerDelegate respondsToSelector:@selector(MOAudioStreamerDidFailed:message:)]) {
                [self.streamerDelegate MOAudioStreamerDidFailed:self message:NSLocalizedString(@"connection finished loading with no response", nil) ];
            }
        }else{
            if (self.streamerDelegate &&[self.streamerDelegate respondsToSelector:@selector(MOAudioStreamerDidFinishRequest:withResponse:)]) {
                [self.streamerDelegate MOAudioStreamerDidFinishRequest:theConnection withResponse:String];
            }else{
        NSLog(@"it does not respond to selector streamdidFinishRequest");
            }
        }
        giveMeResults=NO;

    }
    responseData=nil;
#if DEBUG_THIS
    NSLog(@"connection did data length ");
#endif
   // assert(theConnection == self.connection);
    
    [self stopSendWithStatus:@"end connection"];
    }
    
    [self.streamerDelegate MOAudioStreamerConnectionDidFinishLoading:theConnection]; // NEW
}

#pragma mark * Actions
- (void)startStreamer;
{
    NSLog(@"startStreamer");
    
         giveMeResults=YES;
    StopSignal=NO;
    
        [self setupNewRocordableFile ];
    
 
   //[self performSelector:@selector(startSend) withObject:[NSNull null] afterDelay:0.5];//0.5];
    
  
 //[self performSelector:@selector(startSend) withObject:[NSNull null] ];
    
           StopSignal=NO;
    
}
-(void)stopStreaming{
    NSLog(@"lets Stop streaming");
    if (self.recorder !=nil) {
        [self.recorder stopRecording];
    }
    
    
    //[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(startSend) object:[NSNull null]];
    
    StopSignal=YES;
    
    //[self performSelector:@selector(removeRecordableFile) withObject:[NSNull null] afterDelay:0.5];
    //[self removeRecordableFile];
}
 - (void)cancelStreaming
{
     [self stopSendWithStatus:@"Cancelled"];
    
    if (self.recorder!=nil) {
        [self.recorder stopRecording]; // NEW //
    }
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(startSend) object:[NSNull null]];
    
     StopSignal=YES; // NEW //
    
    //[self removeRecordableFile];
   // [self cleanLastRecordFile]; // NEW - 4/9/13
}



 #pragma mark * URL Request
NSString *fullPathToFilex;

 
- (NSString *)getEncodedHeader {
    NSString *userNamex =self.userName;
    
    NSLog(@"username is %@",userNamex);
    //hashed md5 password//e10adc3949ba59abbe56e057f20f883e
    NSString *passowrd =self.password;
    //NSLog(@"password is %@",passowrd);
    // NSString *paswordMD5=[[passowrd dataUsingEncoding:NSUTF8StringEncoding]md5];
    NSData *authData1 = [userNamex dataUsingEncoding:NSASCIIStringEncoding];
    //encoded username
    
    NSString *encodedUsername = [NSString stringWithString: [authData1 base64Encoding]];
    //username + : + password
    
    NSString *combined =[NSString stringWithFormat:@"%@:%@",  encodedUsername,passowrd ];
    //encoded combined
    
    NSString *encodedEveryThing= [NSString stringWithString:[[combined dataUsingEncoding:NSUTF8StringEncoding] base64Encoding]];
    return encodedEveryThing;
}

-(NSURLRequest *)postRequestWithURL: (NSString *)url

                               data: (NSData *)aData
                           fileName: (NSString*)fileName
{
   // fileName=@"";
    aData=nil;
    
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestUseProtocolCachePolicy   timeoutInterval:240];
    
    [urlRequest setHTTPMethod:@"POST"];
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
    
    if ([fileManager removeItemAtPath:dataPath error:nil]) {
        NSLog(@"RemoveFileSuccesfully");
    }

}

-(void)cleanLastRecordFile{
    
    self.recorder = nil; // Comment on singleton
    //[[Recorder sharedInstance] cleanRecorder];
    [self removeRecordableFile];
}
-(void)setupNewRocordableFile{
    [self cleanLastRecordFile];
    
    NSFileManager *fileManager=[NSFileManager defaultManager];
    
    
    NSString *dataPath= [NSString stringWithString: self.recordingPath];
    
    if (![fileManager fileExistsAtPath:dataPath isDirectory:nil]) {
        
        BOOL success = [fileManager createDirectoryAtPath:dataPath withIntermediateDirectories:NO attributes:nil error:nil];
        NSLog(@"success in creating recordedSounds Dir is: %i", success);
        
    }else{ // NEw /////////
        
    }
    
    if (!self.fileToSaveName || [self.fileToSaveName isEqualToString:@""]) {
        self.fileToSaveName=@"temp";
    }
    
    soundFilePath = [NSString stringWithString: [dataPath
                     stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@",self.fileToSaveName,ext ]]];
    
    self.recorder = [[Recorder alloc] init];
    assert(self.recorder!=nil); // NEW
    self.recorder.savedPath = soundFilePath;
    self.recorder.delegate = self;
    
    [self.recorder startRecording];
    /*assert([Recorder sharedInstance]!=nil); // NEW
    [Recorder sharedInstance].savedPath = soundFilePath;
    [Recorder sharedInstance].delegate = self;
    
    [[Recorder sharedInstance] startRecording];*/
}

 

- (void)dealloc
{
    // Because NSURLConnection retains its delegate until the connection finishes, and
    // any time the connection finishes we call -stopSendWithStatus: to clean everything
    // up, we can't be deallocated with a connection in progress.
    assert(self->_connection == nil);
    
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
    NSLog(@"AudioStreamer - recorderMicLevelCallbackAverage:andPeak");
#endif
    
    
    if([self.streamerDelegate respondsToSelector:@selector(MORecorderMicLevelCallbackAverage:andPeak:)]){
        
        [self.streamerDelegate MORecorderMicLevelCallbackAverage:averagePower andPeak:peakPower];
        
    }else{
        NSLog(@"Error: You haven't implemented MORecorderMicLevelCallbackAverage, It is a must. Please implement this one");
    }
    //- (void)MORecorderMicLevelCallbackAverage: (float)averagePower andPeak: (float)peakPower
}

-(float)averagePower{
    return [self.recorder averagePower];
}

-(float)peakPower{
    return [self.recorder peakPower];
}

- (void)recordFileWasCreated
{
    [self startSend];
}

@end
