//
//  EVAudioChainOperation.m
//  EvaKit
//
//  Created by Yegor Popovych on 7/30/15.
//  Copyright (c) 2015 Evature. All rights reserved.
//

#import "EVAudioChainOperation.h"
#import "EVLogger.h"

@interface EVAudioChainOperation () {
    dispatch_queue_t _queue;
    dispatch_semaphore_t _queueSemaphore;
    BOOL _cancelled;
}

@property (nonatomic, strong) NSMutableSet* producers;

// Send data to next in chain
- (void)sendDataToConsumer:(NSData*)data;
- (void)checkAndWaitForSpaceInQueue;

@end

@implementation EVAudioChainOperation

@synthesize errorHandler;
@synthesize dataConsumer;
@dynamic operationQueue;

- (instancetype)init {
    return [self initWithOperationChainLength:5];
}

- (instancetype)initWithOperationChainLength:(NSUInteger)length {
    self = [super init];
    if (self != nil) {
        _queue = dispatch_queue_create(NULL, DISPATCH_QUEUE_SERIAL);
        _queueSemaphore = dispatch_semaphore_create(length);
        self.producers = [NSMutableSet set];
    }
    return self;
}

- (void)dealloc {
    dispatch_release(_queue);
    dispatch_release(_queueSemaphore);
    self.producers = nil;
    [super dealloc];
}

- (void)sendDataToConsumer:(NSData*)data {
    [self.dataConsumer producer:self hasNewData:data];
}

- (dispatch_queue_t)operationQueue {
    return _queue;
}


- (void)producerStarted:(id<EVDataProducer>)producer {
    _cancelled = NO;
    [self checkAndWaitForSpaceInQueue];
    [producer retain];
    dispatch_async(_queue, ^{
        [producer autorelease];
        [self.producers addObject:producer];
        [self.dataConsumer producerStarted:self];
        dispatch_semaphore_signal(_queueSemaphore);
    });
}

- (void)producerFinished:(id<EVDataProducer>)producer {
    [self checkAndWaitForSpaceInQueue];
    [producer retain];
    dispatch_async(_queue, ^{
        [producer autorelease];
        [self.producers removeObject:producer];
        [self.dataConsumer producerFinished:self];
        dispatch_semaphore_signal(_queueSemaphore);
    });
}

- (void)checkAndWaitForSpaceInQueue {
    if (dispatch_semaphore_wait(_queueSemaphore, DISPATCH_TIME_NOW) != 0) {
        EV_LOG_INFO(@"Queue is full in operation: %@, change length or speedup task", self);
        dispatch_semaphore_wait(_queueSemaphore, DISPATCH_TIME_FOREVER);
    }
}

- (void)producer:(id<EVDataProducer>)producer hasNewData:(NSData*)data {
    if (_cancelled) return;
    [self checkAndWaitForSpaceInQueue];
    [data retain];
    dispatch_async(_queue, ^{
        [data autorelease];
        NSError* error = nil;
        NSData* pData = [self processData:data error:&error];
        if (error != nil) {
            [self.errorHandler provider:self gotAnError:error];
        } else {
            [self sendDataToConsumer:pData];
        }
        dispatch_semaphore_signal(_queueSemaphore);
    });
}

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

-(void)cancel {
    _cancelled = YES;
}

// Overload this method and implement operation logic
- (NSData*)processData:(NSData*)data error:(NSError**)error {
    EV_LOG_ERROR(@"Reload - (NSData*)processData:(NSData*)data error:(NSError**)error method");
    NSAssert(false, @"Reload - (NSData*)processData:(NSData*)data error:(NSError**)error method");
    return nil;
}

@end
