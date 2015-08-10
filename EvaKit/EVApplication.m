//
//  EVApplication.m
//  EvaKit
//
//  Created by Yegor Popovych on 7/7/15.
//  Copyright (c) 2015 Evature. All rights reserved.
//

#import "EVApplication.h"
#import "EVVoiceChatViewController.h"
#import "Eva.h"
#import "EVViewControllerVisibilityObserver.h"
#import <AVFoundation/AVFoundation.h>

#import "EVAudioRecorder.h"
#import "EVAudioConvertionOperation.h"
#import "EVAudioDataStreamer.h"
#import "EVLocationManager.h"
#import "NSTimeZone+EVA.h"


#define EV_HOST_ADDRESS @"https://vproxy.evaws.com:443"
#define EV_API_VERSION @"v1.0"


@interface EVApplication () <EVAudioRecorderDelegate, EVAudioDataStreamerDelegate, EVLocationManagerDelegate>

@property (nonatomic, strong, readwrite) NSString* APIKey;
@property (nonatomic, strong, readwrite) NSString* siteCode;
@property (nonatomic, strong, readwrite) NSString* apiVersion;

@property (nonatomic, assign, readwrite) BOOL isReady;

@property (nonatomic, strong, readwrite) NSMutableDictionary* chatViewControllerPathRewrites;
@property (nonatomic, strong, readwrite) EVLocationManager *locationManager;

@property (nonatomic, strong, readwrite) EVAudioRecorder* soundRecorder;
@property (nonatomic, strong, readwrite) EVAudioConvertionOperation* flacConverter;
@property (nonatomic, strong, readwrite) EVAudioDataStreamer* dataStreamer;


- (void)setAVSession;
- (void)setupRecorderChain;
- (void)updateURL;

@end

@implementation EVApplication

- (id)traverseResponderChainForUIViewControllerForView:(UIView*)view {
    id nextResponder = [view nextResponder];
    if ([nextResponder isKindOfClass:[UIViewController class]]) {
        return nextResponder;
    } else if ([nextResponder isKindOfClass:[UIView class]]) {
        return [self traverseResponderChainForUIViewControllerForView:nextResponder];
    } else {
        return nil;
    }
}

+ (instancetype)sharedApplication {
    static EVApplication* sharedInstance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedInstance = [[EVApplication alloc] init];
    });
    return sharedInstance;
}


- (void)setupRecorderChain {
    self.soundRecorder = [EVAudioRecorder new];
    self.soundRecorder.delegate = self;
    
    self.soundRecorder.audioFormat = kAudioFormatLinearPCM;
    self.soundRecorder.audioFormatFlags = kLinearPCMFormatFlagIsSignedInteger | kLinearPCMFormatFlagIsPacked;
    self.soundRecorder.audioSampleRate = 16000.0;
    self.soundRecorder.audioNumberOfChannels = 1;
    self.soundRecorder.audioBitsPerSample = 16;
    
    self.soundRecorder.levelSampleTime = 0.03; // how often check silence moments
    self.soundRecorder.minNoiseTime = 0.10;  // must have noise for at least this much time to start considering silence
    self.soundRecorder.preRecordingTime = 0.12; // will start listening to noise/silence only after this time
    self.soundRecorder.silentStopRecordTime = 0.7; // time of silence for record stop

    
    self.flacConverter = [EVAudioConvertionOperation new];
    self.flacConverter.sampleRate = 16000;
    self.flacConverter.bitsPerSample = 16;
    self.flacConverter.numberOfChannels = 1;
    
    self.dataStreamer = [[[EVAudioDataStreamer alloc] initWithOperationChainLength:10] autorelease];
    self.dataStreamer.sampleRate = 16000;
    self.dataStreamer.delegate = self;
    
    self.soundRecorder.dataProviderDelegate = self.flacConverter;
    self.flacConverter.dataProviderDelegate = self.dataStreamer;
}

