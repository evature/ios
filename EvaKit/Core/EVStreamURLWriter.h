//
//  EVStreamURLWriter.h
//  EvaKit
//
//  Created by Yegor Popovych on 8/5/15.
//  Copyright (c) 2015 Evature. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EVDataProducer.h"

//Provider delegate methods in this class stops caller run lopp. So Use only in background loops
@protocol EVStreamURLWriterDelegate;

@interface EVStreamURLWriter : NSObject <EVDataConsumer>

- (instancetype)initWithURL:(NSURL*)anURL
                    headers:(NSDictionary*)headers
                 bufferSize:(NSUInteger)bufferSize
          connectionTimeout:(NSTimeInterval)timeout
                   delegate:(id<EVStreamURLWriterDelegate>)delegate;

@property (nonatomic, assign, readwrite) id<EVStreamURLWriterDelegate> delegate;

-(void)cancel;

@end


@protocol EVStreamURLWriterDelegate <NSObject>

- (void)streamWriter:(EVStreamURLWriter*)writer gotResponseData:(NSData*)data;
- (void)streamWriterFinished:(EVStreamURLWriter *)writer;

@end