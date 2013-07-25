//
//  Eva.h
//  Eva
//
//  Created by idan S on 5/12/13.
//  Copyright (c) 2013 Evature. All rights reserved.
//
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreLocation/CoreLocation.h>


@protocol EvaDelegate <NSObject>
@optional
- (void)evaDidReceiveData:(NSData *)dataFromServer;  // Called when receiving valid data from Eva.
- (void)evaDidFailWithError:(NSError *)error;        // Called when receiving an error from Eva.

- (void)evaMicLevelCallbackAverage: (float)averagePower andPeak: (float)peakPower;  // Called when recording. averagePower and peakPower are in decibels. Must be implemented if shouldSendMicLevel is TRUE.
- (void)evaMicStopRecording; // Called everytime the record stops, Must be implemented if shouldSendMicLevel is TRUE.
@end

@interface Eva : NSObject{
    // Optional parameters //
    NSString *uid;
    
    NSString *bias;
    NSString *home;
    
    NSString *version; // Optional, @"v1.0" is the default version
}

@property (nonatomic, weak) id <EvaDelegate> delegate;

@property(nonatomic,retain) NSString *uid;
@property(nonatomic,retain) NSString *bias;
@property(nonatomic,retain) NSString *home;

@property(nonatomic,retain) NSString *version;


+ (Eva *)sharedInstance;

// Set the API keys - Use one of those functions //
- (BOOL)setAPIkey: (NSString *)api_key withSiteCode:(NSString *)site_code;

// if shouldSendMicLevel is TRUE, evaMicLevelCallbackAverage:andPeak would be called when recording and evaMicStopRecording when recording stopped
- (BOOL)setAPIkey: (NSString *)api_key withSiteCode:(NSString *)site_code withMicLevel:(BOOL)shouldSendMicLevel;

// if shouldSendMicLevel is TRUE, evaMicLevelCallbackAverage:andPeak would be called when recording and evaMicStopRecording when recording stopped. secToTimeout represent the timeout of the record (default is 8.0 sec)
- (BOOL)setAPIkey: (NSString *)api_key withSiteCode:(NSString *)site_code withMicLevel:(BOOL)shouldSendMicLevel withRecordingTimeout:(float)secToTimeout;

// Start record from current active Audio, If 'withNewSession' is set to 'FALSE' the function keeps last session //
- (BOOL)startRecord:(BOOL)withNewSession;

// Stop record, Would send the record to Eva for analyze //
- (BOOL)stopRecord;

// Cancel record, Would cancel operation, record won't send to Eva (don't expect response) //
- (BOOL)cancelRecord;


@end
