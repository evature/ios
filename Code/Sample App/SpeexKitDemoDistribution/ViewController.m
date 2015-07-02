//
//  ViewController.m
//  speextest
//
//  Created by Halle Winkler on 2/17/12.
//  Copyright (c) 2012 Politepix. All rights reserved.
//
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVAudioPlayer.h>
#import "ViewController.h"

#import <SpeexKitLicensed/SpeexFileEncodingController.h>
#import <SpeexKitLicensed/SpeexFileDecodingController.h>
#import <SpeexKitLicensed/SpeexNSDataEncodingController.h>
#import <SpeexKitLicensed/SpeexNSDataDecodingController.h>
#import <SpeexKitLicensed/AudioFileWrapperController.h>

//#import <SpeexKitDemo/SpeexFileEncodingController.h>
//#import <SpeexKitDemo/SpeexFileDecodingController.h>
//#import <SpeexKitDemo/SpeexNSDataEncodingController.h>
//#import <SpeexKitDemo/SpeexNSDataDecodingController.h>
//#import <SpeexKitDemo/AudioFileWrapperController.h>

#import "ContinuousAudioUnit.h"
#import "AudioSessionManager.h"

#import "AudioConstants.h"

#import "UIBubbleTableView.h"
#import "UIBubbleTableViewDataSource.h"
#import "NSBubbleData.h"





//#import "VSSpeechSynthesizer.h" // For getting private API (TTS)

//#include <ifaddrs.h>
//#include <arpa/inet.h>

#define ENCODESPEEXASYNCHRONOUSLY // Comment this out if you want to test synchronous encoding instead
#define DECODESPEEXASYNCHRONOUSLY // Comment this out if you want to test synchronous decoding instead

#if defined TARGET_IPHONE_SIMULATOR && TARGET_IPHONE_SIMULATOR // The simulator uses an audio queue driver because it doesn't work at all with the low-latency audio unit driver. 
#define kNumberOfCallBacks 20
#else
# if kSamplesPerSecond == 8000
#define kNumberOfCallBacks 40 // About 10 seconds.
#else
#define kNumberOfCallBacks 80 // About 10 seconds.
#endif

#endif

// Mic visual parameters //
#define MIC_BUTTON_RADIOUS 40 //30
#define MIC_BUTTON_SPACE_FROM_BOTTOM 15 //30
#define MIC_BUTTON_SPACE_OF_INTERNAL_CIRCLE 4//7//6//4  // 7 is for Siri button


const unsigned char SpeechKitApplicationKey[] =
    {
         0xe5, 0x2b, 0x1f, 0xcc, 0xab, 0xfb, 0xee, 0x10, 0xb4, 0x4b, 0x4c, 0x4f, 0x02, 0x2f, 0x52, 0xc6, 0x30, 0xc0, 0xee, 0x1c, 0x6e, 0xb1, 0x5c, 0xb8, 0x60, 0xf0, 0x1b, 0xb7, 0xd7, 0x58, 0xa2, 0xbc, 0x84, 0xc1, 0x89, 0x2f, 0xbd, 0x77, 0x3f, 0x71, 0xc2, 0x8b, 0xc1, 0xc4, 0xba, 0x13, 0x8a, 0xea, 0xd3, 0x78, 0x07, 0x41, 0x29, 0x63, 0xf9, 0x89, 0x53, 0x15, 0x41, 0x2a, 0x6d, 0xe3, 0xe6, 0xf1
     };



int submitcount;
int numberOfBuffersMadeAvailable;
int maxNumberOfBuffersToRecord;
ViewStateType curViewState;



@implementation ViewController

@synthesize buffersConverted;
@synthesize bufferArray;
@synthesize speexNSDataEncodingController;
@synthesize rawSamplesArray;
@synthesize completeBuffer;
@synthesize buffersDecoded;
@synthesize audioSessionManager;
@synthesize continuousAudioUnit;
@synthesize speexNSDataDecodingController;
@synthesize numberOfCallbacksToRecordFor;
@synthesize decodedBuffers;
@synthesize speexFramesCreated;

@synthesize responseData,connection;

@synthesize ipAddress;
@synthesize outputLabel;

@synthesize bubbleTable,bubbleData;

@synthesize emitterLayer;

@synthesize tickSoundFileObject,tickSoundFileURLRef;

//@synthesize curViewState;

// OpenEars //

@synthesize fliteController;
@synthesize slt;
//@synthesize awb,kal;

@synthesize vocalizer;

// Google tts
@synthesize wordToSpeech;
@synthesize player;




static pocketsphinxAudioDevice *audioDevice;


#pragma mark -
#pragma mark For Goole TTS

- (void)sentenceToSpeech{
    
    @try {
        
        NSString *sentenceToSpeech = @"";
        
        if (0 == self.totalCountPlayed) {
            
            sentenceToSpeech = [self.wordToSpeech substringToIndex:100];
            self.totalCountPlayed = 100;
            
        }
        else{
            
            NSString *tempString = [self.wordToSpeech substringFromIndex:self.totalCountPlayed];
            
            if (100 <= [tempString length]) {
                
                sentenceToSpeech = [tempString substringToIndex:100];
                self.totalCountPlayed += 100;
            }
            else
            {
                sentenceToSpeech = tempString;
                self.totalCountPlayed = 0;
            }
        }
        
        [self speechUsingGoogleTTS:sentenceToSpeech];
    }
    @catch (NSException *exception)
    {
        NSLog(@"%s\n exception: Name- %@ Reason->%@", __PRETTY_FUNCTION__,[exception name],[exception reason]);
    }
    
}

- (void)speechUsingGoogleTTS:(NSString *)sentenceToSpeeh{
    
    @try {
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *path = [documentsDirectory stringByAppendingPathComponent:@"file.mp3"];
        
        NSString *urlString = [NSString stringWithFormat:@"http://www.translate.google.com/translate_tts?tl=en&q=%@",sentenceToSpeeh];
        NSURL *url = [NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        NSMutableURLRequest* request = [[NSMutableURLRequest alloc] initWithURL:url] ;
        [request setValue:@"Mozilla/5.0 (Macintosh; Intel Mac OS X 10.6; rv:2.0.1) Gecko/20100101 Firefox/4.0.1" forHTTPHeaderField:@"User-Agent"];
        NSURLResponse* response = nil;
        NSError* error = nil;
        NSData* data = [NSURLConnection sendSynchronousRequest:request
                                             returningResponse:&response
                                                         error:&error];
        [data writeToFile:path atomically:YES];
        
        
        NSError        *err;
        if ([[NSFileManager defaultManager] fileExistsAtPath:path])
        {
            self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:
                           [NSURL fileURLWithPath:path] error:&err];
            
            [self.player prepareToPlay];
            [self.player setNumberOfLoops:0];
            [self.player setDelegate:self];
            [self.player play];
            
        }
    }
    @catch (NSException *exception)
    {
        NSLog(@"%s\n exception: Name- %@ Reason->%@", __PRETTY_FUNCTION__,[exception name],[exception reason]);
    }
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    
    @try {
        
        if (0 != self.totalCountPlayed) {
            
            [self sentenceToSpeech];
        }
    }
    @catch (NSException *exception)
    {
        NSLog(@"%s\n exception: Name- %@ Reason->%@", __PRETTY_FUNCTION__,[exception name],[exception reason]);
    }
}


#pragma mark -
#pragma mark SKVocalizerDelegate methods

