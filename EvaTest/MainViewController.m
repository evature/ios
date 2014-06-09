//
//  MainViewController.m
//  EvaTest
//
//  Created by idan S on 5/12/13.
//  Copyright (c) 2013 Evature. All rights reserved.
//

#import "MainViewController.h"
#import "Common.h"

#import <MediaPlayer/MPVolumeView.h>

#define VAD_DEBUG_GUI FALSE
#define AUTO_START_RECORDING FALSE
#define AUTO_START_RECORD_ON_QUESTION FALSE

@interface MainViewController ()

@end

@implementation MainViewController

@synthesize apiKeyTextField;
@synthesize siteCodeTextField;
@synthesize inputTextField;

@synthesize startButton, continueButton, stopButton,cancelButton;
@synthesize indicationLabel;

@synthesize vadLabel;
@synthesize responseLabel;

@synthesize apiKeyString,siteCodeString;


@synthesize micLevel;


#pragma mark - View parameters
- (void)showLabelWithText:(NSString*)labelText {
    [indicationLabel setText:labelText];
}


-(void)saveViewParameters{
    [[NSUserDefaults standardUserDefaults] setValue:[apiKeyTextField text] forKey:kApiKey];
    [[NSUserDefaults standardUserDefaults] setValue:[siteCodeTextField text] forKey:kSiteCode];
    apiKeyString = [[NSUserDefaults standardUserDefaults] objectForKey:kApiKey];
    siteCodeString = [[NSUserDefaults standardUserDefaults] objectForKey:kSiteCode];
}

-(void)loadViewParameters{
    if ([[NSUserDefaults standardUserDefaults] objectForKey:kApiKey]!=nil) {
        [apiKeyTextField setText:[[NSUserDefaults standardUserDefaults] objectForKey:kApiKey]];
    }
    if ([[NSUserDefaults standardUserDefaults] objectForKey:kSiteCode]!=nil) {
        [siteCodeTextField setText:[[NSUserDefaults standardUserDefaults] objectForKey:kSiteCode]];
    }
    apiKeyString = [[NSUserDefaults standardUserDefaults] objectForKey:kApiKey];
    siteCodeString = [[NSUserDefaults standardUserDefaults] objectForKey:kSiteCode];
}

- (void)showParameterErrorMessage {
    UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Error!"
                                                      message:@"Please set up api_key and site_code first, Then try again"
                                                     delegate:nil
                                            cancelButtonTitle:@"OK"
                                            otherButtonTitles:nil];
    [message show];
}

- (IBAction)textFieldDoneEditing:(id)sender{
    [sender resignFirstResponder];
    [self saveViewParameters];
}

#pragma mark - view actions
-(IBAction)startRecordButton:(id)sender{
    [self textFieldDoneEditing:sender];
    
    [[Eva sharedInstance] startRecord:TRUE];
    [self showLabelWithText:@"Record has started"];
    [self performSelector:@selector(showLabelWithText:) withObject:@"" afterDelay:4.5];
    
    [self setRecordButtons:true];
}

-(IBAction)continueRecordButton:(id)sender{
    [[Eva sharedInstance] startRecord:FALSE];
    [self setRecordButtons:true];
}
-(IBAction)stopRecordButton:(id)sender{
    [[Eva sharedInstance] stopRecord];
    [self setRecordButtons:false];
}
-(IBAction)cancelRecordButton:(id)sender{
    [[Eva sharedInstance] cancelRecord];
    [self setRecordButtons:false];
}

-(IBAction)sendTextQuery:(id)sender{
//  [[Eva sharedInstance] setNoSession];
    [[Eva sharedInstance] queryWithText:[inputTextField text] startNewSession:FALSE];
}

-(IBAction)setAPIKeysButton:(id)sender{
    [self saveViewParameters];
    if (1&&
        apiKeyString!=nil && siteCodeString!=nil
        && apiKeyString!=[NSString stringWithFormat:@""] &&
        siteCodeString!=[NSString stringWithFormat:@""]
        ) {
        //[evaModule setAPIkey:apiKeyString withSiteCode:siteCodeString];
        [[Eva sharedInstance] setAPIkey:apiKeyString withSiteCode:siteCodeString withMicLevel:TRUE]; // This would enable - (void)evaMicLevelCallbackAverage: (float)averagePower andPeak: (float)peakPower;
    }else{
        [self showParameterErrorMessage];
    }
}
//
//-(float) getVolumeLevel
//{
//    MPVolumeView *slide = [MPVolumeView new];
//    UISlider *volumeViewSlider;
//    
//    for (UIView *view in [slide subviews]){
//        if ([[[view class] description] isEqualToString:@"MPVolumeSlider"]) {
//            volumeViewSlider = (UISlider *) view;
//        }
//    }
//    
//    float val = [volumeViewSlider value];
//    slide = nil;
//    
//    return val;
//}

