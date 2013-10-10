//
//  Common.h
//  SpeexKitDemoDistribution
//
//  Created by idan S on 4/7/13.
//  Copyright (c) 2013 Politepix. All rights reserved.
//

#ifndef SpeexKitDemoDistribution_Common_h
#define SpeexKitDemoDistribution_Common_h

#import "TestFlight.h"

#define USING_M4A_RECORDING TRUE//FALSE//TRUE

#define PLAY_DEBUG_SAMPLES FALSE

#define kLastJsonStringFromEva @"LastJsonStringFromEva"

#define TESTFLIGHT_TESTING TRUE
#define TESTFLIGHT_TOKEN @"bf5bff61-a505-4f51-ad10-d58c52843a08"


typedef enum {
    kEvaRecordingUser,
    kEvaWaitingForEvaResponse,
    kEvaWaitingForUserPress
} ViewStateType;


#endif
