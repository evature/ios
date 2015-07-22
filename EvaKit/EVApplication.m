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

@interface EVApplication () <EvaDelegate>

@property (nonatomic, strong, readwrite) NSMutableDictionary* chatViewControllerPathRewrites;
@property (nonatomic, strong, readwrite) Eva* eva;

- (void)setAVSession;

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

- (instancetype)init {
    self = [super init];
    if (self != nil) {
        self.chatViewControllerClass = [EVVoiceChatViewController class];
        self.chatButtonClass = [EVVoiceChatButton class];
        self.chatViewControllerPathRewrites = [NSMutableDictionary dictionary];
        [self.chatViewControllerPathRewrites setObject:@"inputToolbar.contentView." forKey:@"toolbar."];
        [self.chatViewControllerPathRewrites setObject:@"" forKey:@"controller."];
        self.defaultButtonBottomOffset = 30.0f;
        self.eva = [[Eva alloc] init];
        [self.eva setRecorderBufferSize:0];
        [self.eva setFlacBufferSize:0];
        [self.eva setFlacFrameSize:0];
        [self.eva setHttpBufferSize:0];
        [self.eva setDelegate:self];
        self.sendVolumeLevelUpdates = YES;
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
}

// Start record from current active Audio, If 'withNewSession' is set to 'FALSE' the function keeps last session. //
- (void)startRecordingWithNewSession:(BOOL)withNewSession {
    [self.eva startRecord:withNewSession];
}

// Stop record, Would send the record to Eva for analyze //
- (void)stopRecording {
    [self.eva stopRecord];
}

// Cancel record, Would cancel operation, record won't send to Eva (don't expect response) //
- (void)cancelRecording {
    [self.eva cancelRecord];
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
    
        
    [session setCategory:AVAudioSessionCategoryPlayAndRecord withOptions:AVAudioSessionCategoryOptionDefaultToSpeaker error:&error];
    if (error != nil) {
        NSLog(@"Failed to setCategory for AVAudioSession! %@", error);
    }
    
    //    if ([session respondsToSelector:@selector(overrideOutputAudioPort:error:)]){
    //        [session overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker
    //                                   error:&error];
    //    }else{
    //        // Do somthing smart for iOS 5 //
    //    }
    //    if (error != nil) {
    //        NSLog(@"AVAudioSession error overrideOutputAudioPort:%@",error);
    //    }
    
    [session setActive:YES error:&error];
    if (error != nil) {
        NSLog(@"Failed to setActive for AVAudioSession!  %@", error);
    }
}

#pragma mark === Eva Delegate Methods ===

// Required: Called when receiving valid data from Eva.
- (void)evaDidReceiveData:(NSData *)dataFromServer {
    NSError *e = nil;
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:dataFromServer options:0 error:&e];
    if (self.delegate != nil) {
        [self.delegate evApplication:self didObtainResponseFromServer:dict];
    }
}

// Required: Called when receiving an error from Eva.
- (void)evaDidFailWithError:(NSError *)error {
    if (self.delegate != nil) {
        [self.delegate evApplication:self didObtainErrorFromServer:error];
    }
}

// Optional: Called when recording. averagePower and peakPower are in decibels. Must be implemented if shouldSendMicLevel is TRUE.
- (void)evaMicLevelCallbackAverage: (float)averagePower andPeak: (float)peakPower {
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(evApplication:recordingVolumePeak:andAverage:)]) {
        [self.delegate evApplication:self recordingVolumePeak:peakPower andAverage:averagePower];
    }
}

// Optional: Called everytime the record stops, Must be implemented if shouldSendMicLevel is TRUE.
- (void)evaMicStopRecording {
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(evApplicationRecordIsStoped:)]) {
        [self.delegate evApplicationRecordIsStoped:self];
    }
}

// Optional: Called when initiation process is complete after setting the API keys.
- (void)evaRecorderIsReady {
    [self setAVSession];
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(evApplicationRecorderIsReady:)]) {
        [self.delegate evApplicationRecorderIsReady:self];
    }
}

@end