- (void)vocalizer:(SKVocalizer *)vocalizer willBeginSpeakingString:(NSString *)text {
    isSpeaking = YES;
   // [speakButton setTitle:@"Stop" forState:UIControlStateNormal];
	//if (text)
	//	textReadSoFar.text = [[textReadSoFar.text stringByAppendingString:text] stringByAppendingString:@"\n"];
}

- (void)vocalizer:(SKVocalizer *)vocalizer willSpeakTextAtCharacter:(NSUInteger)index ofString:(NSString *)text {
    NSLog(@"Session id [%@].", [SpeechKit sessionID]); // for debugging purpose: printing out the speechkit session id
   // textReadSoFar.text = [text substringToIndex:index];
}

- (void)vocalizer:(SKVocalizer *)vocalizer didFinishSpeakingString:(NSString *)text withError:(NSError *)error {
    NSLog(@"Session id [%@].", [SpeechKit sessionID]); // for debugging purpose: printing out the speechkit session id
    isSpeaking = NO;
   // [speakButton setTitle:@"Read It" forState:UIControlStateNormal];
	if (error !=nil)
	{
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
														message:[error localizedDescription]
													   delegate:nil
											  cancelButtonTitle:@"OK"
											  otherButtonTitles:nil];
		[alert show];
		//[alert release];
	}
}

#pragma mark -
-(void)ttsNuance:(NSString*)textToSay{
    vocalizer = [[SKVocalizer alloc] initWithVoice:@"Samantha" delegate:self];//initWithLanguage:@"en_US" delegate:self];
    [vocalizer speakString:textToSay];
}

-(void)ttsFromGoogleSeperate:(NSString *)textToTranslate{
    
    @try {
        
        //self.wordToSpeech = textToTranslate;
        
        self.wordToSpeech = @"What do functional foods mean? According to the April 2009 position on functional foods by the American Dietetic Association (ADA), all foods are functional at some level, because they provide nutrients that furnish energy, sustain growth, or maintain and repair vital processes. While the functional food category, per se, is not officially recognized by the Food and Drug Administration, the ADA considers functional foods to be whole foods and fortified, enriched, or enhanced foods that have a potentially beneficial effect on health. Thus a list of functional foods might be as varied as nuts, calcium-fortified orange juice, energy bars, bottled teas and gluten-free foods. While many functional foods—from whole grain breads to wild salmon—provide obvious health benefits, other functional foods like acai berry or brain development foods may make overly optimistic promises. Thus, it’s important to evaluate each functional food on the basis of scientific evidence before you buy into their benefits";
        
        [self sentenceToSpeech];
    }
    @catch (NSException *exception)
    {
        NSLog(@"%s\n exception: Name- %@ Reason->%@", __PRETTY_FUNCTION__,[exception name],[exception reason]);
    }
    
}

-(void)ttsFromGoogle:(NSString *)textToTranslate{
    NSLog(@"ttsFromGoogle");
    
        
 
    NSString* userAgent = @"Mozilla/5.0";
    evaAnswers++;
    
    NSString* urlString = [NSString stringWithFormat:@"http://www.translate.google.com/translate_tts?tl=en&q=%@",textToTranslate];
    
    NSURL *url = [NSURL URLWithString:[urlString
                                                         stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    
    NSMutableURLRequest* request = [[NSMutableURLRequest alloc] initWithURL:url] ;
    
    [request setValue:userAgent forHTTPHeaderField:@"User-Agent"];
    
    
    NSURLResponse* response = nil;
    NSError* error = nil;
    NSData* data = [NSURLConnection sendSynchronousRequest:request
                                         returningResponse:&response
                                                     error:&error];
    
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [NSString stringWithFormat:@"%@",[paths objectAtIndex:0]]; // Get documents directory
    
   // NSData *soundData = [NSData dataWithContentsOfFile: ];
    
    
    NSLog(@"Response (%d)= %@",evaAnswers,[response description]);
    [data writeToFile:[NSString stringWithFormat:@"%@/%@",documentsDirectory,
                       [NSString stringWithFormat:@"tts%d.mp3",evaAnswers]
                       ] atomically:NO];//YES];
    
    
  
    
    // Below is working //
    SystemSoundID soundID;
    NSURL *url2 = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/%@",documentsDirectory, [NSString stringWithFormat:@"tts%d.mp3",evaAnswers]]];
    
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)url2, &soundID);
    AudioServicesPlaySystemSound (soundID);
    //AudioServicesAddSystemSoundCompletion(soundID, 0, 0, nil, nil);
    //AudioServicesAddSystemSoundCompletion(soundID);
    
}


#pragma mark - OpenEars

- (FliteController *)fliteController {
	if (fliteController == nil) {
		fliteController = [[FliteController alloc] init];
	}
	return fliteController;
}

- (Slt *)slt {
	if (slt == nil) {
		slt = [[Slt alloc] init];
	}
	return slt;
}

/*- (Awb *)awb {
	if (awb == nil) {
		awb = [[Awb alloc] init];
	}
	return awb;
}

- (Kal *)kal {
	if (kal == nil) {
		kal = [[Kal alloc] init];
	}
	return kal;
}*/


#pragma mark - UIBubbleTableViewDataSource implementation

- (NSInteger)rowsForBubbleTable:(UIBubbleTableView *)tableView
{
    return [bubbleData count];
}

- (NSBubbleData *)bubbleTableView:(UIBubbleTableView *)tableView dataForRow:(NSInteger)row
{
    return [bubbleData objectAtIndex:row];
}

#pragma mark - 

- (void)initBubbles{
   // NSString *helloString = [NSString stringWithFormat:@"Hello, I am EVA, Please say your travel request, This is just a test so I can figure out in Google text to speech API works on long sentences"];//
     NSString *helloString = [NSString stringWithFormat:@"Hello, I am EVA, Please say your travel request"];
    NSBubbleData *heyBubble = [NSBubbleData dataWithText:helloString date:[NSDate dateWithTimeIntervalSinceNow:0]//-300]
                                                    type:BubbleTypeSomeoneElse];
    heyBubble.avatar = [UIImage imageNamed:@"EvaChar.png"];//@"EvaHighRes.jpg"];//@"people_juliane.png"];//@"evature.jpg"];//@"avatar1.png"];
    
    
    bubbleData = [[NSMutableArray alloc] initWithObjects:heyBubble, nil];
    bubbleTable.bubbleDataSource = self;
    
    // The line below sets the snap interval in seconds. This defines how the bubbles will be grouped in time.
    // Interval of 120 means that if the next messages comes in 2 minutes since the last message, it will be added into the same group.
    // Groups are delimited with header which contains date and time for the first message in the group.
    
    bubbleTable.snapInterval = 120;
    
    // The line below enables avatar support. Avatar can be specified for each bubble with .avatar property of NSBubbleData.
    // Avatars are enabled for the whole table at once. If particular NSBubbleData misses the avatar, a default placeholder will be set (missingAvatar.png)
    
    bubbleTable.showAvatars = YES;
    
    // Uncomment the line below to add "Now typing" bubble
    // Possible values are
    //    - NSBubbleTypingTypeSomebody - shows "now typing" bubble on the left
    //    - NSBubbleTypingTypeMe - shows "now typing" bubble on the right
    //    - NSBubbleTypingTypeNone - no "now typing" bubble
    
    //bubbleTable.typingBubble = NSBubbleTypingTypeSomebody;
    
    [bubbleTable reloadData];
    
   // [self.fliteController say:helloString // @"A short statement"
    //                withVoice:self.slt];//awb];//self.slt];
    
    //[self ttsFromGoogle:helloString];
    [self ttsNuance:helloString];
    //[self ttsFromGoogleSeperate:helloString];
    
    //VSSpeechSynthesizer *speech = [[NSClassFromString(@"VSSpeechSynthesizer") alloc] init];
    //[speech setRate:(float)1.0];
    //[speech startSpeakingString:helloString];
}

