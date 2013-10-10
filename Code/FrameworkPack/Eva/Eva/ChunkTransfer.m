//
//  ChunkTransfer.m
//  Eva
//
//  Created by idan S on 8/18/13.
//  Copyright (c) 2013 Evature. All rights reserved.
//

#import "ChunkTransfer.h"

@implementation ChunkTransfer
//@synthesize connection = connection_;
@synthesize iStream = _iStream;
@synthesize oStream = _oStream;

    

+ (ChunkTransfer *)sharedInstance
{
    static ChunkTransfer *sharedInstance = nil;
	if (sharedInstance == nil)
	{
		sharedInstance = [[ChunkTransfer alloc] init];
        
	}
	return sharedInstance;
}


- (BOOL)initWithURL: (NSURL *)url withRequest:(NSMutableURLRequest *)request andConnection:(NSURLConnection *)connectionRef 
{
    NSLog(@"initWithURL:withRequest");
    
    CFReadStreamRef readStream;
    CFWriteStreamRef writeStream;
    CFStreamCreateBoundPair(NULL, &readStream, &writeStream, 8192);

    self.iStream = (__bridge NSInputStream *)readStream;
    self.oStream = (__bridge NSOutputStream *)writeStream;

    self.iStream.delegate = self;
    self.oStream.delegate = self;

    [self.oStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [self.oStream open];

    [request setHTTPBodyStream:self.iStream];

    /*connectionRef = [[NSURLConnection alloc] initWithRequest:request delegate:self.superclass // superclass is new
                                            startImmediately:NO]; // Was yes before chunked

    NSString *runloopmode = [[NSRunLoop currentRunLoop] currentMode];
    [connectionRef scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:runloopmode];

    
    [connectionRef start];
        

    // NEW - Below dispatch is new to not block the process (that was the issue with callback)
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,  
                                             (unsigned long)NULL), ^(void) {

        while (!finished) {
            [[NSRunLoop currentRunLoop] runMode:runloopmode beforeDate:[NSDate distantFuture]];
        }
    });*/
    
    return TRUE;
}

- (void)sendNextChunk
{
    NSLog(@"sendNextChunk");
    if ([self.dataQueue count] == 0)
        return;
    
    if (self.iStream.streamStatus == NSStreamStatusNotOpen ||
        self.iStream.streamStatus == NSStreamStatusOpening ||
        self.iStream.streamStatus == NSStreamStatusClosed ||
        self.iStream.streamStatus == NSStreamStatusError)
    {
        return;
    }
    
    NSData *chunk = [self.dataQueue objectAtIndex:0];
    
    NSMutableData *outgoingData = [[NSMutableData alloc] init];
    [outgoingData appendData:chunk];
    
    NSUInteger bytesWritten = [self.oStream write:outgoingData.bytes maxLength:outgoingData.length];
    if (bytesWritten == outgoingData.length)
        [self.dataQueue removeObjectAtIndex:0];
    else
    {
        NSData *remainder = [outgoingData subdataWithRange:NSMakeRange(bytesWritten, outgoingData.length - bytesWritten)];
        [self.dataQueue replaceObjectAtIndex:0 withObject:remainder];
    }
}

- (void)sendEndChunkAndCloseStream
{
    NSLog(@"sendEndChunkAndCloseStream");
    if (self.dataBuffer.length)
    {
        
         [self.dataBuffer appendData:[@"\r\n" dataUsingEncoding: NSUTF8StringEncoding]]; // NEW
        [self.dataQueue addObject:self.dataBuffer];
        self.dataBuffer = nil;
        [self sendNextChunk];
    }
    
    [self.oStream close];
    [self.oStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    self.oStream = nil;
}

- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode
{
    NSLog(@"stream:handleEvent");
    
    
    if (self.oStream == aStream)
    {
        switch (eventCode)
        {
            case NSStreamEventHasSpaceAvailable:
            {
                @synchronized(self)
                {
                    if (self.dataQueue.count)
                        [self sendNextChunk];
                    else if (self.isEndOfData)
                        [self sendEndChunkAndCloseStream];
                }
            }
                break;
                
            case NSStreamEventOpenCompleted :
                NSLog(@"NSStreamEventOpenCompleted");
                break;
            case NSStreamEventHasBytesAvailable :
                NSLog(@"NSStreamEventHasBytesAvailable");
                break;
            case NSStreamEventErrorOccurred :
                NSLog(@"NSStreamEventErrorOccurred");
                break;
            case NSStreamEventEndEncountered :
                NSLog(@"NSStreamEventEndEncountered");
                break;
            default:
                
                break;
        }
    }
    
    if (self.iStream == aStream) {
        switch (eventCode)
        {
            case NSStreamEventHasBytesAvailable:
            {
                NSLog(@"NSStreamEventHasBytesAvailable");
            }
                break;
            default:
                break;
        }

    }
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    // You may have received an HTTP 200 here, or not...
    NSLog(@"didReceiveResponse");
    
}



@end
