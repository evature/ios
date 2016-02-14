//
//  EvaBaseTest.m
//  EvaKit
//
//  Created by Iftah Haimovitch on 11/02/2016.
//  Copyright © 2016 Evature. All rights reserved.
//

#import "EvaBaseTest.h"


@implementation EvaBaseTest


- (void)setUp {
    [super setUp];
    _formatter = [[NSDateFormatter alloc] init];
    [_formatter setDateFormat:@"yyyy-MM-dd"];
}

- (void)tearDown {
    _formatter = nil;
    [super tearDown];
}

- (void) simulateJSON: (NSString*)jsonString withHandler:(id<SearchHandler>)handler {
    EVApplication *app = [EVApplication sharedApplication];
    NSData *data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    id response = [NSJSONSerialization JSONObjectWithData:data options:0 error:&err];
    
    [app showChatViewController:(UIResponder*)handler];
    [app apiRequest:nil gotResponse:response];
    // Run the loop
    while([handler waitingForSearch]) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
    }
}

@end