-(void)userIsTalking{
    bubbleTable.typingBubble = NSBubbleTypingTypeMe;
    [bubbleTable reloadData];
    
    [self scrollToBottom];
}

-(void)userStoppedTalking{
    bubbleTable.typingBubble = NSBubbleTypingTypeNobody;
    [bubbleTable reloadData];
    
    [self scrollToBottom];
}

-(void)evaIsWriting{
    bubbleTable.typingBubble = NSBubbleTypingTypeSomebody;
    [bubbleTable reloadData];
    
    [self scrollToBottom];
}
-(void)evaStoppedWriting{
    bubbleTable.typingBubble = NSBubbleTypingTypeNobody;
    [bubbleTable reloadData];
    
    [self scrollToBottom];
}

-(void)userSay: (NSString *)userWords{
    bubbleTable.typingBubble = NSBubbleTypingTypeNobody;
    
    NSString *userShouldSay;
    if (userWords ==nil) {
        userShouldSay = [NSString stringWithFormat: @""];
    }else{
        userShouldSay = userWords;
    }
    
    NSBubbleData *sayBubble = [NSBubbleData dataWithText:userShouldSay date:[NSDate dateWithTimeIntervalSinceNow:0] type:BubbleTypeMine];
    sayBubble.avatar = [UIImage imageNamed:@"UserChar.png"];//@"Business_Person.png"];
    [bubbleData addObject:sayBubble];
    [bubbleTable reloadData];
    
    [self scrollToBottom];
    
#if TESTFLIGHT_TESTING
    TFLog(@"userSay:%@",userShouldSay);
#endif
    
    
}

-(void)evaSay: (NSString *)evaWords{
    bubbleTable.typingBubble = NSBubbleTypingTypeNobody;
    
    NSString *evaShouldSay;
    if (evaWords ==nil) {
        evaShouldSay = [NSString stringWithFormat: @"I didn't get that, please try again"];
    }else{
        evaShouldSay = evaWords;
    }
    
    NSBubbleData *sayBubble = [NSBubbleData dataWithText:evaShouldSay date:[NSDate dateWithTimeIntervalSinceNow:0] type:BubbleTypeSomeoneElse];
    sayBubble.avatar = [UIImage imageNamed:@"EvaChar.png"];//@"EvaHighRes.jpg"];//@"people_juliane.png"];//@"evature.jpg"];
    [bubbleData addObject:sayBubble];
    [bubbleTable reloadData];
    
    
   // [self.fliteController say:evaShouldSay // @"A short statement"
   //                 withVoice:self.slt];
    
    //[self ttsFromGoogle:evaShouldSay];
    [self ttsNuance:evaShouldSay];
    //[self ttsFromGoogleSeperate:evaShouldSay];
    
    //VSSpeechSynthesizer *speech = [[NSClassFromString(@"VSSpeechSynthesizer") alloc] init];
    //[speech setRate:(float)1.0];
    //[speech startSpeakingString:@"Hello world, how are you"];
    
   // [[NSClassFromString(@"VSSpeechSynthesizer") new]
    // startSpeakingString:evaWords];  // Use private API.
    
    [self scrollToBottom];
    
#if TESTFLIGHT_TESTING
    TFLog(@"evaSay:%@",evaShouldSay);
#endif

}

