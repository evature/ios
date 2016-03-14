//
//  EVAudioChainOperation.h
//  EvaKit
//
//  Created by Yegor Popovych on 7/30/15.
//  Copyright (c) 2015 Evature. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EVDataProducer.h"
#import <dispatch/dispatch.h>

// Consumes data from one producer, process it,  produce it to the consumer
//
@interface EVAudioChainOperation : EVDataProducer <EVDataConsumer>

- (void)producer:(EVDataProducer*)producer hasNewData:(NSData*)data;


// Overload this method and implement operation logic
- (NSData*)processData:(NSData*)data error:(NSError**)error;

@end