- (instancetype)init {
    self = [super init];
    if (self != nil) {
        self.chatViewControllerClass = [EVVoiceChatViewController class];
        self.chatButtonClass = [EVVoiceChatButton class];
        self.chatViewControllerPathRewrites = [NSMutableDictionary dictionary];
        [self.chatViewControllerPathRewrites setObject:@"inputToolbar.contentView." forKey:@"toolbar."];
        [self.chatViewControllerPathRewrites setObject:@"" forKey:@"controller."];
        self.defaultButtonBottomOffset = 60.0f;
        
        self.locationManager = [EVLocationManager new];
        self.locationManager.delegate = self;
        
        self.currentSessionID = EV_NEW_SESSION_ID;
        self.serverHost = EV_HOST_ADDRESS;
        self.apiVersion = EV_API_VERSION;
        
        self.sendVolumeLevelUpdates = YES;
        self.isReady = NO;
        
        [self setupRecorderChain];
        
        [self setAVSession];
    }
    return self;
}

- (EVVoiceChatButton*)addButtonInController:(UIViewController*)viewController {
    UIViewController* addCtrl = viewController;
    while ([addCtrl.view isKindOfClass:[UIScrollView class]]) {
        addCtrl = ([addCtrl parentViewController] != nil) ? [addCtrl parentViewController] : [addCtrl presentingViewController];
    }
    addCtrl = (addCtrl == nil) ? viewController : addCtrl;
    return [self addButtonInView:addCtrl.view inController:viewController];
}

- (EVVoiceChatButton*)addButtonInView:(UIView*)view inController:(UIViewController *)viewController {
    EVVoiceChatButton* button = [[[EVVoiceChatButton alloc] init] autorelease];
    button.translatesAutoresizingMaskIntoConstraints = NO;
    button.connectedController = viewController;
    EVViewControllerVisibilityObserver *visObserver = [[EVViewControllerVisibilityObserver alloc] initWithController:viewController andDelegate:button];
    button.controllerObserverDelegate = visObserver;
    [visObserver release];
    [view addSubview:button];
    [button ev_pinToBottomCenteredWithOffset:self.defaultButtonBottomOffset];
    [view setNeedsUpdateConstraints];
    return button;
}


- (void)showChatViewController:(id)sender withViewSettings:(NSDictionary*)viewSettings {
    UIViewController *ctrl = nil;
    if ([sender isKindOfClass:[UIViewController class]]) {
        ctrl = sender;
    } else if ([sender isKindOfClass:[UIView class]]) {
        ctrl = [self traverseResponderChainForUIViewControllerForView:sender];
    }
    EVVoiceChatViewController* viewCtrl = [[[self.chatViewControllerClass alloc] init] autorelease];
    viewCtrl.evApplication = self;
    self.delegate = viewCtrl;
    id button = [[viewSettings objectForKey:kEVVoiceChatButtonSettigsKey] nonretainedObjectValue];
    if (button != nil) {
        viewCtrl.openButton = button;
        NSMutableDictionary* mutableSettings = [NSMutableDictionary dictionaryWithDictionary:viewSettings];
        [mutableSettings removeObjectForKey:kEVVoiceChatButtonSettigsKey];
        viewSettings = mutableSettings;
    }
   
    [viewCtrl updateViewFromSettings:viewSettings];
    [ctrl presentViewController:viewCtrl animated:YES completion:^{
        [self.locationManager startLocationService];
    }];
}

- (void)hideChatViewController:(id)sender {
    if (self.soundRecorder.isRecording) {
        [self cancelRecording];
    }
    UIViewController *ctrl = nil;
    if ([sender isKindOfClass:[UIViewController class]]) {
        ctrl = sender;
    } else if ([sender isKindOfClass:[UIView class]]) {
        ctrl = [self traverseResponderChainForUIViewControllerForView:sender];
    }
    [ctrl dismissViewControllerAnimated:YES completion:^{
        [self.locationManager stopLocationService];
    }];
}

#pragma mark === Eva Methods ===

