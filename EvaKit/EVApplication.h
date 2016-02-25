//
//  EVApplication.h
//  EvaKit
//
//  Created by Yegor Popovych on 7/7/15.
//  Copyright (c) 2015 Evature. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EVApplicationDelegate.h"
#import "EVLogger.h"
#import "EVVoiceChatButton.h"
#import "EVSearchScope.h"
#import "EVSearchContext.h"
#import "EVApplicationSound.h"


#define EV_NEW_SESSION_ID @"1"
#define EV_DEFAULT_MAX_RECORDING_TIME 15.0f

#define EV_KIT_VERSION @"2.0.19"

// [[NSBundle bundleForClass:[EVApplication class]] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]

typedef NS_ENUM(char, EVApplicationStateSound) {
    EVApplicationStateSoundRecordingStarted = 0,
    EVApplicationStateSoundRecordingStoped,
    EVApplicationStateSoundRequestFinished,
    EVApplicationStateSoundRequestError,
    EVApplicationStateSoundCancelled
};


@interface EVApplication : NSObject

//Delegate. Automatically updates to current Chat View controller by -showChatViewController... Set manually if not using this method //
@property (nonatomic, assign, readwrite) id<EVApplicationDelegate> delegate;

@property (nonatomic, assign, readonly) BOOL isReady;
@property (nonatomic, assign, readonly) BOOL isControllerShown;

@property (nonatomic, assign, readwrite) BOOL highlightText;
@property (nonatomic, assign, readwrite) BOOL useLocationServices;
@property (nonatomic, assign, readwrite) BOOL sendVolumeLevelUpdates;
@property (nonatomic, assign, readwrite) NSTimeInterval maxRecordingTime;
@property (nonatomic, assign, readwrite) NSTimeInterval connectionTimeout;

@property (nonatomic, strong, readonly) NSString* apiVersion;
@property (nonatomic, strong, readonly) NSString* APIKey;
@property (nonatomic, strong, readonly) NSString* siteCode;
@property (nonatomic, strong, readwrite) NSString* serverHost;
@property (nonatomic, strong, readwrite) NSString* textServerHost;

@property (nonatomic, strong, readwrite) NSString* currentSessionID;
@property (nonatomic, assign, readwrite) double deviceLongitude;
@property (nonatomic, assign, readwrite) double deviceLatitude;
@property (nonatomic, strong, readwrite) EVSearchScope* scope;
@property (nonatomic, strong, readwrite) EVSearchContext* context;
@property (nonatomic, strong, readwrite) NSString* language;
@property (nonatomic, strong, readonly) NSDictionary* extraParameters;

@property (nonatomic, strong, readonly) NSMutableArray* sessionMessages;

@property (nonatomic, strong, readonly) NSDictionary* applicationSounds;



// View Classes. Can be changed //
@property (nonatomic, assign, readwrite) Class chatViewControllerClass;
@property (nonatomic, assign, readwrite) Class chatButtonClass;

// Default bottom offset for chat button //
@property (nonatomic, assign) CGFloat defaultButtonBottomOffset;

// Dictionary with Chat View settings path rewrites. For more simple configuration and Chat Button //
@property (nonatomic, strong, readonly) NSMutableDictionary* chatViewControllerPathRewrites;


+ (instancetype)sharedApplication;

// Set API key and Site Code for application
- (void)setAPIKey:(NSString*)apiKey andSiteCode:(NSString*)siteCode;

// tell Eva what is currently being viewee in the app
- (void)setCurrentPage:(EVCRMPageType)currentPage andSubPage:(NSString*)subPage andFilter:(EVCRMFilterType)filter;

// Start record from current active Audio, If 'withNewSession' is set to 'NO' the function keeps last session. //
- (void)startRecordingWithNewSession:(BOOL)withNewSession;

//The same but with autoSrop. If autostop disabled then will be stoped only on max recording time event.
- (void)startRecordingWithNewSession:(BOOL)withNewSession andAutoStop:(BOOL)autoStop;

// Stop record, Would send the record to Eva for analyze //
- (void)stopRecording;

// Cancel record, Would cancel operation, record won't send to Eva (don't expect response) //
- (void)cancelRecording;

// Text query APIs //
- (void)queryText:(NSString*)text withNewSession:(BOOL)withNewSession;
- (void)editLastQueryWithText:(NSString*)text;

// Add button to controller methods //
- (EVVoiceChatButton*)addButtonInController:(UIViewController*)viewController;
- (EVVoiceChatButton*)addButtonInView:(UIView*)view inController:(UIViewController *)viewController;

// Sender can be View Controller or View //
- (void)showChatViewController:(UIResponder*)sender;
- (void)showChatViewController:(UIResponder*)sender withViewSettings:(NSDictionary*)viewSettings;
- (void)hideChatViewController:(UIResponder*)sender;

// Sounds APIs //
- (EVApplicationSound*)soundForState:(EVApplicationStateSound)state;
- (void)setSound:(EVApplicationSound*)sound forApplicationState:(EVApplicationStateSound)state;

// Extra Server Parameters //
- (void)setExtraServerParameter:(NSString*)parameter withValue:(id)value;

@end