-(void) scrollToBottom
{
    int lastSection=[bubbleTable numberOfSections]-1;
    int lastRowNumber = [bubbleTable numberOfRowsInSection:lastSection]-1;
    NSIndexPath* ip = [NSIndexPath indexPathForRow:lastRowNumber inSection:lastSection];
    [bubbleTable scrollToRowAtIndexPath:ip atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

#pragma mark -

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

- (SpeexNSDataEncodingController *)speexNSDataEncodingController {
	if (speexNSDataEncodingController == nil) {
		speexNSDataEncodingController = [[SpeexNSDataEncodingController alloc] init];
        speexNSDataEncodingController.delegate = self;
        
        // speexNSDataEncodingController.verboseSpeexKit = TRUE;
        // speexNSDataEncodingController.denoise = TRUE;
        // speexNSDataEncodingController.dereverb = TRUE;
        // speexNSDataEncodingController.quality = 4;
        // speexNSDataEncodingController.vad = TRUE;
        // speexNSDataEncodingController.variableBitrate = TRUE;
        // speexNSDataEncodingController.complexity = 10;
        // speexNSDataEncodingController.timeEncoding = TRUE;
        
        if(kSamplesPerSecond == 8000) {
            speexNSDataEncodingController.mode = @"NarrowBand";
        }  else {
            speexNSDataEncodingController.mode = @"WideBand";
        }
        
        [speexNSDataEncodingController setSpeexEncodingOptions]; // It's always necessary to run setSpeexEncodingOptions once before starting to use the encoder so that the settings are registered and the encoder can work quickly.
	}
	return speexNSDataEncodingController;
}

- (SpeexNSDataDecodingController *)speexNSDataDecodingController {
	if (speexNSDataDecodingController == nil) {
		
        speexNSDataDecodingController = [[SpeexNSDataDecodingController alloc]init];
        
        // speexNSDataDecodingController.verboseSpeexKit = TRUE;
        speexNSDataDecodingController.delegate = self;
        
        if(kSamplesPerSecond == 8000) {
            speexNSDataDecodingController.mode = @"NarrowBand"; // Since the original samples were 16-bit 16000 PCM we are going to decode in WideBand mode.
        } else {
            speexNSDataDecodingController.mode = @"WideBand"; // Since the original samples were 16-bit 16000 PCM we are going to decode in WideBand mode.
        }
        
        [speexNSDataDecodingController setSpeexDecodingOptions]; // You always have to call setSpeexDecodingOptions after setting the mode and any other properties of the SpeexNSDataDecodingController, one time after initializing the SpeexNSDataDecodingController. Then you can call decodeSpeexNSData:withSpeexFrameSize: as many times as you want and it will be able to run as fast as possible.
        
    }
	return speexNSDataDecodingController;
}

- (NSMutableArray *)rawSamplesArray {
	if (rawSamplesArray == nil) {
		rawSamplesArray = [[NSMutableArray alloc] init];
    }
	return rawSamplesArray;
}

- (AudioSessionManager *)audioSessionManager {
	if (audioSessionManager == nil) {
		audioSessionManager = [[AudioSessionManager alloc] init];
    }
	return audioSessionManager;
}

- (ContinuousAudioUnit *)continuousAudioUnit {
	if (continuousAudioUnit == nil) {
		continuousAudioUnit = [[ContinuousAudioUnit alloc] initWithDelegate:self];
        continuousAudioUnit.delegate = self;
    }
	return continuousAudioUnit;
}


- (NSMutableArray *)bufferArray {
	if (bufferArray == nil) {
		bufferArray = [[NSMutableArray alloc] init];
    }
	return bufferArray;
}


- (NSMutableData *)completeBuffer {
	if (completeBuffer == nil) {
		completeBuffer = [[NSMutableData alloc] init];
    }
	return completeBuffer;
}


#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [SpeechKit setupWithID:@"NMDPTRIAL_majortal20120315143516"
                      host:@"sandbox.nmdp.nuancemobility.net"
                      port:443
                    useSSL:NO
                  delegate:nil];  //self
    

    
    evaAnswers =0;
    
    curViewState = kEvaWaitingForUserPress;
    
    ipAddress = [self getIPAddress];
    [self getCurrenLocale];
    
    
    NSLog(@"Timezone=%@",[self getCurrentTimezone]);
    
    [self initBubbles];
    //[self userIsTalking];
    
   /* [self userSay:@"Test 1"];
    for (int i=2; i<=10; i++) {
        [self evaSay:[NSString stringWithFormat:@"Test %d",i]];
    }*/
    
    
    
    
    
    
    /**** tick sound initialization ****/
    NSURL *tickSound   = [[NSBundle mainBundle] URLForResource: @"button-19"//@"button-16"//@"button-50"
                                                 withExtension: @"wav"];
    
    // Store the URL as a CFURLRef instance
    self.tickSoundFileURLRef = (__bridge  CFURLRef) tickSound;
    
    //[tickSound release]; // NEW
    
    // Create a system sound object representing the sound file.
    AudioServicesCreateSystemSoundID (
                                      
                                      tickSoundFileURLRef,
                                      &tickSoundFileObject
                                      );
    
    /***********************************/

    
    
    
    
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.distanceFilter = kCLDistanceFilterNone; // whenever we move
    locationManager.desiredAccuracy = kCLLocationAccuracyKilometer;// kCLLocationAccuracyHundredMeters; // 100 m
   // [locationManager startUpdatingLocation];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self createMicButton];
    
    askForStopRecording = FALSE;
    
    submitcount = 0;
    self.speexFramesCreated = 0;
    numberOfBuffersMadeAvailable = 0;
    
    if(kSamplesPerSecond == 8000) {
        self.numberOfCallbacksToRecordFor = kNumberOfCallBacks * 2;
    } else {
        self.numberOfCallbacksToRecordFor = kNumberOfCallBacks;
    }
    
    maxNumberOfBuffersToRecord = self.numberOfCallbacksToRecordFor;
    
    self.buffersConverted = 0;
    self.buffersDecoded = 0;
    
    NSLog(@"Welcome to the SpeexKitDemo sample app. This app uses an excerpt from the Librivox audiobook Aesop's Fables volume 1, \"The Fox and the Grapes\", read by Joplin.");
    
    if ([[[UIDevice currentDevice] model] rangeOfString:@"imulator"].location != NSNotFound) {
        NSLog(@"It looks like you are running the sample app on the simulator. Please keep in mind that there is no way to simulate iPhone low-latency audio recording on the Simulator, so depending on what audio hardware you have in your simulator host machine, you may see very different results from recording. In case of any concerns, please check the sample app behavior on an iOS device first.");    
    } else {
        NSLog(@"Starting the audio session.");
    }
    
    [self.audioSessionManager startAudioSession]; // Set up audio session for our low-latency buffer
    
   /*
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); 
    NSString *documentsDirectory = [NSString stringWithFormat:@"%@",[paths objectAtIndex:0]]; // Get documents directory
    NSString *inputFile = [NSString stringWithFormat:@"%@/%@",[[NSBundle mainBundle] resourcePath], @"Aesop.wav"]; // This is a complete wav file we're going to convert to a complete spx file
    NSString *outputFile = [NSString stringWithFormat:@"%@/%@",documentsDirectory, @"Aesop.spx"]; // This will be the output path for the comple speex file.
    
    SpeexFileEncodingController *speexFileEncodingController = [[SpeexFileEncodingController alloc] init];
	
    speexFileEncodingController.mode = @"Wideband"; // 16Khz mode
    speexFileEncodingController.inputBits = 16; // Input is a 16-bit file
    speexFileEncodingController.timeConversion = TRUE; // Report the amount of time the conversion took.
    speexFileEncodingController.verboseSpeexKit = TRUE;
	
    NSLog(@"Encoding the complete WAV file \"Aesop.wav\" into a complete Speex file titled \"Aesop.spx\". You can use the Xcode organizer to view this file in this app's Documents directory of your device, and it can be played back with the software VLC (keeping in mind that VLC can skip at both the beginning and ending of a local file, so this behavior should not be taken as a sign of a problem in isolation).");
    
    [speexFileEncodingController encodeLocalRawOrWavFileAtPath:inputFile intoSpeexFileAtPath:outputFile]; // This takes one entire file and converts it to a spx with a header. This file could be played back, for instance, by VLC. You can find it in your device's documents folder.
    
    NSLog(@"Encoding complete.");
    
    NSString *inputSpxFile = [NSString stringWithFormat:@"%@/%@",documentsDirectory, @"Aesop.spx"]; // Next we're going to input the speex file into the file decoder and get a complete PCM wav file out.
    NSString *outputWavFile = [NSString stringWithFormat:@"%@/%@",documentsDirectory, @"Aesop_2.wav"];  // This will be the path to the wav file.
    
    NSLog(@"Now decoding the file \"Aesop.spx\" into a WAV file titled \"Aesop_2.wav\". You can use the Xcode organizer to view this file in this app's Documents directory of your device, and it can be played back with an AVAudioPlayer.");
    
    SpeexFileDecodingController *speexDecodeController = [[SpeexFileDecodingController alloc] init];
    //speexDecodeController.quiet = TRUE; // Uncomment to suppress output
    [speexDecodeController decodeLocalSpeexFileAtPath:inputSpxFile intoLocalRawOrWavFileAtPath:outputWavFile];*/

   self.continuousAudioUnit.delegate = self;
    
   // if ((audioDevice = openAudioDevice("device",kSamplesPerSecond)) == NULL) NSLog(@"openAudioDevice failed"); // Opening the audio device
    
   // if (startRecording(audioDevice) < 0) NSLog(@"startRecording failed"); // Starting the audio unit
    
    
    
}


- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
    
    NSLog(@"Lat&Long: %.5f %.5f", fabs(newLocation.coordinate.latitude), fabs(newLocation.coordinate.longitude));
    longitude = fabs(newLocation.coordinate.longitude);
    latitude = fabs(newLocation.coordinate.latitude);
}


-(NSString *)getCurrentTimezone{
    NSInteger hoursFromGMT = [[NSTimeZone defaultTimeZone] secondsFromGMT]/3600;
    NSInteger minutesFromGMT = (([[NSTimeZone defaultTimeZone] secondsFromGMT]+0)%3600)/60;
    //NSLog(@"Timezone=%d",[[NSTimeZone defaultTimeZone] secondsFromGMT]/3600);
    
    if (hoursFromGMT>=0) {
        return [NSString stringWithFormat:@"+%02d:%02d",hoursFromGMT,minutesFromGMT];
    }else{
        return [NSString stringWithFormat:@"%02d:%02d",hoursFromGMT,minutesFromGMT];
    }
}

-(NSString *)getCurrenLocale{
    NSLocale* currentLocale = [NSLocale currentLocale];
    
    NSLog(@"Locale = %@", [currentLocale objectForKey:NSLocaleCountryCode]);
    return [currentLocale objectForKey:NSLocaleCountryCode];
}