- (void)updateURL {
    
    NSMutableString *urlStr = [NSMutableString stringWithFormat:@"%@", self.serverHost];
    if (self.apiVersion != nil) {
        [urlStr appendFormat:@"/%@", self.apiVersion];
    }
    [urlStr appendFormat:@"?site_code=%@&api_key=%@&locale=%@&time_zone=%@&uid=%@", self.siteCode, self.APIKey, [[NSLocale currentLocale] objectForKey:NSLocaleCountryCode], [[NSTimeZone localTimeZone] stringOffsetFromGMT], [[[UIDevice currentDevice] identifierForVendor] UUIDString]];
    
    if (self.deviceLatitude != 0.0 || self.deviceLongtitude != 0.0) { // Check if location services returned a valid value
        [urlStr appendFormat:@"&latitude=%.5f&longitude=%.5f", self.deviceLatitude, self.deviceLongtitude];
    }
    if (self.currentSessionID != nil) {
        [urlStr appendFormat:@"&session_id=%@", self.currentSessionID];
    }
    //    if (ipAddress_ != nil) {
    //        urlStr = [NSString stringWithFormat:@"%@&ip_addr=%@",urlStr,ipAddress_];
    //    }
    
//    if (bias_ != nil) {
//        urlStr = [NSString stringWithFormat:@"%@&bias=%@",urlStr,[self makeSafeString:bias_]];
//    }
//    if (home_ != nil) {
//        urlStr = [NSString stringWithFormat:@"%@&home=%@",urlStr,[self makeSafeString:home_]];
//    }
//    if (language_ != nil) {
//        urlStr = [NSString stringWithFormat:@"%@&language=%@",urlStr,language_];
//    }
//    if (scope_ != nil) {
//        urlStr = [NSString stringWithFormat:@"%@&scope=%@",urlStr,[self makeSafeString:scope_]];
//    }
//    if (context_ != nil) {
//        urlStr = [NSString stringWithFormat:@"%@&context=%@",urlStr,[self makeSafeString:context_]];
//    }
//    
//    urlStr = [NSString stringWithFormat:@"%@&audio_files_used=%@%@%@%@",urlStr,
//              audioFileStartRecord_ == nil ? @"N": @"Y",
//              audioFileRequestedEndRecord_ == nil ? @"N" : @"Y",
//              audioFileVadEndRecord_ == nil ? @"N" : @"Y",
//              audioFileCanceledRecord_ == nil ? @"N" : @"Y"
//              ];
//    
//    if (optional_dictionary_ != nil) {
//        urlStr = [NSString stringWithFormat:@"%@&%@",urlStr,[self urlSafeEncodedOptionalParametersString]];
//    }
    [urlStr appendFormat:@"&device=%@&ios_ver=%@", [[UIDevice currentDevice] model], [[UIDevice currentDevice] systemVersion]];
    [urlStr appendFormat:@"&sdk_version=ios-%@", EV_KIT_VERSION];
    
    // Escape URL
    [urlStr replaceOccurrencesOfString:@" " withString:@"+" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [urlStr length])];
    
    self.dataStreamer.webServiceURL = [NSURL URLWithString:[urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
}

- (void)setAPIKey:(NSString*)apiKey andSiteCode:(NSString*)siteCode {
    self.APIKey = apiKey;
    self.siteCode = siteCode;
    if (apiKey != nil && siteCode != nil) {
        self.isReady = YES;
    } else {
        self.isReady = NO;
    }
    [self updateURL];
}

- (void)setCurrentSessionID:(NSString *)currentSessionID {
    [_currentSessionID release];
    _currentSessionID = (currentSessionID == nil) ? EV_NEW_SESSION_ID : currentSessionID;
    [_currentSessionID retain];
    [self updateURL];
}

- (void)setIsReady:(BOOL)isReady {
    BOOL old = _isReady;
    _isReady = isReady;
    if (isReady && !old) {  //Check that value changed from NO to YES and send event.
        [self.delegate evApplicationIsReady:self];
    }
}

// Start record from current active Audio, If 'withNewSession' is set to 'FALSE' the function keeps last session. //
- (void)startRecordingWithNewSession:(BOOL)withNewSession {
    if (!self.isReady) {
        EV_LOG_ERROR(@"EVApplication is not ready!");
        return;
    }
    if (withNewSession) {
        self.currentSessionID = EV_NEW_SESSION_ID;
    }
    self.isReady = NO;
    [self.soundRecorder startRecording:EV_DEFAULT_MAX_RECORDING_TIME withAutoStop:YES];
}

// Stop record, Would send the record to Eva for analyze //
- (void)stopRecording {
    [self.soundRecorder stopRecording];
}

// Cancel record, Would cancel operation, record won't send to Eva (don't expect response) //
- (void)cancelRecording {
    [self.soundRecorder cancelRecording];
}


- (void)setAVSession {
    EV_LOG_DEBUG(@"Setting session to Play and Record");
    AVAudioSession *session = [AVAudioSession sharedInstance];
    NSError *error = nil;
    
        
    [session setCategory:AVAudioSessionCategoryPlayAndRecord withOptions:AVAudioSessionCategoryOptionDefaultToSpeaker | AVAudioSessionCategoryOptionAllowBluetooth error:&error];
    if (error != nil) {
        EV_LOG_ERROR(@"Failed to setCategory for AVAudioSession! %@", error);
    }
    [session setMode:AVAudioSessionModeVoiceChat error:&error];
    if (error != nil) {
        EV_LOG_ERROR(@"Failed to setMode for AVAudioSession! %@", error);
    }
}

#pragma mark === Managers Delegates Methods ===

- (void)audioDataStreamerFailed:(EVAudioDataStreamer*)streamer withError:(NSError*)error {
    [error retain];
    dispatch_async(dispatch_get_main_queue(), ^{
        [error autorelease];
        EV_LOG_ERROR(@"Streamer failed with error: %@", error);
        if ([error code] == EVAudioRecorderCancelledErrorCode) {
            if ([self.delegate respondsToSelector:@selector(evApplicationRecordingIsCancelled:)]) {
                [self.delegate evApplicationRecordingIsCancelled:self];
            }
        } else {
            [self.delegate evApplication:self didObtainError:error];
        }
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.isReady = YES;
        });
    });
}

