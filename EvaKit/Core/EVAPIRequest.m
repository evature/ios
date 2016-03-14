//
//  EVAPIRequest.m
//  EvaKit
//
//  Created by Yegor Popovych on 8/20/15.
//  Copyright (c) 2015 Evature. All rights reserved.
//

#import "EVAPIRequest.h"
#import "EVLogger.h"

@interface EVAPIRequest ()

@property (nonatomic, strong, readwrite) NSURLConnection* connection;
@property (nonatomic, strong, readwrite) NSMutableData* responseData;

@end

@implementation EVAPIRequest

- (instancetype)initWithURL:(NSURL*)URL timeout:(NSTimeInterval)timeout andDelegate:(id<EVAPIRequestDelegate>)delegate {
    self = [super initWithName:@"APIRequest" andErrorHandler:delegate];
    if (self != nil) {
        NSURLRequest* request = [NSURLRequest requestWithURL:URL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:timeout];
        self.connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
        [self.connection release];
        self.delegate = delegate;
        self.responseData = [NSMutableData data];
    }
    return self;
}

- (void)dealloc {
    self.connection = nil;
    self.responseData = nil;
    [super dealloc];
}

- (void)start {
    [self.connection start];
}

- (void)cancel {
    [self.connection cancel];
    self.connection = nil;
    [super cancel];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    self.connection = nil;
    [self.delegate node:self gotAnError:error];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.responseData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    self.connection = nil;
    NSError* error = nil;
    NSDictionary* json = [NSJSONSerialization JSONObjectWithData:self.responseData options:kNilOptions error:&error];
    if (error != nil) {
        EV_LOG_ERROR("Can't read json: %@", error);
        [self.delegate node:self gotAnError:error];
    } else {
        [self.delegate apiRequest:self gotResponse:json];
    }
}




@end