- (NSString *)getIPAddress
{
    NSUInteger  an_Integer;
    NSArray * ipItemsArray;
    NSString *externalIP;
    
    NSURL *iPURL = [NSURL URLWithString:@"http://www.dyndns.org/cgi-bin/check_ip.cgi"];
    
    if (iPURL) {
        NSError *error = nil;
        NSString *theIpHtml = [NSString stringWithContentsOfURL:iPURL
                                                       encoding:NSUTF8StringEncoding
                                                          error:&error];
        if (!error) {
            NSScanner *theScanner;
            NSString *text = nil;
            
            theScanner = [NSScanner scannerWithString:theIpHtml];
            
            while ([theScanner isAtEnd] == NO) {
                
                // find start of tag
                [theScanner scanUpToString:@"<" intoString:NULL] ;
                
                // find end of tag
                [theScanner scanUpToString:@">" intoString:&text] ;
                
                // replace the found tag with a space
                //(you can filter multi-spaces out later if you wish)
                theIpHtml = [theIpHtml stringByReplacingOccurrencesOfString:
                             [ NSString stringWithFormat:@"%@>", text]
                                                                 withString:@" "] ;
                ipItemsArray =[theIpHtml  componentsSeparatedByString:@" "];
                an_Integer=[ipItemsArray indexOfObject:@"Address:"];
                
                externalIP =[ipItemsArray objectAtIndex:  ++an_Integer];
                
                
                
            } 
            
            
            NSLog(@"%@",externalIP);
            return [NSString stringWithFormat:@"%@",externalIP];
        } else {
            NSLog(@"Oops... g %d, %@", 
                  [error code], 
                  [error localizedDescription]);
        }
    }
    
    
    
    
    //[pool drain];
    return @"";
}

-(void)establishConnection{
    
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://vproxy.evaws.com:443/?site_code=thack&api_key=thack-london-june-2012&ip_addr=%@&locale=%@&time_zone=%@&latitude=%.5f&longitude=%.5f",ipAddress,[self getCurrenLocale],[self getCurrentTimezone],latitude,longitude]];
    NSLog(@"Url = %@",url);
   
#if TESTFLIGHT_TESTING
    TFLog(@"urlToEva:%@",url);
#endif
    
    
    self.responseData = [[NSMutableData alloc] initWithLength:0] ;
    //NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10.0f];  // New : Set timeout...
    
    [request setHTTPMethod:@"POST"];
    
    // "Content-Type: audio/x-speex;rate=16000"
    NSString *headerBoundary = [NSString stringWithFormat:@"audio/x-speex;rate=%d",kSamplesPerSecond];
    
    // set header 
    [request addValue:headerBoundary forHTTPHeaderField:@"Content-Type"];
    
    //Accept-Language: ENUS
    [request addValue:@"ENUS" forHTTPHeaderField:@"Accept-Language"];
    
    // "Accept-Topic: Dictation" 
    
    [request addValue:@"Dictation" forHTTPHeaderField:@"Accept-Topic"];
    
    // "Accept: text/plain"  
    [request addValue:@"text/plain" forHTTPHeaderField:@"Accept"];
    //"Transfer-Encoding: chunked"
    [request addValue:@"chunked" forHTTPHeaderField:@"Transfer-Encoding"];
    
    NSMutableData *postBody = [NSMutableData data];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [NSString stringWithFormat:@"%@",[paths objectAtIndex:0]]; // Get documents directory
#if !USING_M4A_RECORDING
    NSData *soundData = [NSData dataWithContentsOfFile: [NSString stringWithFormat:@"%@/%@",documentsDirectory, @"test.spx"]]; //mpegrecord.m4a
#else
    
    NSData *soundData = [NSData dataWithContentsOfFile: [NSString stringWithFormat:@"%@/%@",documentsDirectory, @"mpegrecord.m4a"]];
#endif
    
    
    [postBody appendData:soundData];
    [postBody appendData:[@"\r\n" dataUsingEncoding: NSUTF8StringEncoding]];
    
    // final boundary
    //[postBody appendData:[[NSString stringWithFormat:@"--%@\r\n", stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    // add body to post
    [request setHTTPBody:postBody];
    
    self.connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];

}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    // You may have received an HTTP 200 here, or not...
    [responseData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    NSString* aStr = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
    
    NSLog(@"This is my first chunk %@", aStr);
    
#if TESTFLIGHT_TESTING
    TFLog(@"JSon Reply:%@",aStr);
#endif
    
    [[NSUserDefaults standardUserDefaults] setValue:aStr forKey:kLastJsonStringFromEva ];
    
    NSError* error;
    NSDictionary* json = [NSJSONSerialization
                          JSONObjectWithData:data //1
                          
                          options:kNilOptions
                          error:&error];
    
    NSLog(@"input_text=%@",[json objectForKey:@"input_text"]);
    NSDictionary* apiReply = [json objectForKey:@"api_reply"]; //2
    //NSDictionary* locationsReply = [apiReply objectForKey:@"Locations"];
    NSString *sayIt = [apiReply objectForKey:@"Say It"];
    NSString *processedText = [apiReply objectForKey:@"ProcessedText"];
  //  NSLog(@"loans: %@", latestLoans); //3
    [outputLabel setText:sayIt];
    NSLog(@"SayIt=%@, ProcessedText=%@",sayIt,processedText);
    [self userSay:processedText];
    [self evaSay:sayIt];
    
    [self stopSiriEffect];
    curViewState = kEvaWaitingForUserPress;
    
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connectionV {
   // [connection2 release];
    connectionV = nil;
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"Something went wrong...");
    [self evaSay:@"Something went wrong, Please try again"];
    
    [self stopSiriEffect];
    curViewState = kEvaWaitingForUserPress;
}

-(void)recordAsM4A{
    
    [locationManager startUpdatingLocation];
    
    [self userIsTalking];
    
    askForStopRecording = FALSE;
    
   // NSData *soundData = [NSData dataWithContentsOfFile: [NSString stringWithFormat:@"%@/%@",documentsDirectory, @"test.spx"]];
    
    NSArray *dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docsDir = [NSString stringWithFormat:@"%@",[dirPaths objectAtIndex:0]]; // Get documents directory
    NSURL *tmpFileUrl = [NSURL fileURLWithPath:[docsDir stringByAppendingPathComponent:@"rec.m4a"//m4a"
                                                ]];
    
    NSMutableDictionary *recordSettings = [[NSMutableDictionary alloc] init];
    
    [recordSettings setValue :[NSNumber numberWithInt:kAudioFormatMPEG4AAC] forKey:AVFormatIDKey];
    [recordSettings setValue:[NSNumber numberWithFloat:16000.0] forKey:AVSampleRateKey];
    [recordSettings setValue:[NSNumber numberWithInt: 1] forKey:AVNumberOfChannelsKey];
    
 /*   [recordSettings setValue:[NSNumber numberWithInt:AVAudioQualityLow] forKey:AVEncoderAudioQualityKey];                //Encoder Settings
    [recordSettings setValue:[NSNumber numberWithInt:96] forKey:AVEncoderBitRateKey];                                    //          "
    [recordSettings setValue:[NSNumber numberWithInt:16] forKey:AVEncoderBitDepthHintKey];                               //          "
    [recordSettings setValue:[NSNumber numberWithInt:AVAudioQualityLow] forKey:AVSampleRateConverterAudioQualityKey];
    
    [recordSettings setValue :[NSNumber numberWithInt:kAudioFormatMPEG4AAC] forKey:AVMetadataCommonKeyFormat];
    [recordSettings setValue :[NSString stringWithFormat:@"Evature"] forKey:AVMetadataCommonKeyCopyrights];*/
    
    
    
    
    /*NSDictionary *recordSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [NSNumber numberWithInt:kAudioFormatMPEG4AAC]
                                    , AVFormatIDKey,
                                    [NSNumber numberWithFloat:16000.0
                                     ], AVSampleRateKey,
                                    [NSNumber numberWithInt: 1
                                     ], AVNumberOfChannelsKey,
                                    nil];*/
    NSError *error = nil;
    //AVAudioRecorder *recorder
    recorder = [[AVAudioRecorder alloc] initWithURL:tmpFileUrl settings:recordSettings error:&error];
    
    //prepare to record
    [recorder setDelegate:self];
    
    [recorder prepareToRecord];
    recorder.meteringEnabled = YES;
    
    
    //[recorder prepareToRecord];
    
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryRecord error:nil];
    [session setActive:YES error:nil];
    
    
    
    [recorder record];
}

