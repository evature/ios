//
//  EvaTestAppTests.m
//  EvaTestAppTests
//
//  Created by idan S on 7/30/13.
//  Copyright (c) 2013 IdanS. All rights reserved.
//

#import "EvaTestAppTests.h"
#import "SpeexEncoder.h"

//       'iosdev'          : 'bc3e0b6a-a021-40b6-b38f-1f4d8e1740cb',
//#define EVA_API_KEY @"thack-london-june-2012"
//#define EVA_SITE_CODE @"thack"

#define EVA_API_KEY @"bc3e0b6a-a021-40b6-b38f-1f4d8e1740cb"
#define EVA_SITE_CODE @"iosdev"

#define MIN_RECORD_LEN 0.0f//0.5f //2.0f

#define TIMES_TO_REPEAT_EACH_TEST 1

#define SERVER_RESPONSE_TIMEOUT_DEFAULT 10.0f


@implementation EvaTestAppTests
@synthesize lockSoundFileObject;
@synthesize lockSoundFileURLRef;

- (void)initSounds{
    
    /**** Lock sound initialization ****/
    NSURL *lockSound   = [[NSBundle mainBundle] URLForResource: @"multi-plier-close-1"//@"LargeDoorSlam"
                                                 withExtension: @"wav"];
    
    // Store the URL as a CFURLRef instance
    lockSoundFileURLRef = (__bridge CFURLRef) lockSound ;
    
 
    
    // Create a system sound object representing the sound file.
    AudioServicesCreateSystemSoundID (
                                      
                                      lockSoundFileURLRef,
                                      &lockSoundFileObject
                                      );
}

- (void)setUp
{
    [super setUp];
    
    // Set-up code here.
#if !CHECK_SPEEX_MALLOC_ERROR
    [Eva sharedInstance].delegate = self; // Setting the delegate to this view //
    
    // Checking new optional dictionary //
    //NSMutableDictionary *optionalDict = [NSMutableDictionary dictionaryWithObject:[NSString stringWithFormat: @"%@",@"objTest"] forKey:@"keyTest"];
    //[Eva sharedInstance].optional_dictionary = optionalDict;
    
    //////////////////////////////////////
    
    [[Eva sharedInstance] setAPIkey:EVA_API_KEY withSiteCode:EVA_SITE_CODE];
#endif
    
   
    
    _recievedDataCallbackInvoked = FALSE;
    _recievedFailCallbackInvoked = FALSE;
    errorCode = 0;
    
    //[self initSounds];
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}


/*-(void)testLotsOfSpeexCrashRecord{
    for (int i=0; i<1000; i++) {
        NSLog(@"\n ---- TEST LOG : testLotsOfCrashRecord #%d",i);
        [self singleCrashRecord];
    }
}*/

#if !CHECK_SPEEX_MALLOC_ERROR
- (void)testSimpleRecord{
    
    [self recordWithLengthHelper:5.0f withNewSession:TRUE];
    
    STAssertTrue(_recievedDataCallbackInvoked,
                 @"Delegate should send -evaDidReceiveData:dataFromServer:");
    
    
}

/*- (void)testSimpleCancel{
    

    
    [self recordCancelWithLengthHelper:5.0f withNewSession:TRUE];
    
    STAssertTrue(!_recievedDataCallbackInvoked,
                 @"Delegate shouldn't send -evaDidReceiveData:dataFromServer:");

}*/

