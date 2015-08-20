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
#import <AVFoundation/AVFoundation.h>
#import "EVAPIRequest.h"
#import "EVSearchDelegate.h"

#import "EVAudioRecorder.h"
#import "EVAudioConvertionOperation.h"
#import "EVAudioDataStreamer.h"
#import "EVLocationManager.h"
#import "NSTimeZone+EVA.h"


#define EV_HOST_ADDRESS @"http://vproxy.evaws.com"
#define EV_HOST_ADDRESS_FOR_TEXT  EV_HOST_ADDRESS
#define EV_API_VERSION @"v1.0"


@interface EVApplication () <EVAudioRecorderDelegate, EVAudioDataStreamerDelegate, EVLocationManagerDelegate, EVAPIRequestDelegate>

@property (nonatomic, strong, readwrite) NSString* APIKey;
@property (nonatomic, strong, readwrite) NSString* siteCode;
@property (nonatomic, strong, readwrite) NSString* apiVersion;

@property (nonatomic, assign, readwrite) BOOL isReady;

@property (nonatomic, strong, readwrite) NSMutableDictionary* chatViewControllerPathRewrites;
@property (nonatomic, strong, readwrite) EVLocationManager *locationManager;

@property (nonatomic, strong, readwrite) EVAudioRecorder* soundRecorder;
@property (nonatomic, strong, readwrite) EVAudioConvertionOperation* flacConverter;
@property (nonatomic, strong, readwrite) EVAudioDataStreamer* dataStreamer;

@property (nonatomic, strong, readwrite) EVAPIRequest* currentApiRequest;

@property (nonatomic, strong, readwrite) NSDictionary* applicationSounds;


- (void)setAVSession;
- (void)setupRecorderChain;
- (void)updateURL;
- (NSString*)getURLStringWithServer:(NSString*)server;
- (void)apiQuery:(NSURL*)url;
- (id)traverseResponderChainForUIViewControllerForView:(UIView*)view;
- (id)traverseResponderChainForDelegate:(UIResponder*)fromObject;
- (id)searchForDelegate:(UIView*)fromView;

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

- (id)traverseResponderChainForDelegate:(UIResponder*)fromObject {
    UIResponder* nextResponder = [fromObject nextResponder];
    if ([nextResponder conformsToProtocol:@protocol(EVSearchDelegate)]) {
        return nextResponder;
    } else if (nextResponder != nil) {
        return [self traverseResponderChainForDelegate:nextResponder];
    }
    return nil;
}

- (id)searchForDelegate:(UIView*)fromView {
    if ([[fromView subviews] count] == 0) {
        return [self traverseResponderChainForDelegate:fromView];
    } else {
        for (UIView* subview in fromView.subviews) {
            id delegate = [self searchForDelegate:subview];
            if (delegate != nil) {
                return delegate;
            }
        }
    }
    return nil;
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
        self.textServerHost = EV_HOST_ADDRESS_FOR_TEXT;
        self.apiVersion = EV_API_VERSION;
        self.scope = [EVSearchScope scopeWithContextTypes:EVSearchContextTypesAll];
        
        self.sendVolumeLevelUpdates = YES;
        self.isReady = NO;
        self.useLocationServices = YES;
        self.highlightText = YES;
        self.applicationSounds = [NSMutableDictionary dictionaryWithCapacity:4];
        
        EVApplicationSound* high = [EVApplicationSound soundWithPath:[[NSBundle bundleForClass:[self class]] pathForResource:@"voice_high" ofType:@"aif"]];
        EVApplicationSound* low = [EVApplicationSound soundWithPath:[[NSBundle bundleForClass:[self class]] pathForResource:@"voice_low" ofType:@"aif"]];
        [self setSound:high forApplicationState:EVApplicationStateSoundRecordingStarted];
        [self setSound:low forApplicationState:EVApplicationStateSoundRecordingStoped];
        [self setSound:low forApplicationState:EVApplicationStateSoundCancelled];
        [self setSound:low forApplicationState:EVApplicationStateSoundRequestFinished];
        
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
    
    [view addSubview:button];
    [button ev_pinToBottomCenteredWithOffset:self.defaultButtonBottomOffset];
    [view setNeedsUpdateConstraints];
    return button;
}


