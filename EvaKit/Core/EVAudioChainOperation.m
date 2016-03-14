//
//  EVAudioChainOperation.m
//  EvaKit
//
//  Created by Yegor Popovych on 7/30/15.
//  Copyright (c) 2015 Evature. All rights reserved.
//

#import "EVAudioChainOperation.h"
#import "EVLogger.h"



@implementation EVAudioChainOperation



/*
- (void)producer:(id<EVDataProducer>)producer gotAnError:(NSError*)error {
    [error retain];
    [producer retain];
    dispatch_async(_queue, ^{
        [error autorelease];
        [producer autorelease];
        [self.producers removeObject:producer];
        [self sendErrorToConsumer:error];
    });
}*/

- (void)producerStarted:(EVDataProducer*)producer {
    EV_LOG_DEBUG(@"node %@ - producer %@ started", self.name, producer.name);
    [self propagateProducerStarted];
}
- (void)producerFinished:(EVDataProducer*)producer {
    EV_LOG_DEBUG(@"node %@ - producer %@ finished", self.name, producer.name);
    [self propagateProducerFinished];
}

- (void)producer:(EVDataProducer*)producer hasNewData:(NSData*)data {
    if (data == NULL || ![data length]) {
        EV_LOG_ERROR(@"No data sent to hasNewData ?");
        return;
    }
    NSError* error = nil;
    NSData* processedData = [self processData:data error:&error];
    if (error != nil) {
        [self.errorHandler node:self gotAnError:error];
    } else {
        if (processedData != NULL && [processedData length]) {
            [self propagateHasNewData:processedData];
        }
    }
}

// Overload this method and implement operation logic
- (NSData*)processData:(NSData*)data error:(NSError**)error {
    EV_LOG_ERROR(@"%@ Does not implement - (NSData*)processData:(NSData*)data error:(NSError**)error method", self.name);
    NSAssert(false, @"Reload - (NSData*)processData:(NSData*)data error:(NSError**)error method");
    return nil;
}

@end
