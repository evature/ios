//
//  Eva.h
//  Eva
//
//  Created by idan S on 5/12/13.
//  Copyright (c) 2013 Evature. All rights reserved.
//
//  Version 1.6.2
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreLocation/CoreLocation.h>

   
@protocol EvaDelegate <NSObject>
@optional

// Required: Called when receiving valid data from Eva.
- (void)evaDidReceiveData:(NSData *)dataFromServer;

// Required: Called when receiving an error from Eva.
- (void)evaDidFailWithError:(NSError *)error;

// Optional: Called when recording. averagePower and peakPower are in decibels. Must be implemented if shouldSendMicLevel is TRUE.
- (void)evaMicLevelCallbackAverage: (float)averagePower andPeak: (float)peakPower;  

// Optional: Called everytime the record stops, Must be implemented if shouldSendMicLevel is TRUE.
- (void)evaMicStopRecording; 

// Optional: Called when initiation process is complete after setting the API keys.
- (void)evaRecorderIsReady;

@end

@interface Eva : NSObject{
    // Optional parameters //
    NSString *uid;
    
    NSString *bias;
    NSString *home;
    
    NSString *version; // Optional, @"v1.0" is the default version
    
    NSString *scope;
    NSString *context;
    
    NSDictionary *optional_dictionary;
}

@property (nonatomic, weak) id <EvaDelegate> delegate;

@property(nonatomic,retain) NSString *uid;
@property(nonatomic,retain) NSString *bias;
@property(nonatomic,retain) NSString *home;

@property(nonatomic,retain) NSString *version;

@property(nonatomic,retain) NSString *scope; 
@property(nonatomic,retain) NSString *context;

@property(nonatomic,retain) NSDictionary *optional_dictionary;

+ (Eva *)sharedInstance;

// Set the API keys - Use one of those functions, This should be called as earlier as possible //
- (BOOL)setAPIkey: (NSString *)api_key withSiteCode:(NSString *)site_code;

// if shouldSendMicLevel is TRUE, evaMicLevelCallbackAverage:andPeak would be called when recording and evaMicStopRecording when recording stopped
- (BOOL)setAPIkey: (NSString *)api_key withSiteCode:(NSString *)site_code withMicLevel:(BOOL)shouldSendMicLevel;

// if shouldSendMicLevel is TRUE, evaMicLevelCallbackAverage:andPeak would be called when recording and evaMicStopRecording when recording stopped. secToTimeout represent the timeout of the record (default is 15.0 sec, max value is 15.0 sec)
- (BOOL)setAPIkey: (NSString *)api_key withSiteCode:(NSString *)site_code withMicLevel:(BOOL)shouldSendMicLevel withRecordingTimeout:(float)secToTimeout;



// Start record from current active Audio, If 'withNewSession' is set to 'FALSE' the function keeps last session. Return TRUE if could start the record and FALSE if there was any error (for example when APIkeys aren't set or recorder isn't ready) //
- (BOOL)startRecord:(BOOL)withNewSession;

// Start record without sending any session to Eva. //
- (BOOL)startRecordNoSession;

// Stop record, Would send the record to Eva for analyze //
- (BOOL)stopRecord;

// Cancel record, Would cancel operation, record won't send to Eva (don't expect response) //
- (BOOL)cancelRecord;

// query Eva by text - optional start new session
- (BOOL)queryWithText:(NSString *)text startNewSession:(BOOL)newSession;

- (void)setDebugMode:(BOOL)isDebug;

-(void)repeatStreamer; // for debugging stress test
-(void)stopRecordQueue: (BOOL)wasCanceled; // for debugging

// optional - audio files to play before or after recording voice - set to NULL to skip these sounds.
// will return FALSE on error (file not found, wrong file format, etc...)
- (BOOL) setStartRecordAudioFile: (NSURL *)filePath;          // this sound will play when a "startRecord" method is called - the actual recording will start after the sound finishes playing
- (BOOL) setRequestedEndRecordAudioFile: (NSURL *)filePath;   // this sound will play when the "stopRecord" is called
- (BOOL) setVADEndRecordAudioFile: (NSURL *)filePath;         // this sound will play when the VAD (voice automatic detection) recognizes the user finished speaking
- (BOOL) setCanceledRecordAudioFile: (NSURL *)filePath;       // this sound will play when calling "cancelRecord"

- (BOOL) isReady; // Do not call startRecord before this method returns true - you can wait for the evaRecorderIsReady delegate callback

@end
