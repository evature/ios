//
//  EvaMainViewController.h
//  EvaTestApp
//
//  Created by idan S on 7/30/13.
//  Copyright (c) 2013 IdanS. All rights reserved.
//

#import "EvaFlipsideViewController.h"
/*
#ifdef FLAC_VERSION
#import <EvaFlac/Eva.h>
#else
#import <Eva/Eva.h>
#endif
*/
@interface EvaMainViewController : UIViewController <EvaFlipsideViewControllerDelegate//,EvaDelegate
>{
    
}

- (IBAction)showInfo:(id)sender;

//+ (Eva *)sharedInstance;

/*
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
*/
@end
