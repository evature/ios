//
//  EvaBaseTest.h
//  EvaKit
//
//  Created by Iftah Haimovitch on 11/02/2016.
//  Copyright © 2016 Evature. All rights reserved.
//

#ifndef EvaBaseTest_h
#define EvaBaseTest_h

#import <XCTest/XCTest.h>
#import "EvaKit.h"
#import "EVAPIRequest.h"


@protocol SearchHandler
    @property __block BOOL waitingForSearch;
@end

@interface EVApplication (Testing)
// expose the private method:
- (void)apiRequest:(EVAPIRequest*)request gotResponse:(NSDictionary*)response;
@end

@interface EvaBaseTest : XCTestCase

@property NSDateFormatter *formatter;

- (void)setUp;
- (void)tearDown;
- (void) simulateJSON: (NSString*)jsonString withHandler:(id<SearchHandler>)handler;
@end

#endif /* EvaBaseTest_h */