- (void)audioDataStreamerFinished:(EVAudioDataStreamer *)streamer withResponse:(NSDictionary*)response {
    [response retain];
    dispatch_async(dispatch_get_main_queue(), ^{
        [response autorelease];
        if ([response objectForKey:@"session_id"] != nil) {
            self.currentSessionID = [response objectForKey:@"session_id"];
        }
        [self.delegate evApplication:self didObtainResponse:response];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.isReady = YES;
        });
    });
}

- (void)locationManager:(EVLocationManager*)manager didObtainNewLongtitude:(double)lng andLatitude:(double)lat {
    self.deviceLatitude = lat;
    self.deviceLongtitude = lng;
    [self updateURL];
}

- (void)locationManager:(EVLocationManager*)manager didObtainError:(NSError*)error {
    EV_LOG_ERROR(@"Location error: %@", error);
}


- (void)recorder:(EVAudioRecorder*)recorder peakVolumeLevel:(float)peakLevel andAverageVolumeLevel:(float)averageLevel {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.sendVolumeLevelUpdates && [self.delegate respondsToSelector:@selector(evApplication:recordingVolumePeak:andAverage:)]) {
            [self.delegate evApplication:self recordingVolumePeak:peakLevel andAverage:averageLevel];
        }
    });
}

- (void)recorderStartedRecording:(EVAudioRecorder*)recorder {
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.delegate respondsToSelector:@selector(evApplicationRecordingIsStarted:)]) {
        [self.delegate evApplicationRecordingIsStarted:self];
        }
    });
}
- (void)recorderFinishedRecording:(EVAudioRecorder *)recorder {
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.delegate respondsToSelector:@selector(evApplicationRecordingIsStoped:)]) {
            [self.delegate evApplicationRecordingIsStoped:self];
        }
    });
}

@end