-(void)stopRecordAsM4A{
    [recorder stop];
    
    AVAudioSession *session = [AVAudioSession sharedInstance];
    int flags = AVAudioSessionSetActiveFlags_NotifyOthersOnDeactivation;
    [session setActive:NO withFlags:flags error:nil];
    
    [locationManager stopUpdatingLocation];
    
    //stopRecording(audioDevice);   // Stop.
    //closeAudioDevice(audioDevice);
    askForStopRecording = TRUE;
    
    [self userStoppedTalking];
    
    [self evaIsWriting];
    
    [self stopSiriEffect];
    
    //[self establishConnection];
}

- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *) aRecorder successfully:(BOOL)flag
{
    
    NSLog (@"audioRecorderDidFinishRecording:successfully:");
    // your actions here
    [self establishConnection];
    
}

-(IBAction)startRecording:(id)sender{
    [locationManager startUpdatingLocation];
    
    [self userIsTalking];
    
    askForStopRecording = FALSE;
    
    // Below new //
    submitcount = 0;
    self.speexFramesCreated = 0;
    numberOfBuffersMadeAvailable = 0;
    
    if(kSamplesPerSecond == 8000) {
        self.numberOfCallbacksToRecordFor = kNumberOfCallBacks * 2;
    } else {
        self.numberOfCallbacksToRecordFor = kNumberOfCallBacks;
    }
    
    maxNumberOfBuffersToRecord = self.numberOfCallbacksToRecordFor;
    
    self.buffersConverted = 0;
    self.buffersDecoded = 0;
    
   
    
   // [self.audioSessionManager startAudioSession]; // Set up audio session for our low-latency buffer
    
    self.bufferArray = nil;  // NEWWWW
    self.rawSamplesArray = nil; // New
    self.completeBuffer = nil; // New
    
    self.continuousAudioUnit.delegate = self;
    if ((audioDevice = openAudioDevice("device",kSamplesPerSecond)) == NULL) NSLog(@"openAudioDevice failed"); // Opening the audio device
    if (startRecording(audioDevice) < 0) NSLog(@"startRecording failed"); // Starting the audio unit

    
}
-(IBAction)stopRecording:(id)sender{
    [locationManager stopUpdatingLocation];
    
    //stopRecording(audioDevice);   // Stop.
    //closeAudioDevice(audioDevice);
    askForStopRecording = TRUE;
    
    [self userStoppedTalking];
    
    [self evaIsWriting];
    
    [self stopSiriEffect];
    
    //[self establishConnection];
    
}

- (void) playbackOriginalSamplesAndEncodedAndDecodedSpeexBuffer  {
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); 
    NSString *documentsDirectory = [NSString stringWithFormat:@"%@",[paths objectAtIndex:0]]; // Get documents directory
    
   // NSString *raw_from_speex_outputFile = [NSString stringWithFormat:@"%@/%@",documentsDirectory, @"raw_from_speex_recording.wav"]; // This is where we will write out our decoded raw PCM as a WAV.
    
    NSString *original_raw_samples_outputFile = [NSString stringWithFormat:@"%@/%@",documentsDirectory, @"original_raw_samples_recording.wav"]; // This is where we will write out our original raw PCM as a WAV, so we can compare it with the encoded/decoded version to see if everything is working.
    
    NSMutableData *originalRawSamples = [[NSMutableData alloc] init]; // We are going to append all of our original raw samples to this data in order to write them out for comparison.
    
    for (NSData *rawData in self.rawSamplesArray) {
        [originalRawSamples appendData:rawData]; // Append our raw samples to the NSMutableData object.
    }
    
    NSError *error = nil;
    
    AudioFileWrapperController *audioFileWrapperController = [[AudioFileWrapperController alloc] init]; // Initialize the AudioFileWrapperController.
    
    error = [audioFileWrapperController writeWavFileFromMonoPCMData:originalRawSamples withSampleRate:kSamplesPerSecond andBitsPerChannel:kBitsPerChannel toFileLocation:original_raw_samples_outputFile];
    
    if(error) {
        NSLog(@"Error while writing out WAV 1: %@", error);    
    }
#if PLAY_DEBUG_SAMPLES
    AVAudioPlayer *audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:original_raw_samples_outputFile] error:&error];
    if(!error) {
        NSLog(@"Playing the original samples...");
        
      [audioPlayer play]; // Play the original raw samples WAV.
    } else {
        NSLog(@"Error while playing the original samples: %@", error);   
    }
    
    [NSThread sleepForTimeInterval:11]; // The only reason we are sleeping here is so that it isn't necessary to set up delegate methods for AVAudioPlayer to report completed playback.
    
    
    error = [audioFileWrapperController writeWavFileFromMonoPCMData:self.completeBuffer withSampleRate:kSamplesPerSecond andBitsPerChannel:kBitsPerChannel toFileLocation:raw_from_speex_outputFile];
    
    
    if(error) {
        NSLog(@"Error while writing out WAV 2: %@", error);    
    }
    
    AVAudioPlayer *audioPlayer2 = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:raw_from_speex_outputFile] error:&error];
    if(!error) {
        NSLog(@"Playing the speex-encoded/speex-decoded samples...");
        [audioPlayer2 play]; // Play the encoded and decoded samples for comparison.
    } else {
        NSLog(@"Error while playing the encoded/decoded samples: %@", error);   
    }
    
    [NSThread sleepForTimeInterval:11];  // The only reason we are sleeping here is so that it isn't necessary to set up delegate methods for AVAudioPlayer to report completed playback.
    
#endif
    NSLog(@"End of application demonstration.");

}

- (void) decodeSpeexBuffersAsynchronously {
    
    int total = 0;
    
    for (NSArray *speexArray in self.bufferArray) { // For every Speex Array that is in the master view controller buffer array,
        
        
        for (NSDictionary *speexFrameDictionary in speexArray) { // And for every dictionary that is in those Speex Arrays,
            
            NSData *speexData = [speexFrameDictionary objectForKey:@"SpeexFrameNSData"]; // Grab the speex-encoded data
            int speexDataFrameSize = [[speexFrameDictionary objectForKey:@"SpeexFrameSizeNSNumber"]intValue]; // And its frame size.
            total++;
            [self.speexNSDataDecodingController asynchronouslyDecodeSpeexNSData:speexData withSpeexFrameSize:speexDataFrameSize]; // And decode that data with the specified speex frame size.
            
        }
    }
    
}

