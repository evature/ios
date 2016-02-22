//
//  EVDataProvider.h
//  EvaKit
//
//  Created by Yegor Popovych on 7/30/15.
//  Copyright (c) 2015 Evature. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol EVDataConsumer;
@protocol EVErrorHandler;

@protocol EVDataProducer <NSObject>

@property (nonatomic, assign, readwrite) id<EVDataConsumer> dataConsumer;
@property (nonatomic, assign, readwrite) id<EVErrorHandler> errorHandler;


@end


@protocol EVDataConsumer <NSObject>

@required
- (void)producer:(id<EVDataProducer>)producer hasNewData:(NSData*)data;
@property (nonatomic, assign, readwrite) id<EVErrorHandler> errorHandler;

@optional
- (void)producerStarted:(id<EVDataProducer>)producer;
- (void)producerFinished:(id<EVDataProducer>)producer;
@end



@protocol EVErrorHandler <NSObject>

- (void)provider:(id<NSObject>)provider gotAnError:(NSError*)error;  //either consumer or producer

@end