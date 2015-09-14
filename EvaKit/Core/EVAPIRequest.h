//
//  EVAPIRequest.h
//  EvaKit
//
//  Created by Yegor Popovych on 8/20/15.
//  Copyright (c) 2015 Evature. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSError+EVA.h"

#define EVAPIRequestCancelledErrorCode ERROR_STR_TO_CODE("EAIC")

@class EVAPIRequest;

@protocol EVAPIRequestDelegate <NSObject>

- (void)apiRequest:(EVAPIRequest*)request gotResponse:(NSDictionary*)response;
- (void)apiRequest:(EVAPIRequest *)request gotAnError:(NSError*)error;

@end

@interface EVAPIRequest : NSObject

//@property (nonatomic, strong, readwrite) NSString* name;
@property (nonatomic, assign, readwrite) id<EVAPIRequestDelegate> delegate;

- (instancetype)initWithURL:(NSURL*)URL timeout:(NSTimeInterval)timeout andDelegate:(id<EVAPIRequestDelegate>)delegate;

- (void)start;
- (void)cancel;

@end
