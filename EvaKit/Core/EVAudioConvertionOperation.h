//
//  EVAudioConvertionOperation.h
//  EvaKit
//
//  Created by Yegor Popovych on 7/31/15.
//  Copyright (c) 2015 Evature. All rights reserved.
//

#import "EVAudioChainOperation.h"

@interface EVAudioConvertionOperation : EVAudioChainOperation

@property (nonatomic, assign) unsigned int numberOfChannels;
@property (nonatomic, assign) unsigned int bitsPerSample;
@property (nonatomic, assign) unsigned int sampleRate;

@property (nonatomic, assign) unsigned int flacBufferMaxSamples;

//This option used for precalculations in encoder. Can be 0
@property (nonatomic, assign) unsigned int maxRecordingTime;

- (id)initWithErrorHandler:(id<EVErrorHandler>)errorHandler;

@end
