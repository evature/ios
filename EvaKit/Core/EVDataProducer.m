//
//  EVDataProducer.m
//  EvaKit
//
//

#import <Foundation/Foundation.h>
#import "EVDataProducer.h"
#import "EVLogger.h"


@implementation EVDataNode : NSObject

- (instancetype) initWithName:(NSString*)name andErrorHandler:(id<EVErrorHandler>) errorHandler {
    self = [super init];
    if (self != NULL) {
        _name = [name retain];
        _errorHandler = errorHandler;
        _canceled = NO;
        EV_LOG_DEBUG(@"Node %@ was initialized", _name);
    }
    return self;
}
- (void)cancel {
    EV_LOG_DEBUG(@"Node %@ was canceled", _name);
    self.canceled = YES;
}

- (void)dealloc {
    EV_LOG_DEBUG(@"Node %@ was dealloc", _name);
    _errorHandler = nil;
    [self.name release];
    _name = nil;
    [super dealloc];
}

@end


@interface EVDataProducer () {
    dispatch_queue_t _queue;
    dispatch_semaphore_t _queueSemaphore;
}

@property (nonatomic, strong) NSMutableSet* producers;


@end

@implementation EVDataProducer : EVDataNode

@synthesize dataConsumer;

- (instancetype)initWithName:(NSString*)name andErrorHandler:(id<EVErrorHandler>) errorHandler {
    return [self initWithOperationChainLength:10 andName:name andErrorHandler:errorHandler];
}

- (instancetype)initWithOperationChainLength:(NSUInteger)length  andName:(NSString*)name andErrorHandler:(id<EVErrorHandler>) errorHandler {
    self = [super initWithName:name andErrorHandler:errorHandler];
    if (self != NULL) {
        _queue = dispatch_queue_create([[NSString stringWithFormat:@"Queue of %@", self.name] UTF8String], DISPATCH_QUEUE_SERIAL);
        _queueSemaphore = dispatch_semaphore_create(length);
    }
    return self;
}

- (void)dealloc {
    dispatch_release(_queue);
    dispatch_release(_queueSemaphore);
    [super dealloc];
}

- (dispatch_queue_t) getOperationQueue {
    return _queue;
}

- (void)checkAndWaitForSpaceInQueue {
//    EV_LOG_DEBUG(@"Waiting for space for %@", self.name);
    if (dispatch_semaphore_wait(_queueSemaphore, DISPATCH_TIME_NOW) != 0) {
        EV_LOG_INFO(@"--> --> --> Queue is full in operation: %@, change length or speedup task", self);
        dispatch_semaphore_wait(_queueSemaphore, DISPATCH_TIME_FOREVER);
        EV_LOG_INFO(@"--> --> --> Got Semaphore for operation queue %@", self);
    }
//    EV_LOG_DEBUG(@"Got space for %@", self.name);
}


/////////
// Propagate methods (except cancel) activate the consumer handling in async, background thread, threadsafe, FIFO


// producerStarted:   cancelable, initializes object
- (void)propagateProducerStarted {
    EV_LOG_DEBUG(@"Propagating producer started %@", self.name);
    self.canceled = NO;
    if ([[self dataConsumer] respondsToSelector:@selector(producerStarted:)]) {
        [self checkAndWaitForSpaceInQueue];
        dispatch_async(_queue, ^{
            EV_LOG_DEBUG(@"Producer started %@", self.name);
            if (self.canceled) {
                EV_LOG_DEBUG(@"Producer was canceled - not propagating %@", self.name);
                return;
            }
            [[self dataConsumer] producerStarted:self];
            dispatch_semaphore_signal(_queueSemaphore);
        });
    }
}


// produerFinished:  NOT cancelable, releases resources
- (void)propagateProducerFinished {
    EV_LOG_DEBUG(@"Propagating producer finished %@", self.name);
    if ([[self dataConsumer] respondsToSelector:@selector(producerFinished:)]) {
        [self checkAndWaitForSpaceInQueue];
        dispatch_async(_queue, ^{
            EV_LOG_DEBUG(@"Producer finished %@", self.name);
            [[self dataConsumer] producerFinished:self];
            dispatch_semaphore_signal(_queueSemaphore);
        });
    }
}


// producerStarted:   cancelable, processes a chunk of data
- (void)propagateHasNewData:(NSData*)data {
    //EV_LOG_DEBUG(@"Propagating %@ has a new chunk len= %lu", self.name,  (unsigned long)[data length]);
    if (self.canceled) {
        EV_LOG_DEBUG(@"Producer was canceled - not propagating %@ new data", self.name);
        return;
    }
    [self checkAndWaitForSpaceInQueue];
    [data retain];
    dispatch_async(_queue, ^{
        [data autorelease];
        //EV_LOG_DEBUG(@"Producer has new chunk %@  data len = %lu", self.name, (unsigned long)[data length]);
        if (self.canceled) {
            EV_LOG_DEBUG(@"Producer was canceled - not propagating %@ new data", self.name);
            return;
        }
        [[self dataConsumer] producer:self hasNewData:data];
        dispatch_semaphore_signal(_queueSemaphore);
    });
}


// cancel does not use the async FIFO, but immediately propagates on the main thread
- (void)propagateCancel {
    EV_LOG_DEBUG(@"Propagating cancel %@", self.name);
    [[self dataConsumer] cancel];
}

- (void)cancel {
    [super cancel];
    [self propagateCancel];
}

@end
