//
//  EVAudioChainOperation.m
//  EvaKit
//
//  Created by Yegor Popovych on 7/30/15.
//  Copyright (c) 2015 Evature. All rights reserved.
//

#import "EVAudioChainOperation.h"

@interface EVAudioChainOperation () {
    dispatch_queue_t _queue;
    dispatch_semaphore_t _queueSemaphore;
    BOOL _cancelled;
}

@property (nonatomic, strong) NSMutableSet* providers;

// Send data to next in chain
- (void)sendDataToConsumer:(NSData*)data;
- (void)sendErrorToConsumer:(NSError*)error;
- (void)checkAndWaitForSpaceInQueue;

@end

@implementation EVAudioChainOperation

@synthesize dataProviderDelegate;
@dynamic operationQueue;

- (instancetype)init {
    return [self initWithOperationChainLength:5];
}

- (instancetype)initWithOperationChainLength:(NSUInteger)length {
    self = [super init];
    if (self != nil) {
        _queue = dispatch_queue_create(NULL, DISPATCH_QUEUE_SERIAL);
        _queueSemaphore = dispatch_semaphore_create(length);
        self.providers = [NSMutableSet set];
    }
    return self;
}

- (void)dealloc {
    dispatch_release(_queue);
    dispatch_release(_queueSemaphore);
    [super dealloc];
}

- (void)sendErrorToConsumer:(NSError*)error {
    [self.dataProviderDelegate provider:self gotAnError:error];
}

- (void)sendDataToConsumer:(NSData*)data {
    [self.dataProviderDelegate provider:self hasNewData:data];
}

- (dispatch_queue_t)operationQueue {
    return _queue;
}

- (void)stopDataProvider {
    _cancelled = YES;
    dispatch_async(_queue, ^{
        for (id<EVDataProvider> provider in self.providers) {
            [provider stopDataProvider];
        }
    });
}

- (void)providerStarted:(id<EVDataProvider>)provider {
    _cancelled = NO;
    [self checkAndWaitForSpaceInQueue];
    [provider retain];
    dispatch_async(_queue, ^{
        [provider autorelease];
        [self.providers addObject:provider];
        [self.dataProviderDelegate providerStarted:self];
        dispatch_semaphore_signal(_queueSemaphore);
    });
}

- (void)providerFinished:(id<EVDataProvider>)provider {
    [self checkAndWaitForSpaceInQueue];
    [provider retain];
    dispatch_async(_queue, ^{
        [provider autorelease];
        [self.providers removeObject:provider];
        [self.dataProviderDelegate providerFinished:self];
        dispatch_semaphore_signal(_queueSemaphore);
    });
}

- (void)checkAndWaitForSpaceInQueue {
    if (dispatch_semaphore_wait(_queueSemaphore, DISPATCH_TIME_NOW) != 0) {
        if (self.isDebugMode) {
            NSLog(@"Queue is full in operation: %@, change length or speedup task", self);
        }
        dispatch_semaphore_wait(_queueSemaphore, DISPATCH_TIME_FOREVER);
    }
}

- (void)provider:(id<EVDataProvider>)provider hasNewData:(NSData*)data {
    if (_cancelled) return;
    [self checkAndWaitForSpaceInQueue];
    [data retain];
    dispatch_async(_queue, ^{
        [data autorelease];
        NSError* error = nil;
        NSData* pData = [self processData:data error:&error];
        if (error != nil) {
            [provider stopDataProvider];
            [self sendErrorToConsumer:error];
        } else {
            [self sendDataToConsumer:pData];
        }
        dispatch_semaphore_signal(_queueSemaphore);
    });
}

- (void)provider:(id<EVDataProvider>)provider gotAnError:(NSError*)error {
    [error retain];
    [provider retain];
    dispatch_async(_queue, ^{
        [error autorelease];
        [provider autorelease];
        [self.providers removeObject:provider];
        [self sendErrorToConsumer:error];
    });
}


// Overload this method and implement operation logic
- (NSData*)processData:(NSData*)data error:(NSError**)error {
    NSAssert(false, @"Reload - (NSData*)processData:(NSData*)data error:(NSError**)error method");
    return nil;
}

@end
