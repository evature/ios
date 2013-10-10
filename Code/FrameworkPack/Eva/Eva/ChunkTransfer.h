//
//  ChunkTransfer.h
//  Eva
//
//  Created by idan S on 8/18/13.
//  Copyright (c) 2013 Evature. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

@interface ChunkTransfer : NSObject <NSStreamDelegate>{
    NSInputStream *iStream;
    NSOutputStream *oStream;
    
    BOOL finished;
}

@property (nonatomic, strong) NSInputStream *iStream;
@property (nonatomic, strong) NSOutputStream *oStream;

@property(nonatomic, strong) NSURLConnection * connection;
@property (nonatomic, assign) BOOL isEndOfData;
@property (nonatomic, strong) NSMutableData *dataBuffer;
@property (nonatomic, strong) NSMutableArray *dataQueue;

+ (ChunkTransfer *)sharedInstance;
- (BOOL)initWithURL:(NSURL *)url withRequest:(NSMutableURLRequest *)request andConnection:(NSURLConnection *)connection;
- (void)sendEndChunkAndCloseStream;
- (void)sendNextChunk;

@end
