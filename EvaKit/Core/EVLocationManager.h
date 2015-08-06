//
//  EVLocationManager.h
//  EvaKit
//
//  Created by Yegor Popovych on 8/6/15.
//  Copyright (c) 2015 Evature. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol EVLocationManagerDelegate;

@interface EVLocationManager : NSObject

@property (nonatomic, assign, readwrite) id<EVLocationManagerDelegate> delegate;

- (void)startLocationService;
- (void)stopLocationService;

@end


@protocol EVLocationManagerDelegate <NSObject>

- (void)locationManager:(EVLocationManager*)manager didObtainNewLongtitude:(double)lng andLatitude:(double)lat;
- (void)locationManager:(EVLocationManager*)manager didObtainError:(NSError*)error;

@end