//
//  EvaTestAppTests.h
//  EvaTestAppTests
//
//  Created by idan S on 7/30/13.
//  Copyright (c) 2013 IdanS. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>

#import <AudioToolbox/AudioToolbox.h>

#define CHECK_SPEEX_MALLOC_ERROR FALSE //TRUE

#if !CHECK_SPEEX_MALLOC_ERROR
#ifdef FLAC_VERSION
#import <EvaFlac/Eva.h>
#else
#import <Eva/Eva.h>
#endif 
#endif

//#import "EvaAppDelegate.h"
//#import "EvaMainViewController.h"

@interface EvaTestAppTests : SenTestCase
#if !CHECK_SPEEX_MALLOC_ERROR
<EvaDelegate>
#endif
{
@private
// Eva    *eva_framework;
    BOOL _recievedDataCallbackInvoked,_recievedFailCallbackInvoked;
    
    NSInteger errorCode;
    
    CFURLRef		lockSoundFileURLRef;
	SystemSoundID	lockSoundFileObject;
//    EvaAppDelegate    *app_delegate;
  //  EvaMainViewController *eva_view_controller;
   // UIView             *eva_view;

}

@property (readwrite)	CFURLRef		lockSoundFileURLRef;
@property (readonly)	SystemSoundID	lockSoundFileObject;


@end
