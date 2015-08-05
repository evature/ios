//
//  EVAudioChainOperation.h
//  EvaKit
//
//  Created by Yegor Popovych on 7/30/15.
//  Copyright (c) 2015 Evature. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EVDataProvider.h"
#import <dispatch/dispatch.h>

@interface EVAudioChainOperation : NSObject <EVDataProvider, EVDataProviderDelegate>

@property (nonatomic, assign, readonly) dispatch_queue_t operationQueue;

@property (nonatomic, assign) BOOL isDebugMode;

- (instancetype)initWithOperationChainLength:(NSUInteger)length;

// Overload this method and implement operation logic
- (NSData*)processData:(NSData*)data error:(NSError**)error;

@end
