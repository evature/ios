//
//  EvaKitTests.m
//  EvaKitTests
//
//  Created by Iftah Haimovitch on 21/01/2016.
//  Copyright © 2016 Evature. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "EvaKit.h"
#import "EVAPIRequest.h"

@interface EVApplication (Testing)
    - (void)apiRequest:(EVAPIRequest*)request gotResponse:(NSDictionary*)response;
@end

@interface NavigateHandler : UIViewController<EVFlightNavigateDelegate>
    - (EVCallbackResult*)navigateTo:(EVFlightPageType)page;
    @property EVFlightPageType navigatedTo;
    @property __block BOOL waitingForNavigate;
@end

@implementation NavigateHandler
@synthesize navigatedTo;
- (id) init {
    self = [super init];
    self.navigatedTo = EVFlightPageTypeUnknown;
    self.waitingForNavigate = YES;
    return self;
}
- (EVCallbackResult*)navigateTo:(EVFlightPageType)page {
    self.navigatedTo = page;
    self.waitingForNavigate = NO;
    return nil;
}
@end

@interface EvaKitTests : XCTestCase

@end

@implementation EvaKitTests

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testNavigateBoardingPass {
    EVApplication *app = [EVApplication sharedApplication];
    
    NSDictionary *response = @{
                @"status": @true,
                @"transaction_key":	@"11e5-c04e-fd139694-8aed-22000bd9069b",
                @"api_reply": @{
                     @"Flow": @[
                                @{
                                    @"NavigationDestination": @"Boarding Pass",
                                    @"SayIt": @"Here is your boarding pass",
                                    @"Type": @"Navigate",
                                    @"URL": @"trip/boarding pass",
                            }
                        ],
                }
    };
    
    NavigateHandler *handler = [[NavigateHandler alloc] init];
    [app showChatViewController:handler];
    [app apiRequest:nil gotResponse:response];
    // Run the loop
    while([handler waitingForNavigate]) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
    }
    
    XCTAssertEqual([handler navigatedTo], EVFlightPageTypeBoardingPass, "Unexpected navigatedTo");
}




/*
- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}*/

@end
