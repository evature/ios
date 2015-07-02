//
//  EvaMainViewController.m
//  EvaTestApp
//
//  Created by idan S on 7/30/13.
//  Copyright (c) 2013 IdanS. All rights reserved.
//

#import "EvaMainViewController.h"

@interface EvaMainViewController ()

@end

@implementation EvaMainViewController

/*
- (BOOL)setAPIkey: (NSString *)api_key withSiteCode:(NSString *)site_code{
    return [[Eva sharedInstance] setAPIkey:api_key withSiteCode:site_code];
}

- (BOOL)setAPIkey: (NSString *)api_key withSiteCode:(NSString *)site_code withMicLevel:(BOOL)shouldSendMicLevel{
    return [[Eva sharedInstance] setAPIkey:api_key withSiteCode:site_code withMicLevel:shouldSendMicLevel];
}

// if shouldSendMicLevel is TRUE, evaMicLevelCallbackAverage:andPeak would be called when recording and evaMicStopRecording when recording stopped. secToTimeout represent the timeout of the record (default is 8.0 sec)
- (BOOL)setAPIkey: (NSString *)api_key withSiteCode:(NSString *)site_code withMicLevel:(BOOL)shouldSendMicLevel withRecordingTimeout:(float)secToTimeout{
    return [[Eva sharedInstance] setAPIkey:api_key withSiteCode:site_code withMicLevel:shouldSendMicLevel withRecordingTimeout:secToTimeout];
}

// Start record from current active Audio, If 'withNewSession' is set to 'FALSE' the function keeps last session //
- (BOOL)startRecord:(BOOL)withNewSession{
    return [[Eva sharedInstance] startRecord:withNewSession];
}

// Stop record, Would send the record to Eva for analyze //
- (BOOL)stopRecord{
    return [[Eva sharedInstance] stopRecord];
}

// Cancel record, Would cancel operation, record won't send to Eva (don't expect response) //
- (BOOL)cancelRecord{
    return [[Eva sharedInstance] cancelRecord];
}*/


#pragma mark -
#pragma mark ViewHandlers

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Flipside View

- (void)flipsideViewControllerDidFinish:(EvaFlipsideViewController *)controller
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)showInfo:(id)sender
{    
    EvaFlipsideViewController *controller = [[EvaFlipsideViewController alloc] initWithNibName:@"EvaFlipsideViewController" bundle:nil];
    controller.delegate = self;
    controller.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentViewController:controller animated:YES completion:nil];
}

@end
