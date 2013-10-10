//
//  SpeexKitTests.m
//  SpeexKitTests
//
//  Created by Ryan Wang on 7/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SpeexKitTests.h"
#import <SpeexKit/SpeexKit.h>

@implementation SpeexKitTests

- (void)setUp
{
    [super setUp];
    
    // Set-up code here.
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}


- (void)testDecode {
    SpeexDecoder *decoder = [[SpeexDecoder alloc] init];
    NSString *infilePath = [[NSBundle mainBundle] pathForResource:@"output" ofType:@"spx"];//@"/Users/ryan/Documents/workspace/SpeexKit/SpeexKit/output.spx";
    NSString *outfilePath = [NSHomeDirectory() stringByAppendingFormat:@"Document/decode1.wav"];//@"/Users/ryan/Desktop/decode1.wav";
    [decoder decodeInFilePath:infilePath outFilePath:outfilePath];
    [SenTestLog testLogWithFormat:@"infilePath"];
    [SenTestLog testLogWithFormat:@"infilePath : %@",infilePath];
    [SenTestLog testLogWithFormat:@"outfilePath : %@",outfilePath];
    STFail(@"Unit tests are not implemented yet in SpeexKitTests");
}

- (void)testExample
{
//    STFail(@"Unit tests are not implemented yet in SpeexKitTests");
}

@end
