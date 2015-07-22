//
//  EVApplicationDelegate.h
//  EvaKit
//
//  Created by Yegor Popovych on 7/22/15.
//  Copyright (c) 2015 Evature. All rights reserved.
//

#import <Foundation/Foundation.h>

@class EVApplication;

@protocol EVApplicationDelegate <NSObject>

- (void)evApplication:(EVApplication*)application didObtainResponseFromServer:(NSDictionary*)response;
- (void)evApplication:(EVApplication*)application didObtainErrorFromServer:(NSError*)error;

- (void)evApplicationRecordIsStoped:(EVApplication *)application;

@optional
- (void)evApplicationRecorderIsReady:(EVApplication*)application;

- (void)evApplication:(EVApplication*)application recordingVolumePeak:(float)peak andAverage:(float)average;

@end
