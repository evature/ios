//
//  EVApplicationDelegate.h
//  EvaKit
//
//  Created by Yegor Popovych on 7/22/15.
//  Copyright (c) 2015 Evature. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EVResponse.h"

@class EVApplication;

@protocol EVApplicationDelegate <NSObject>

- (void)evApplicationIsReady:(EVApplication*)application;
- (void)evApplication:(EVApplication*)application didObtainResponse:(EVResponse*)response;
- (void)evApplication:(EVApplication*)application didObtainError:(NSError*)error;

@optional

- (void)evApplicationRecordingIsStarted:(EVApplication*)application;
- (void)evApplicationRecordingIsStoped:(EVApplication *)application;
- (void)evApplicationRecordingIsCancelled:(EVApplication *)application;

- (void)evApplication:(EVApplication*)application recordingVolumePeak:(float)peak andAverage:(float)average;

@end
