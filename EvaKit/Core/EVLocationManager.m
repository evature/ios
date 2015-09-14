//
//  EVLocationManager.m
//  EvaKit
//
//  Created by Yegor Popovych on 8/6/15.
//  Copyright (c) 2015 Evature. All rights reserved.
//

#import "EVLocationManager.h"
#import <CoreLocation/CoreLocation.h>

@interface EVLocationManager () <CLLocationManagerDelegate>
@property (nonatomic, strong, readwrite) CLLocationManager* locationManager;

@end

@implementation EVLocationManager

- (instancetype)init {
    self = [super init];
    if (self != nil) {
        self.locationManager = [[CLLocationManager new] autorelease];
        self.locationManager.delegate = self;
        self.locationManager.distanceFilter = 500.0; //1km movement
        self.locationManager.desiredAccuracy = kCLLocationAccuracyKilometer;
    }
    return self;
}

- (void)dealloc {
    self.locationManager = nil;
    [super dealloc];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    CLLocation* newLocation = [locations lastObject];
    [self.delegate locationManager:self didObtainNewLongitude:newLocation.coordinate.longitude andLatitude:newLocation.coordinate.latitude];
}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error {
    [self.delegate locationManager:self didObtainError:error];
}

- (void)startLocationService {
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied ||
        [CLLocationManager authorizationStatus] == kCLAuthorizationStatusRestricted )
    {
        return;
    }
    
    if ([_locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)])
    {
        [_locationManager requestWhenInUseAuthorization];
    }
    
    [self.locationManager startUpdatingLocation];
//    [self.locationManager startMonitoringSignificantLocationChanges];
//    if (self.locationManager.location != nil) {
//        [self locationManager:self.locationManager didUpdateLocations:@[self.locationManager.location]];
//    }
}

- (void)stopLocationService {
    //[self.locationManager stopMonitoringSignificantLocationChanges];
    [self.locationManager stopUpdatingLocation];
}

@end
