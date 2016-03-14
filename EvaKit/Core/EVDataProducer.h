//
//  EVDataProvider.h
//  EvaKit
//
//  Created by Yegor Popovych on 7/30/15.
//  Copyright (c) 2015 Evature. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol EVErrorHandler;
@protocol EVDataConsumer;

// Nodes have a name (for debug) and can be canceled or notify an error
@interface EVDataNode : NSObject
- (instancetype) initWithName:(NSString*)name andErrorHandler:(id<EVErrorHandler>) errorHandler;
- (void)cancel;

@property (atomic, assign, readwrite) bool canceled;
@property (nonatomic, strong, readonly) NSString* name;
@property (nonatomic, strong, readwrite) id<EVErrorHandler> errorHandler;

@end


// producer has a FIFO queue of operations it produced,  and a consumer which handles these operations
@interface EVDataProducer: EVDataNode

// async Fifo, pass the events to the consumer
- (void)propagateCancel;
- (void)propagateProducerStarted;
- (void)propagateProducerFinished;
- (void)propagateHasNewData:(NSData*)data;
        
- (void)checkAndWaitForSpaceInQueue;

- (instancetype)initWithOperationChainLength:(NSUInteger)length  andName:(NSString*)name andErrorHandler:(id<EVErrorHandler>) errorHandler;

@property (nonatomic, assign, readwrite) EVDataNode<EVDataConsumer>* dataConsumer;
@property (nonatomic, assign, readonly, getter=getOperationQueue) dispatch_queue_t operationQueue;


@end


// Consumer processes the events
@protocol EVDataConsumer
- (void)producer:(EVDataProducer*)producer hasNewData:(NSData*)data;
@optional
- (void)producerStarted:(EVDataProducer*)producer;
- (void)producerFinished:(EVDataProducer*)producer;
@end



@protocol EVErrorHandler <NSObject>
- (void)node:(EVDataNode*)node gotAnError:(NSError*)error;  //either consumer or producer
@end