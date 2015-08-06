//
//  EVApplication.h
//  EvaKit
//
//  Created by Yegor Popovych on 7/7/15.
//  Copyright (c) 2015 Evature. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EVApplicationDelegate.h"
#import "EVVoiceChatButton.h"


#define EV_NEW_SESSION_ID @"1"
#define EV_DEFAULT_MAX_RECORDING_TIME 15.0f
#define EV_KIT_VERSION @"1.6.4"

@interface EVApplication : NSObject

//Delegate. Automatically updates to current controller by -showChatViewController... Set manually if not using this method
@property (nonatomic, assign, readwrite) id<EVApplicationDelegate> delegate;

@property (nonatomic, strong, readonly) NSString* apiVersion;



@property (nonatomic, assign, readwrite) double deviceLongtitude;
@property (nonatomic, assign, readwrite) double deviceLatitude;

@property (nonatomic, strong, readwrite) NSString* currentSessionID;

@property (nonatomic, assign, readwrite) BOOL sendVolumeLevelUpdates;


@property (nonatomic, strong, readonly) NSString* APIKey;
@property (nonatomic, strong, readonly) NSString* siteCode;
@property (nonatomic, strong, readwrite) NSString* serverHost;


//View Classes. Can be changed.
@property (nonatomic, assign, readwrite) Class chatViewControllerClass;
@property (nonatomic, assign, readwrite) Class chatButtonClass;

// Default bottom offset for chat button
@property (nonatomic, assign) CGFloat defaultButtonBottomOffset;
// Dictionary with Chat View settings path rewrites. For more simple configuration and Chat Button.
@property (nonatomic, strong, readonly) NSMutableDictionary* chatViewControllerPathRewrites;




+ (instancetype)sharedApplication;


- (void)setAPIKey:(NSString*)apiKey andSiteCode:(NSString*)siteCode;

// Start record from current active Audio, If 'withNewSession' is set to 'FALSE' the function keeps last session. //
- (void)startRecordingWithNewSession:(BOOL)withNewSession;

// Stop record, Would send the record to Eva for analyze //
- (void)stopRecording;

// Cancel record, Would cancel operation, record won't send to Eva (don't expect response) //
- (void)cancelRecording;

// Add button to controller methods
- (EVVoiceChatButton*)addButtonInController:(UIViewController*)viewController;
- (EVVoiceChatButton*)addButtonInView:(UIView*)view inController:(UIViewController *)viewController;

// Sender can be View Controller or View
- (void)showChatViewController:(id)sender withViewSettings:(NSDictionary*)viewSettings;
- (void)hideChatViewController:(id)sender;

@end