- (void)showChatViewController:(UIResponder*)sender withViewSettings:(NSDictionary*)viewSettings {
    UIViewController *ctrl = nil;
    id delegate = nil;
    if ([sender isKindOfClass:[UIViewController class]]) {
        ctrl = (UIViewController*)sender;
    } else if ([sender isKindOfClass:[UIView class]]) {
        if ([sender isKindOfClass:[EVVoiceChatButton class]]) {
            if ([(EVVoiceChatButton*)sender connectedController] == nil) {
                [(EVVoiceChatButton*)sender setConnectedController:[self traverseResponderChainForUIViewControllerForView:((EVVoiceChatButton*)sender)]];
            }
            ctrl = [(EVVoiceChatButton*)sender connectedController];
        } else {
            ctrl = [self traverseResponderChainForUIViewControllerForView:((UIView*)sender)];
        }
    }
    if ([ctrl conformsToProtocol:@protocol(EVSearchDelegate)]) {
        delegate = ctrl;
    } else {
        delegate = [self searchForDelegate:ctrl.view];
    }
    if (delegate == nil) {
        EV_LOG_ERROR(@"Delegate not found in responder chain. Check protocols on delegate");
    }
    EVVoiceChatViewController* viewCtrl = [[[self.chatViewControllerClass alloc] init] autorelease];
    viewCtrl.evApplication = self;
    self.delegate = viewCtrl;
    viewCtrl.delegate = delegate;
   
    [viewCtrl updateViewFromSettings:viewSettings];
    [ctrl presentViewController:viewCtrl animated:YES completion:^{
        if (self.useLocationServices) {
            [self.locationManager startLocationService];
        }
    }];
}

- (void)hideChatViewController:(UIResponder*)sender {
    if (self.soundRecorder.isRecording) {
        [self cancelRecording];
    }
    UIViewController *ctrl = nil;
    if ([sender isKindOfClass:[UIViewController class]]) {
        ctrl = (UIViewController*)sender;
    } else if ([sender isKindOfClass:[UIView class]]) {
        if ([sender isKindOfClass:[EVVoiceChatButton class]]) {
            ctrl = [(EVVoiceChatButton*)sender connectedController];
        } else {
            ctrl = [self traverseResponderChainForUIViewControllerForView:((UIView*)sender)];
        }
    }
    [ctrl dismissViewControllerAnimated:YES completion:^{
        if (self.useLocationServices) {
            [self.locationManager stopLocationService];
        }
    }];
}

#pragma mark === Eva Methods ===

- (NSString*)getURLStringWithServer:(NSString*)server {
    NSMutableString *urlStr = [NSMutableString stringWithFormat:@"%@", server];
    if (self.apiVersion != nil) {
        [urlStr appendFormat:@"/%@", self.apiVersion];
    }
    [urlStr appendFormat:@"?site_code=%@&api_key=%@&locale=%@&time_zone=%@&uid=%@", self.siteCode, self.APIKey, [[NSLocale currentLocale] objectForKey:NSLocaleCountryCode], [[NSTimeZone localTimeZone] stringOffsetFromGMT], [[[UIDevice currentDevice] identifierForVendor] UUIDString]];
    
    if (self.deviceLatitude != 0.0 || self.deviceLongitude != 0.0) { // Check if location services returned a valid value
        [urlStr appendFormat:@"&latitude=%.5f&longitude=%.5f", self.deviceLatitude, self.deviceLongitude];
    }
    if (self.currentSessionID != nil) {
        [urlStr appendFormat:@"&session_id=%@", self.currentSessionID];
    }
    
    //    if (bias_ != nil) {
    //        urlStr = [NSString stringWithFormat:@"%@&bias=%@",urlStr,[self makeSafeString:bias_]];
    //    }
    //    if (home_ != nil) {
    //        urlStr = [NSString stringWithFormat:@"%@&home=%@",urlStr,[self makeSafeString:home_]];
    //    }
    //    if (language_ != nil) {
    //        urlStr = [NSString stringWithFormat:@"%@&language=%@",urlStr,language_];
    //    }
    if (self.scope != nil) {
        [urlStr appendFormat:@"&scope=%@", [self.scope requestParameterValue]];
    }
    if (self.context != nil) {
        [urlStr appendFormat:@"&context=%@", [self.context requestParameterValue]];
    }
    [urlStr appendFormat:@"&audio_files_used=%@%@%@%@",
                         [self soundForState:EVApplicationStateSoundRecordingStarted] == nil ? @"N": @"Y",
                         [self soundForState:EVApplicationStateSoundRequestFinished] == nil ? @"N" : @"Y",
                         [self soundForState:EVApplicationStateSoundRecordingStoped] == nil ? @"N" : @"Y",
                         [self soundForState:EVApplicationStateSoundCancelled] == nil ? @"N" : @"Y"];
    //
    //    if (optional_dictionary_ != nil) {
    //        urlStr = [NSString stringWithFormat:@"%@&%@",urlStr,[self urlSafeEncodedOptionalParametersString]];
    //    }
    if (self.highlightText) {
        [urlStr appendFormat:@"&add_text=1"];
    }
    [urlStr appendFormat:@"&device=%@&ios_ver=%@", [[UIDevice currentDevice] model], [[UIDevice currentDevice] systemVersion]];
    [urlStr appendFormat:@"&sdk_version=ios-%@", EV_KIT_VERSION];
    
    // Escape URL
    [urlStr replaceOccurrencesOfString:@" " withString:@"+" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [urlStr length])];
    return urlStr;
}

