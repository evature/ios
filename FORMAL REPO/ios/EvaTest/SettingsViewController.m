//
//  SettingsViewController.m
//  EvaTest
//
//  Created by Iftah on 12/31/14.
//  Copyright (c) 2014 Evature. All rights reserved.
//

#import "SettingsViewController.h"
#import "MainViewController.h"
#import "Common.h"

@interface SettingsViewController ()

@end

@implementation SettingsViewController

@synthesize apiKeyTextField;
@synthesize siteCodeTextField;
@synthesize hostTextField;
@synthesize vrServiceTextField;
@synthesize encoderBuffTextField;
@synthesize encoderFrameTextField;
@synthesize recorderBuffTextField;
@synthesize connectionBuffTextField;


- (void)viewDidLoad {
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) { // if iOS 7
        self.edgesForExtendedLayout = UIRectEdgeNone; //layout adjustements
    }
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if ([[NSUserDefaults standardUserDefaults] objectForKey:kApiKey]!=nil) {
        [apiKeyTextField setText:[[NSUserDefaults standardUserDefaults] objectForKey:kApiKey]];
    }
    if ([[NSUserDefaults standardUserDefaults] objectForKey:kSiteCode]!=nil) {
        [siteCodeTextField setText:[[NSUserDefaults standardUserDefaults] objectForKey:kSiteCode]];
    }
    
    if ([[NSUserDefaults standardUserDefaults] stringForKey:kHost]!=nil) {
        [hostTextField setText:[[NSUserDefaults standardUserDefaults] stringForKey:kHost]];
    }

    if ([[NSUserDefaults standardUserDefaults] stringForKey:kVrService]!=nil) {
        [vrServiceTextField setText:[[NSUserDefaults standardUserDefaults] stringForKey:kVrService]];
    }
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:kRecorderBuff]!=nil) {
        [recorderBuffTextField setText:[[NSUserDefaults standardUserDefaults] objectForKey:kRecorderBuff]];
    }
    if ([[NSUserDefaults standardUserDefaults] objectForKey:kEncoderBuff]!=nil) {
        [encoderBuffTextField setText:[[NSUserDefaults standardUserDefaults] objectForKey:kEncoderBuff]];
    }
    if ([[NSUserDefaults standardUserDefaults] objectForKey:kEncoderFrame]!=nil) {
        NSString *txt = [[NSUserDefaults standardUserDefaults] objectForKey:kEncoderFrame];
        [encoderFrameTextField setText:txt];
    }
    if ([[NSUserDefaults standardUserDefaults] objectForKey:kConnectionBuff]!=nil) {
        [connectionBuffTextField setText:[[NSUserDefaults standardUserDefaults] objectForKey:kConnectionBuff]];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)textFieldDoneEditing:(id)sender{
    [sender resignFirstResponder];
    //[self saveViewParameters];
    [self.delegate settingsDidFinish:self];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
//    // Get the new view controller using [segue destinationViewController].
//    // Pass the selected object to the new view controller.
//    NSLog(@"Sender is %@", sender);
//    MainViewController *mv = (MainViewController*)    segue.sourceViewController;
//    [mv setApiKeyString:@"Hello"];
//}


@end
