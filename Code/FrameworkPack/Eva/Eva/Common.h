//
//  Common.h
//  Eva
//
//  Created by idan S on 10/10/13.
//  Copyright (c) 2013 Evature. All rights reserved.
//

#ifndef Eva_Common_h
#define Eva_Common_h


#define EVA_FRAMEWORK_VERSION @"1.4.9"

#define USE_SAFE_STRING TRUE //FALSE

#ifdef SHOW_DEBUG_LOGS
    #define DEBUG_LOGS TRUE
    #define DEBUG_MODE_FOR_EVA TRUE 
#else
    #define DEBUG_LOGS FALSE
    #define DEBUG_MODE_FOR_EVA FALSE
#endif

#endif