- (void)updateURL {
    NSString* urlStr = [self getURLStringWithServer:self.serverHost];
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

- (void)setHighlightText:(BOOL)highlightText {
    _highlightText = highlightText;
    [self updateURL];
}

- (void)setUseLocationServices:(BOOL)useLocationServices {
    _useLocationServices = useLocationServices;
    if (!useLocationServices) {
        self.deviceLatitude = 0.0;
        self.deviceLongitude = 0.0;
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

- (EVApplicationSound*)soundForState:(EVApplicationStateSound)state {
    return [self.applicationSounds objectForKey:@(state)];
}

- (void)setSound:(EVApplicationSound*)sound forApplicationState:(EVApplicationStateSound)state {
    NSMutableDictionary* dict = (NSMutableDictionary*)self.applicationSounds;
    if (sound == nil) {
        [dict removeObjectForKey:@(state)];
    } else {
        [dict setObject:sound forKey:@(state)];
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
    [self.currentApiRequest cancel];
    [self.soundRecorder cancelRecording];
}


- (void)apiQuery:(NSURL*)url {
    self.isReady = NO;
    EV_LOG_DEBUG(@"API Query: %@", url);
    self.currentApiRequest = [[EVAPIRequest alloc] initWithURL:url timeout:self.dataStreamer.connectionTimeout andDelegate:self];
    [self.currentApiRequest release];
    [self.currentApiRequest start];
}

- (void)queryText:(NSString*)text withNewSession:(BOOL)withNewSession {
    if (!self.isReady) {
        EV_LOG_ERROR(@"EVApplication is not ready!");
        return;
    }
    if (withNewSession) {
        self.currentSessionID = EV_NEW_SESSION_ID;
    }
    NSString* urlStr = [self getURLStringWithServer:self.textServerHost];
    urlStr = [urlStr stringByAppendingFormat:@"&input_text=%@", [text stringByReplacingOccurrencesOfString:@" " withString:@"+"]];
    NSURL* url = [NSURL URLWithString:[urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    [self apiQuery:url];
}

- (void)editLastQueryWithText:(NSString*)text {
    NSString* urlStr = [self getURLStringWithServer:self.textServerHost];
    if (text != nil) {
        urlStr = [urlStr stringByAppendingFormat:@"&edit_last_utterance=true&input_text=%@", [text stringByReplacingOccurrencesOfString:@" " withString:@"+"]];
    } else {
        urlStr = [urlStr stringByAppendingFormat:@"&edit_last_utterance=true&input_text="];
    }
    
    NSURL* url = [NSURL URLWithString:[urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    [self apiQuery:url];
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
            [[self soundForState:EVApplicationStateSoundCancelled] play];
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
    EV_LOG_DEBUG(@"Response: %@", response);
    [[self soundForState:EVApplicationStateSoundRequestFinished] play];
    @try {
        EVResponse* evResponse = [[EVResponse alloc] initWithResponse:response];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [evResponse autorelease];
            self.currentSessionID = evResponse.sessionId;
            [self.delegate evApplication:self didObtainResponse:evResponse];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                self.isReady = YES;
            });
        });
    }
    @catch (NSException *exception) {
        [self audioDataStreamerFailed:streamer withError:[NSError errorWithCode:100 andDescription:[exception reason]]];
    }
}

- (void)apiRequest:(EVAPIRequest*)request gotResponse:(NSDictionary*)response {
    [self audioDataStreamerFinished:nil withResponse:response];
    self.currentApiRequest = nil;
}
- (void)apiRequest:(EVAPIRequest *)request gotAnError:(NSError*)error {
    [self audioDataStreamerFailed:nil withError:error];
    self.currentApiRequest = nil;
}

- (void)locationManager:(EVLocationManager*)manager didObtainNewLongitude:(double)lng andLatitude:(double)lat {
    self.deviceLatitude = lat;
    self.deviceLongitude = lng;
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
        [[self soundForState:EVApplicationStateSoundRecordingStarted] play];
        if ([self.delegate respondsToSelector:@selector(evApplicationRecordingIsStarted:)]) {
            [self.delegate evApplicationRecordingIsStarted:self];
        }
    });
}
- (void)recorderFinishedRecording:(EVAudioRecorder *)recorder {
    dispatch_async(dispatch_get_main_queue(), ^{
        [[self soundForState:EVApplicationStateSoundRecordingStoped] play];
        if ([self.delegate respondsToSelector:@selector(evApplicationRecordingIsStoped:)]) {
            [self.delegate evApplicationRecordingIsStoped:self];
        }
    });
}

@end