- (void)setRecordButtons: (Boolean) isRecording{
    [startButton setHidden: isRecording];
    [continueButton setHidden: isRecording];
    [cancelButton setHidden: !isRecording];
    [stopButton setHidden: !isRecording];
}


#pragma mark - Eva Delegate
- (void)evaDidReceiveData:(NSData *)dataFromServer{
    NSString* dataStr = [[NSString alloc] initWithData:dataFromServer encoding:NSUTF8StringEncoding];
    
    NSLog(@"Data from Eva %@", dataStr);
    
    // Save it to disk (to show easily on second view) //
    [[NSUserDefaults standardUserDefaults] setValue:dataStr forKey:kLastJsonStringFromEva ];
    
    [self setRecordButtons:false];
    [self showLabelWithText:@"Recived data from Eva!"];
    [self performSelector:@selector(showLabelWithText:) withObject:@"" afterDelay:3.5];
    
    NSData *jsonData = [dataStr dataUsingEncoding:NSUTF8StringEncoding];
    NSError *e;
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&e];
    
    if (e != NULL || dict == NULL) {
        [responseLabel setText:@"Error parsing"];
    }
    else {
        [responseLabel setText:[dict objectForKey:@"input_text"]];
        
        NSLog(@"Session is: %@", [dict objectForKey:@"session_id"]);
        
        NSDictionary *api_reply = (NSDictionary*)[dict objectForKey:@"api_reply"];
        if (api_reply != nil) {
            NSArray *flow = (NSArray*)[api_reply objectForKey:@"Flow"];
            if (flow != nil && [flow count] > 0) {
                NSDictionary *flowAction = [flow firstObject];
                if ([[flowAction objectForKey:@"Type"] isEqualToString:@"Question"]) {
                    NSLog(@"Question!");
#if AUTO_START_RECORD_ON_QUESTION
                    [[Eva sharedInstance] startRecord:FALSE];
                    [self setRecordButtons:true];
                    [self showLabelWithText:@"Record has started on Question"];
                    [responseLabel setText:[flowAction objectForKey:@"SayIt"]];
                    [self performSelector:@selector(showLabelWithText:) withObject:@"" afterDelay:4.5];
#endif
                }
            }
        }
    }
    
    
}

- (void)evaDidFailWithError:(NSError *)error{
    NSLog(@"Got error from Eva");
    //[self.micLevel setHidden:TRUE];
    [self showLabelWithText:@"Error from Eva"];
    [vadLabel setText:[NSString stringWithFormat:@"Error: %@", error]];
}

- (void)evaMicLevelCallbackAverage: (float)averagePower andPeak: (float)peakPower{
    NSLog(@"Mic Average: %f Peak: %f", averagePower,peakPower);
    #if VAD_DEBUG_GUI
    vadAveragePower = pow(10, (0.05 * averagePower));
    #endif
    [self.micLevel setProgress:(45+averagePower)/45];
    [self.micLevel setHidden:FALSE];
}

- (void)evaMicStopRecording{
    NSLog(@"Recording has stopped");
    [self showLabelWithText:@"stopping"];
    //[self setRecordButtons:false];
}

- (void)evaRecorderIsReady{
    NSLog(@"EvaRecorder is ready!");
    [self showLabelWithText:@"Ready!"];
//    [self showLabelWithText:[NSString stringWithFormat:@"%f", [self getVolumeLevel]]];
    [self.startButton setEnabled:TRUE];
    
    [self setAVSession];

#if AUTO_START_RECORDING
    [[Eva sharedInstance] startRecord:TRUE];
    [self showLabelWithText:@"Record has started on isReady"];
    [self performSelector:@selector(showLabelWithText:) withObject:@"" afterDelay:4.5];
    [self setRecordButtons:true];
#endif

}



#if VAD_DEBUG_GUI


float vadAveragePower;
float vadMinLevel;
float vadMaxLevel;
float vadThreshold;
int vadSilentMoments;
float vadStopSilenceMoments;
int vadNoisyMoments;
float vadStopNoisyMoments;