- (void) dataWasConverted:(NSArray *)speexArray { // This method is called every time a raw buffer from the audio unit is converted into a speex buffer synchronously. 
    
    if((numberOfBuffersMadeAvailable == maxNumberOfBuffersToRecord) || askForStopRecording ){
        stopRecording(audioDevice);   // Stop.
        printf("DONE RECORDING AND CONVERTING\n");
        NSLog(@"Since %d buffers of audio have been recorded, recording will now stop.", self.numberOfCallbacksToRecordFor);    
        
    }
    
    
    self.speexFramesCreated = speexFramesCreated + [speexArray count];
    self.buffersConverted++; // We're tracking how many have been converted because we're only going to record/convert for a few seconds and then stop.
    
    
    if(self.speexNSDataEncodingController.vad == TRUE) { // If you are using speex voice activity detection, here is how you could detect which buffers contained speech:
        
        for (NSArray *speexArray in self.bufferArray) { // For every Speex Array that is in the master view controller buffer array,
            
            for (NSDictionary *speexFrameDictionary in speexArray) { // And for every dictionary that is in those Speex Arrays,
                if ([speexFrameDictionary objectForKey:@"SpeexVADDetectedSpeech"] && [[speexFrameDictionary objectForKey:@"SpeexVADDetectedSpeech"] isEqualToNumber:[NSNumber numberWithBool:FALSE]]) {
                    // Do something with Speex that doesn't contain speech (or don't)
                } else if([speexFrameDictionary objectForKey:@"SpeexVADDetectedSpeech"] && [[speexFrameDictionary objectForKey:@"SpeexVADDetectedSpeech"] isEqualToNumber:[NSNumber numberWithBool:TRUE]]) {
                    // Do something with Speex that contains speech
                }
            }
        }
    }
    
    // You could, for instance, decide not to add the speex with no speech to this array so that you are only doing subsequent actions on buffers which have speech in them.
    
    [self.bufferArray addObject:speexArray]; // Add the new converted speex array (the array contains all the speex frames as dictionaries containing their data and their framesize) to the master array of buffers for this view controller.
    
    if((self.buffersConverted == self.numberOfCallbacksToRecordFor) || askForStopRecording) { // Once we've converted all the buffers we're going to decode them.
        
        // But first let's attempt to wrap up all our Speex buffers as a spx file here.
        
        NSMutableArray *arrayToSubmit = [[NSMutableArray alloc] init];
        
        for (NSArray *speexArray in self.bufferArray) { // For every Speex Array that is in the master view controller buffer array,
            
            for (NSDictionary *speexFrameDictionary in speexArray) { // And for every dictionary that is in those Speex Arrays,
                [arrayToSubmit addObject:speexFrameDictionary]; // Add it to the big array
            }
        }
        
        NSArray *documentPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); 
        NSString *documentsDirectory = [NSString stringWithFormat:@"%@",[documentPath objectAtIndex:0]]; // Get documents directory
        
        NSString *speexOutputFile = [NSString stringWithFormat:@"%@/%@",documentsDirectory, @"test.spx"]; // This will be the output path for the comple speex file.
        
        AudioFileWrapperController *audioFileWrapperControllerForSpeexTestFile = [[AudioFileWrapperController alloc] init]; // Initialize the AudioFileWrapperController.
        
        
        NSString *speexMode = nil;
        if(kSamplesPerSecond == 8000) {
            speexMode = @"NarrowBand";
        }  else {
            speexMode = @"WideBand";
        }
        
        
        
        NSLog(@"Writing out the Speex file consisting of all the live recorded buffers to \"test.spx\" in the app's Documents folder.");
        
        NSError *error = [audioFileWrapperControllerForSpeexTestFile writeSpeexFileFromArrayOfSpeexDictionaries:arrayToSubmit inSpeexMode:speexMode toFileLocation:speexOutputFile];
        
		if(error) {
            NSLog(@"Error: %@", error);
        } else {
            NSLog(@"Done writing out spx.");
            
            [self establishConnection];
        }

        
#ifdef DECODESPEEXASYNCHRONOUSLY
        NSLog(@"Next we will decode all of the individual frames of Speex back into PCM asynchronously.");
        [self decodeSpeexBuffersAsynchronously];   
#else
        NSLog(@"Next we will decode all of the individual frames of Speex back into PCM synchronously.");
        
        for (NSArray *speexArray in self.bufferArray) { // For every Speex Array that is in the master view controller buffer array,
            
            for (NSDictionary *speexFrameDictionary in speexArray) { // And for every dictionary that is in those Speex Arrays,
                
                NSData *speexData = [speexFrameDictionary objectForKey:@"SpeexFrameNSData"]; // Grab the speex-encoded data
                int speexDataFrameSize = [[speexFrameDictionary objectForKey:@"SpeexFrameSizeNSNumber"]intValue]; // And its frame size.
                
                NSData *decodedBuffer = [self.speexNSDataDecodingController decodeSpeexNSData:speexData withSpeexFrameSize:speexDataFrameSize]; // And decode that data with the specified speex frame size.
                if(decodedBuffer)[self.completeBuffer appendData:decodedBuffer]; // If this isn't nil (a sign that something went wrong), append it to the complete PCM sample buffer.
                
                printf(".");
                
            }
        }
        NSLog(@"\n");
        NSLog(@"Done decoding, now playing back the original PCM samples and the Speex-encoded and -decoded samples for auditory comparison.");
        
        [self playbackOriginalSamplesAndEncodedAndDecodedSpeexBuffer];
#endif
        
    }
}

- (void) asynchronousDecoderCreatedPCMData:(NSData *)pcmData {
    
	printf(".");
    
    if(pcmData) { // If an array was returned instead of nil
        
        self.decodedBuffers++;
        
		NSData *decodedBuffer = pcmData; // Get the decoded data
		[self.completeBuffer appendData:decodedBuffer]; // Add it to the big NSMutableData of raw samples that we will eventually write out as a WAV.
        
        
        if(self.decodedBuffers == self.speexFramesCreated) { // If all the buffers in the array have been decoded,
			NSLog(@"Done decoding, now playing back the original samples and the encoded/decoded samples for auditory comparison.");
			[self playbackOriginalSamplesAndEncodedAndDecodedSpeexBuffer];
        }
    } else {
        NSLog(@"A nil frame was returned, turn on verbose mode if this is unexpected.");   
    }
}

- (void) samplesAvailable:(SInt16 *)samples withNumberOfSamples:(int)numberOfSamples {
    
    if(numberOfBuffersMadeAvailable==0) { 
        NSLog(@"Now recording live sound from the device microphone. Recording will stop when %d buffers of PCM audio have been recorded.",self.numberOfCallbacksToRecordFor);
        printf("RECORDING AND CONVERTING RECORDED PCM BUFFERS TO SPEEX.");
    }
    
    printf("."); // A visual indicator in the console that we are recording.
    
    // This is a delegate method of the audio driver. Every time a buffer full of samples becomes available, it passes them to this method as a SInt16 buffer.
    
    @autoreleasepool { // This NSAutoreleasePool is just here because this delegate method is being invoked from the audio unit buffer callback, which has none. You may want to do a much simpler audio recording implementation but I thought it would be helpful to show a complex one in the sample app.

    numberOfBuffersMadeAvailable++;  // We are keeping track of how many buffers have been passed here because we're going to do something different when the maximum as set in self.numberOfCallbacksToRecordFor has been reached.
    
        
        // askForStopRecording IS new (15/4/13)
    if((numberOfBuffersMadeAvailable <= maxNumberOfBuffersToRecord) || askForStopRecording) { // But until that time, let's add the data we're going to convert to an array that will just consist of NSDatas of raw PCM samples, ready for Speex conversion.
        
        NSData *dataToConvert = [[NSData alloc] initWithBytes:samples length:numberOfSamples * sizeof(SInt16)]; // We are going to convert it in the form of an NSData. frames * 2 is because the data length is bytes, not samples. Frames, in the case of mono 16-bit PCM, are the number of samples. There are two bytes in this kind of sample. In 8-bit PCM on the iPhone you will instead have one byte (and one frame) per sample.
        
        [self.rawSamplesArray addObject:dataToConvert]; // Save this original raw sample data for later auditory comparison.
        
#ifdef ENCODESPEEXASYNCHRONOUSLY
        [self.speexNSDataEncodingController asynchronouslyConvertNSDataToSpeex:dataToConvert];
        submitcount++;
        
#else
        NSArray *dataToReceive = [[NSData alloc] init]; // Get ready to receive an NSArray from the speex data encoder.
        
        dataToReceive = [self.speexNSDataEncodingController convertNSDataToSpeex:dataToConvert]; // We are calling the speex encoder on this buffer and receiving an array of NSDictionaries containing the converted speex buffers and their frame sizes.
        
        [self dataWasConverted:dataToReceive]; // We're calling dataWasConverted with the data we received.
        
#endif
        

    } 
    
    }
}

