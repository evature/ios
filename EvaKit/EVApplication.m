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

@interface EVApplication () <EvaDelegate, EVAudioRecorderDelegate, EVAudioDataStreamerDelegate>

@property (nonatomic, strong, readwrite) NSMutableDictionary* chatViewControllerPathRewrites;
@property (nonatomic, strong, readwrite) Eva* eva;

@property (nonatomic, strong, readwrite) EVAudioRecorder* soundRecorder;
@property (nonatomic, strong, readwrite) EVAudioConvertionOperation* flacConverter;
@property (nonatomic, strong, readwrite) EVAudioDataStreamer* dataStreamer;


- (void)setAVSession;
- (void)setupRecorderChain;

@end

@implementation EVApplication

@dynamic APIKey;
@dynamic siteCode;
@dynamic sendVolumeLevelUpdates;

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
    self.soundRecorder.isDebugMode = YES;
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
    self.flacConverter.isDebugMode = YES;
    
    self.dataStreamer = [[[EVAudioDataStreamer alloc] initWithOperationChainLength:10] autorelease];
    self.dataStreamer.sampleRate = 16000;
    self.dataStreamer.isDebugMode = YES;
    self.dataStreamer.delegate = self;
    
    self.soundRecorder.dataProviderDelegate = self.flacConverter;
    self.flacConverter.dataProviderDelegate = self.dataStreamer;
}

- (void)audioDataStreamerFailed:(EVAudioDataStreamer*)streamer withError:(NSError*)error {
    [error retain];
    dispatch_async(dispatch_get_main_queue(), ^{
        [error autorelease];
        if ([error code] == EVAudioRecorderCancelledErrorCode) {
            if ([self.delegate respondsToSelector:@selector(evApplicationRecordingIsCancelled:)]) {
                [self.delegate evApplicationRecordingIsCancelled:self];
            }
        } else {
            [self.delegate evApplication:self didObtainError:error];
        }
        NSLog(@"Streamer failed with error: %@", error);
    });
}
- (void)audioDataStreamerFinished:(EVAudioDataStreamer *)streamer withResponse:(NSDictionary*)response {
    [response retain];
    dispatch_async(dispatch_get_main_queue(), ^{
        [response autorelease];
        [self.delegate evApplication:self didObtainResponse:response];
    });
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
        self.eva = [[Eva alloc] init];
//        [self.eva setRecorderBufferSize:0];
//        [self.eva setFlacBufferSize:0];
//        [self.eva setFlacFrameSize:0];
//        [self.eva setHttpBufferSize:0];
//        [self.eva setDelegate:self];
        self.sendVolumeLevelUpdates = YES;
        
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
    [ctrl presentViewController:viewCtrl animated:YES completion:^{}];
}

#pragma mark === Eva Methods ===

- (NSString*)APIKey {
    return self.eva.evaAPIKey;
}

- (NSString*)siteCode {
    return self.eva.evaSiteCode;
}

- (void)setAPIKey:(NSString*)apiKey andSiteCode:(NSString*)siteCode {
    [self.eva setAPIkey:apiKey withSiteCode:siteCode withMicLevel:self.sendVolumeLevelUpdates];
    self.dataStreamer.webServiceURL = [self.eva getUrl:@"https://vproxy.evaws.com:443"];
}

// Start record from current active Audio, If 'withNewSession' is set to 'FALSE' the function keeps last session. //
- (void)startRecordingWithNewSession:(BOOL)withNewSession {
    //[self.eva startRecord:withNewSession];
    [self.soundRecorder startRecording:10.0f withAutoStop:YES];
}

// Stop record, Would send the record to Eva for analyze //
- (void)stopRecording {
    [self.soundRecorder stopRecording];
    //[self.eva stopRecord];
}

// Cancel record, Would cancel operation, record won't send to Eva (don't expect response) //
- (void)cancelRecording {
    [self.soundRecorder cancelRecording];
    //[self.eva cancelRecord];
}

- (BOOL)sendVolumeLevelUpdates {
    return self.eva.sendMicLevel;
}

- (void)setSendVolumeLevelUpdates:(BOOL)sendVolumeLevelUpdates {
    self.eva.sendMicLevel = sendVolumeLevelUpdates;
}

- (void)setAVSession {
    NSLog(@"Setting session to Play and Record");
    AVAudioSession *session = [AVAudioSession sharedInstance];
    NSError *error = nil;
    
        
    [session setCategory:AVAudioSessionCategoryPlayAndRecord withOptions:AVAudioSessionCategoryOptionDefaultToSpeaker | AVAudioSessionCategoryOptionAllowBluetooth error:&error];
    if (error != nil) {
        NSLog(@"Failed to setCategory for AVAudioSession! %@", error);
    }
    [session setMode:AVAudioSessionModeVoiceChat error:&error];
    if (error != nil) {
        NSLog(@"Failed to setMode for AVAudioSession! %@", error);
    }
}

#pragma mark === Eva Delegate Methods ===

- (void)recorder:(EVAudioRecorder*)recorder peakVolumeLevel:(float)peakLevel andAverageVolumeLevel:(float)averageLevel {
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.delegate respondsToSelector:@selector(evApplication:recordingVolumePeak:andAverage:)]) {
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

// Required: Called when receiving valid data from Eva.
- (void)evaDidReceiveData:(NSData *)dataFromServer {
    NSError *e = nil;
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:dataFromServer options:0 error:&e];
    if (self.delegate != nil) {
        [self.delegate evApplication:self didObtainResponse:dict];
    }
}

// Required: Called when receiving an error from Eva.
- (void)evaDidFailWithError:(NSError *)error {
    if (self.delegate != nil) {
        [self.delegate evApplication:self didObtainError:error];
    }
}

// Optional: Called when recording. averagePower and peakPower are in decibels. Must be implemented if shouldSendMicLevel is TRUE.
- (void)evaMicLevelCallbackAverage: (float)averagePower andPeak: (float)peakPower {
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(evApplication:recordingVolumePeak:andAverage:)]) {
        [self.delegate evApplication:self recordingVolumePeak:peakPower andAverage:averagePower];
    }
}

//// Optional: Called everytime the record stops, Must be implemented if shouldSendMicLevel is TRUE.
//- (void)evaMicStopRecording {
//    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(evApplicationRecordIsStoped:)]) {
//        [self.delegate evApplicationRecordIsStoped:self];
//    }
//}
//
//// Optional: Called when initiation process is complete after setting the API keys.
//- (void)evaRecorderIsReady {
//    [self setAVSession];
//    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(evApplicationRecorderIsReady:)]) {
//        [self.delegate evApplicationRecorderIsReady:self];
//    }
//}

@end