-(void)testLotsOfRecordSizes{
    float recordLength;
    int timesToRepeatEachTest = TIMES_TO_REPEAT_EACH_TEST;
    for (int i=1; i<50
         ; i++) {
        for (int j=0; j<timesToRepeatEachTest; j++) {
            NSLog(@"\n ---- TEST LOG : testLotsOfRecordSizes #%d - Repeat #%d ----",i,j);
            _recievedDataCallbackInvoked = FALSE;
            _recievedFailCallbackInvoked = FALSE;
            errorCode = 0;
            recordLength = MIN_RECORD_LEN+i*0.1f;
            [self recordWithLengthHelper:recordLength withNewSession:TRUE];
            
            if (_recievedDataCallbackInvoked) {
                STAssertTrue(_recievedDataCallbackInvoked,
                             [NSString stringWithFormat:@"Delegate should send -evaDidReceiveData:dataFromServer: Failed on test length: %f On time #%d", recordLength,j]);
            }else{
                
                STAssertTrue((_recievedFailCallbackInvoked && errorCode==406) || (_recievedFailCallbackInvoked && errorCode == 400) ,
                             [NSString stringWithFormat:@"Delegate should send -evaDidFailWithError:error: Failed on test length: %f On time #%d, Got error number: %d, _recievedFailCallbackInvoked = %d", recordLength,j ,errorCode,_recievedFailCallbackInvoked ]);
                
                
            
            }
            
        }
   
    }
}
/*
-(void)testLotsOfCancelRecordSizes{
    float recordLength;
    int timesToRepeatEachTest = TIMES_TO_REPEAT_EACH_TEST;
    for (int i=1; i<5//10
         ; i++) {
        for (int j=0; j<timesToRepeatEachTest; j++) {
            NSLog(@"\n ---- TEST LOG : testLotsOfCancelRecordSizes #%d - Repeat #%d ---- ",i,j);
            //_recievedDataCallbackInvoked = FALSE;
            recordLength = MIN_RECORD_LEN+i*0.2f;
            [self recordCancelWithLengthHelper:recordLength withNewSession:TRUE];
            
            STAssertTrue(!_recievedDataCallbackInvoked,
                         [NSString stringWithFormat:@"Delegate should send -evaDidReceiveData:dataFromServer: Failed on test length: %f On time #%d", recordLength,j]);
        }
        
    }
}

-(void)testLotsOfRecordsOnSameSession{
    float recordLength;
    int timesToRepeatEachTest = TIMES_TO_REPEAT_EACH_TEST;
    for (int i=1; i<5//0
         ; i++) {
        for (int j=0; j<timesToRepeatEachTest; j++) {
            NSLog(@"\n ---- TEST LOG : testLotsOfRecordsOnSameSession #%d - Repeat #%d ----",i,j);
            _recievedDataCallbackInvoked = FALSE;
            _recievedFailCallbackInvoked = FALSE;
            errorCode = 0;
            recordLength = MIN_RECORD_LEN+i*0.1f;
            [self recordWithLengthHelper:recordLength withNewSession:FALSE];
            
            if (_recievedDataCallbackInvoked) {
                STAssertTrue(_recievedDataCallbackInvoked,
                             [NSString stringWithFormat:@"Delegate should send -evaDidReceiveData:dataFromServer: Failed on test length: %f On time #%d", recordLength,j]);
            }else{
                
                STAssertTrue(_recievedFailCallbackInvoked && errorCode==406,
                             [NSString stringWithFormat:@"Delegate should send -evaDidFailWithError:error: Failed on test length: %f On time #%d, Got error number: %d, _recievedFailCallbackInvoked = %d", recordLength,j ,errorCode,_recievedFailCallbackInvoked ]);
                
                
                
            }
            
        }
        
    }
}*/
#endif


#pragma mark -
#pragma mark helpers

