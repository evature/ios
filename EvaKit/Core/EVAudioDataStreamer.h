//
//  EVAudioDataStreamer.h
//  EvaKit
//
//  Created by Yegor Popovych on 8/5/15.
//  Copyright (c) 2015 Evature. All rights reserved.
//

#import "EVAudioChainOperation.h"
#import "NSError+EVA.h"

#define EVAudioDataStreamerCreateErrorCode ERROR_STR_TO_CODE("EDSC")

@protocol EVAudioDataStreamerDelegate;

@interface EVAudioDataStreamer : EVAudioChainOperation

@property (nonatomic, assign, readwrite) unsigned int sampleRate;
@property (nonatomic, assign, readwrite) NSUInteger httpBufferSize;
@property (nonatomic, strong, readwrite) NSURL* webServiceURL;
@property (nonatomic, assign, readwrite) NSTimeInterval connectionTimeout;
@property (nonatomic, assign, readwrite) id<EVAudioDataStreamerDelegate> delegate;

- (void)cancel;

@end

@protocol EVAudioDataStreamerDelegate <NSObject>

- (void)audioDataStreamerFinished:(EVAudioDataStreamer *)streamer withResponse:(NSDictionary*)response;
                                 
@end