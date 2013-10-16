//
//  MainViewController.m
//  EvaTest
//
//  Created by idan S on 5/12/13.
//  Copyright (c) 2013 Evature. All rights reserved.
//

#import "MainViewController.h"
#import "Common.h"

@interface MainViewController ()

@end

@implementation MainViewController

@synthesize apiKeyTextField;
@synthesize siteCodeTextField;

@synthesize startButton, continueButton, stopButton,cancelButton;
@synthesize indicationLabel;

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
    
    
    [continueButton setHidden:FALSE];
    [cancelButton setHidden:FALSE];
    [stopButton setHidden:FALSE];
    
}

-(IBAction)continueRecordButton:(id)sender{
    [[Eva sharedInstance] startRecord:FALSE];
    [cancelButton setHidden:FALSE];
    [stopButton setHidden:FALSE];
}
-(IBAction)stopRecordButton:(id)sender{
    [[Eva sharedInstance] stopRecord];
    [cancelButton setHidden:TRUE];
    [stopButton setHidden:TRUE];
}
-(IBAction)cancelRecordButton:(id)sender{
    [[Eva sharedInstance] cancelRecord];
    [cancelButton setHidden:TRUE];
    [stopButton setHidden:TRUE];

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
        

        [startButton setHidden:FALSE];
        [stopButton setHidden:TRUE];
    }else{
        [self showParameterErrorMessage];
    }
}

#pragma mark - Eva Delegate
- (void)evaDidReceiveData:(NSData *)dataFromServer{
    NSString* dataStr = [[NSString alloc] initWithData:dataFromServer encoding:NSASCIIStringEncoding];
    
    NSLog(@"Data from Eva %@", dataStr);
    
    // Save it to disk (to show easily on second view) //
    [[NSUserDefaults standardUserDefaults] setValue:dataStr forKey:kLastJsonStringFromEva ];
    
    [self showLabelWithText:@"Recived data from Eva!"];
    [self performSelector:@selector(showLabelWithText:) withObject:@"" afterDelay:4.5];
    
}

- (void)evaDidFailWithError:(NSError *)error{
    NSLog(@"Got error from Eva");
    //[self.micLevel setHidden:TRUE];
}

- (void)evaMicLevelCallbackAverage: (float)averagePower andPeak: (float)peakPower{
    NSLog(@"Mic Average: %f Peak: %f", averagePower,peakPower);
    
    [self.micLevel setProgress:(45+averagePower)/45];
    [self.micLevel setHidden:FALSE];
}

- (void)evaMicStopRecording{
    NSLog(@"Recording has stopped");
    [self.micLevel setHidden:TRUE];
    [cancelButton setHidden:TRUE];
    [stopButton setHidden:TRUE];
}

- (void)evaRecorederIsReady{
    [self.startButton setHidden:FALSE];
}



#pragma mark - View

-(void)viewWillAppear:(BOOL)animated{
    // New Setup //
    [Eva sharedInstance].delegate = self; // Setting the delegate to this view //
    // The delegate initiation is here for it to be set-up every time this view is called //

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
    [continueButton setHidden:TRUE];
    
    // Initialize Eva keys - It is recommended to do that on your App delegate //
    // [[Eva sharedInstance] setAPIkey:apiKeyString withSiteCode:siteCodeString];
    [[Eva sharedInstance] setAPIkey:apiKeyString withSiteCode:siteCodeString withMicLevel:TRUE]; // This would enable - (void)evaMicLevelCallbackAverage: (float)averagePower andPeak: (float)peakPower;
    //[[Eva sharedInstance] setAPIkey:apiKeyString withSiteCode:siteCodeString withMicLevel:TRUE withRecordingTimeout:20.0f];
    
    // Hide buttons if no API keys //
    if (apiKeyString==nil || siteCodeString==nil
        || apiKeyString==[NSString stringWithFormat:@""] ||
        siteCodeString==[NSString stringWithFormat:@""]) {
        [startButton setHidden:TRUE];
        [stopButton setHidden:TRUE];
    }
    
    
    }

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