- (void)showVadDetails {
    [vadLabel setText:[NSString stringWithFormat:@"Level: %.3f \n Min: %.3f,  Max: %.3f,  \n Threshold: %.3f,  \n Silent: %d  out of: %.1f \n  Noisy: %d  out of: %.1f",
                       vadAveragePower, vadMinLevel, vadMaxLevel, vadThreshold, vadSilentMoments, vadStopSilenceMoments, vadNoisyMoments, vadStopNoisyMoments]];
}

- (void)evaMicLevelCallbackMin: (float)minLevel {
    vadMinLevel = minLevel;
    [self showVadDetails];
}

- (void)evaMicLevelCallbackMax: (float)maxLevel {
    vadMaxLevel = maxLevel;
    [self showVadDetails];
}

- (void)evaMicLevelCallbackThreshold: (float)threshold {
    vadThreshold = threshold;
    [self showVadDetails];
}

- (void)evaSilentMoments: (int)moments  stopOn:(float) stopMoments {
    vadSilentMoments = moments;
    vadStopSilenceMoments = stopMoments;
    [self showVadDetails];
}

- (void)evaNoisyMoments: (int)moments  stopOn:(float) stopMoments {
    vadNoisyMoments = moments;
    vadStopNoisyMoments = stopMoments;
    [self showVadDetails];
}
#endif

#pragma mark - View

-(void)viewWillAppear:(BOOL)animated{
    // New Setup //
    [Eva sharedInstance].delegate = self; // Setting the delegate to this view //
    // The delegate initiation is here for it to be set-up every time this view is called //
}

- (void)setAVSession {
    NSLog(@"Setting session to Play and Record");
    AVAudioSession *session = [AVAudioSession sharedInstance];
    NSError *error;
    if ([session respondsToSelector:@selector(setCategory:withOptions:error:)]) { // Using iOS 6+
        
        [session setCategory:AVAudioSessionCategoryPlayAndRecord withOptions:AVAudioSessionCategoryOptionDefaultToSpeaker error:&error];
    }else{
        // Do somthing smart for iOS 5 //
    }
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

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
	// Do any additional setup after loading the view, typically from a nib.
    
    
    // Below old setup - You can still use it //
    //evaModule = [[Eva alloc] init];
    //evaModule.delegate = self;
    // End old setup //
    
    // Set optional parameters //
    
    //[[Eva sharedInstance] setHome:@"paris"];
    //[[Eva sharedInstance] setVersion: @"v1.0"];
    //[[Eva sharedInstance] setUid:@"TestUID"];
    //[[Eva sharedInstance] setScope:@"h"];
    
    //NSMutableDictionary *optionalDict = [NSMutableDictionary dictionaryWithObject:[NSString stringWithFormat: @"%@",@"objTest"] forKey:@"keyTest"];
    //[[Eva sharedInstance] setOptional_dictionary:[optionalDict mutableCopy]];
    
    
    // View settings //
    [self loadViewParameters];

    
    [Eva sharedInstance].delegate = self;
    // Initialize Eva keys - It is recommended to do that on your App delegate //
    [[Eva sharedInstance] setAPIkey:apiKeyString withSiteCode:siteCodeString withMicLevel:TRUE]; 
    
    NSURL *beepSound   = [[NSBundle mainBundle] URLForResource: @"voice_high"
                                                 withExtension: @"aif"];
    NSURL *beepSound2   = [[NSBundle mainBundle] URLForResource: @"voice_low"
                                                 withExtension: @"aif"];
    
    [[Eva sharedInstance] setStartRecordAudioFile:beepSound];
    [[Eva sharedInstance] setVADEndRecordAudioFile:beepSound2];
    [[Eva sharedInstance] setRequestedEndRecordAudioFile:beepSound2];
    [[Eva sharedInstance] setCanceledRecordAudioFile:beepSound2];
    
    // Hide buttons if no API keys //
    if (apiKeyString==nil || siteCodeString==nil
        || apiKeyString==[NSString stringWithFormat:@""] ||
        siteCodeString==[NSString stringWithFormat:@""]) {
        [startButton setHidden:TRUE];
        [stopButton setHidden:TRUE];
    }
    
    [Eva sharedInstance].optional_dictionary  = @{@"demo_app" : @"1"};
    
#if !VAD_DEBUG_GUI
    [vadLabel setHidden:TRUE];
#endif
    
    [self showLabelWithText:@"View loaded"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    [self showLabelWithText:@"Memory warning!"];
}

#pragma mark - Flipside View

- (void)flipsideViewControllerDidFinish:(FlipsideViewController *)controller
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showAlternate"]) {
        [[segue destinationViewController] setDelegate:self];
    }
}

@end