- (void) asynchronousEncoderCreatedSpeexArray:(NSArray *)speexArray { // SpeexNSDataEncodingControllerDelegate method
    
    [self dataWasConverted:speexArray];
    // This is called every time the asynchronous encoder returns a speexArray with speex data in it
}


- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}



#pragma mark -
#pragma mark Mic view& Effect

-(void)createMicButton{
    UIImage *micButtonImage = [UIImage imageNamed:@"GreenMic.png"];//@"SiriMic.png"];
    
    UIImage *micButtonPressedImage = [UIImage imageNamed:@"GreenMicPressed.png"];
    
    UIButton *micButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    NSLog(@"elf.view.bounds.size.height=%f",self.view.bounds.size.height);
    micButton.frame =  CGRectMake(self.view.bounds.size.width/2 - MIC_BUTTON_RADIOUS, self.view.bounds.size.height - MIC_BUTTON_RADIOUS*2 - MIC_BUTTON_SPACE_FROM_BOTTOM, MIC_BUTTON_RADIOUS*2, MIC_BUTTON_RADIOUS*2);//CGRectMake(280.0, 10.0, 29.0, 29.0);
    [micButton setBackgroundImage:micButtonImage forState:UIControlStateNormal];
    
    [micButton setImage:micButtonPressedImage forState:UIControlStateHighlighted];
    //[micButton setHighlighted:YES];
    
    [self.view addSubview:micButton];
    
    [micButton addTarget:self action:@selector(micButtonPressed) forControlEvents:UIControlEventTouchUpInside];
}

-(void)micButtonPressed{
    
    
    if (curViewState==kEvaWaitingForUserPress) {
#if !USING_M4A_RECORDING
        [self startRecording:nil];
#else
        [self recordAsM4A];
#endif
        curViewState = kEvaRecordingUser;
    }else if (curViewState == kEvaRecordingUser){
#if !USING_M4A_RECORDING
        [self stopRecording:nil];
#else
        [self stopRecordAsM4A];
#endif
        [self createSiriEffect];
        curViewState = kEvaWaitingForEvaResponse;
    }else{ // User press but button won't do nothing... Apply some sound.
        AudioServicesPlaySystemSound (tickSoundFileObject);
    }
}

-(void)createSiriEffect{
    // create emitter layer
    //emitterLayer = [CAEmitterLayer layer];
    emitterLayer = [CAEmitterLayer layer];
    emitterLayer.frame = CGRectMake(0, 0, self.view.bounds.size.width,  self.view.bounds.size.height);
    
    emitterLayer.emitterMode = kCAEmitterLayerOutline;
    emitterLayer.emitterShape = kCAEmitterLayerLine;
    emitterLayer.renderMode = kCAEmitterLayerAdditive;
    [emitterLayer setEmitterSize:CGSizeMake(4, 4)];
    
    // create the ball emitter cell
    CAEmitterCell *ball = [CAEmitterCell emitterCell];
    ball.color = [[UIColor colorWithRed:111.0/255.0 green:80.0/255.0 blue:241.0/255.0 alpha:0.10] CGColor];
    ball.contents = (id)[[UIImage imageNamed:@"ball.png"] CGImage] ; // ball.png is simply an image of white circle
    
    [ball setName:@"ball"];
    
    emitterLayer.emitterCells = [NSArray arrayWithObject:ball];
    [self.view.layer addSublayer:emitterLayer];
    
    float factor = 1.5; // you should play around with this value
    [emitterLayer setValue:[NSNumber numberWithInt:(factor * 500)] forKeyPath:@"emitterCells.ball.birthRate"];
    [emitterLayer setValue:[NSNumber numberWithFloat:factor * 0.25] forKeyPath:@"emitterCells.ball.lifetime"];
    [emitterLayer setValue:[NSNumber numberWithFloat:(factor * 0.15)] forKeyPath:@"emitterCells.ball.lifetimeRange"];
    
    NSLog(@"self.view.bounds.size.height=%f",self.view.bounds.size.height);
    // animation code
    CAKeyframeAnimation* circularAnimation = [CAKeyframeAnimation animationWithKeyPath:@"emitterPosition"];
    CGMutablePathRef path = CGPathCreateMutable();
    CGRect pathRect =CGRectMake(self.view.bounds.size.width/2 - MIC_BUTTON_RADIOUS+ MIC_BUTTON_SPACE_OF_INTERNAL_CIRCLE, self.view.bounds.size.height - MIC_BUTTON_RADIOUS*2 - MIC_BUTTON_SPACE_FROM_BOTTOM + MIC_BUTTON_SPACE_OF_INTERNAL_CIRCLE, (MIC_BUTTON_RADIOUS-MIC_BUTTON_SPACE_OF_INTERNAL_CIRCLE)*2, (MIC_BUTTON_RADIOUS-MIC_BUTTON_SPACE_OF_INTERNAL_CIRCLE)*2);
    
    // define circle bounds with rectangle
    CGPathAddEllipseInRect(path, NULL, pathRect);
    circularAnimation.path = path;
    CGPathRelease(path);
    circularAnimation.duration = 1.2;//1.5; // 2
    circularAnimation.repeatDuration = 0;
    circularAnimation.repeatCount = 300;
    circularAnimation.calculationMode = kCAAnimationPaced;
    [emitterLayer addAnimation:circularAnimation forKey:@"circularAnimation"];
    [emitterLayer setHidden:FALSE]; // NEw
}
-(void)stopSiriEffect{
    [emitterLayer removeAllAnimations];
    [emitterLayer setHidden:TRUE]; // New
}

- (IBAction)dataButtonPressed:(id)sender{
    if (curViewState != kEvaWaitingForEvaResponse) { // not processing
        DataViewController *controller = [[DataViewController alloc] initWithNibName:@"DataViewController" bundle:nil];
        controller.delegate = self;
        
        controller.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;// UIModalTransitionStyleFlipHorizontal;
        [self presentModalViewController:controller animated:YES];
    }else{
        AudioServicesPlaySystemSound (tickSoundFileObject); // can't go to data screen because processing...
    }
    
    
    //[controller release];
}

#pragma mark -
#pragma mark AboutViewControllerDelegate
- (void)dataViewControllerDidFinish:(DataViewController *)controller
{
    [self dismissModalViewControllerAnimated:YES];
}

@end