-(void)singleCrashRecord{
    
    NSURL *crashSound   = [[NSBundle mainBundle] URLForResource: @"crashrec"//@"LargeDoorSlam"
                                                  withExtension: @"wav"];
    
    /*   NSLog(@"convertFileToSpeex");
     
     NSLog(@"crashSound : %@", crashSound);//waveFilePath);
     
     NSLog(@"[crashSound absoluteString]=%@", [crashSound absoluteString]);*/
    
    
    NSError *encodingError;
    SpeexEncoder *spxEncoder = [SpeexEncoder encoderWithMode:speex_wb_mode quality:6
                                            outputSampleRate:SAMPLE_RATE_16000_HZ];
    
    
    if (spxEncoder == NULL) {
        NSLog(@"spxEncoder == NULL");
    }else{
        NSLog(@"[spxEncoder description]=%@",[spxEncoder description]);
    }
    
    
    // NSArray *dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    // NSString *docsDir = [NSString stringWithFormat:@"%@",[dirPaths objectAtIndex:0]]; // Get documents directory
    // NSURL *tmpFileUrl = [NSURL fileURLWithPath:[docsDir stringByAppendingPathComponent:@"rec.wav" //@"rec.m4a"//m4a"
    //                                         ]];
    
    
    NSURL *someURL = crashSound;//tmpFileUrl; // some file URL
    NSString *path = [someURL path];
    //NSDictionary *info = [[NSFileManager defaultManager] attributesOfItemAtPath:path];
    
    NSString* expandedPath = [path stringByExpandingTildeInPath];
    //NSURL* audioUrl = [NSURL fileURLWithPath:expandedPath];
    
    NSLog(@"expandedPath = %@",expandedPath);
    
    // DEBUG //
    //NSData *_waveData = [NSData dataWithContentsOfFile:path];
    //NSLog(@"[_waveData description]=%@",[_waveData description]);
    ///////////
    
    NSData *spx = [spxEncoder encodeWaveFileAtPath:expandedPath//path//[wavFileUrl_ absoluteString]
                   //waveFilePath
                                             error:&encodingError];
    
    NSArray *documentPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [NSString stringWithFormat:@"%@",[documentPath objectAtIndex:0]]; // Get documents directory
    
    NSString *speexOutputFile = [NSString stringWithFormat:@"%@/%@",documentsDirectory, @"recCrash.spx"];
    
    BOOL fileWriteSuccess = [spx writeToFile:speexOutputFile atomically:YES];
    
    STAssertTrue(fileWriteSuccess,
                 @"Can't write crash file");
}

#if !CHECK_SPEEX_MALLOC_ERROR
- (void)recordWithLengthHelper:(float)recLength withNewSession: (BOOL)isNewSession{
    NSDate *recordLength = [NSDate dateWithTimeIntervalSinceNow:recLength];
    
    [[Eva sharedInstance] startRecord:isNewSession];
    [[NSRunLoop currentRunLoop] runUntilDate:recordLength];
    [[Eva sharedInstance] stopRecord];
    
    NSDate *serverResponseTimout = [NSDate dateWithTimeIntervalSinceNow:SERVER_RESPONSE_TIMEOUT_DEFAULT];
    [[NSRunLoop currentRunLoop] runUntilDate:serverResponseTimout];
    
}

- (void)recordCancelWithLengthHelper:(float)recLength withNewSession: (BOOL)isNewSession{
    NSDate *recordLength = [NSDate dateWithTimeIntervalSinceNow:recLength];
    
    [[Eva sharedInstance] startRecord:isNewSession];
    [[NSRunLoop currentRunLoop] runUntilDate:recordLength];
    [[Eva sharedInstance] cancelRecord];
    
    NSDate *serverResponseTimout = [NSDate dateWithTimeIntervalSinceNow:SERVER_RESPONSE_TIMEOUT_DEFAULT];
    [[NSRunLoop currentRunLoop] runUntilDate:serverResponseTimout];
    
}

/*- (void)testExample
{
  //  STFail(@"Unit tests are not implemented yet in EvaTestAppTests");
}*/

#pragma mark - Eva Delegate
- (void)evaDidReceiveData:(NSData *)dataFromServer{
    NSString* dataStr = [[NSString alloc] initWithData:dataFromServer encoding:NSASCIIStringEncoding];
    
    NSLog(@"TEST LOG : Data from Eva %@", dataStr);
    _recievedDataCallbackInvoked = YES;
    
    
}

- (void)evaDidFailWithError:(NSError *)error{
    errorCode = [error code];
    NSLog(@"TEST LOG : Got error from Eva, Error number : %d",errorCode);
    _recievedFailCallbackInvoked = YES;
    
    STAssertTrue(TRUE, @"Got error from Eva : %d",errorCode);
    }

- (void)evaMicLevelCallbackAverage: (float)averagePower andPeak: (float)peakPower{
    NSLog(@"TEST LOG : Mic Average: %f Peak: %f", averagePower,peakPower);
    
}

- (void)evaMicStopRecording{
    NSLog(@"TEST LOG : Recording has stopped");
    
}

#endif


@end
