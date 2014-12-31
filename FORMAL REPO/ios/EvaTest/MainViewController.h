//
//  MainViewController.h
//  EvaTest
//
//  Created by idan S on 5/12/13.
//  Copyright (c) 2013 Evature. All rights reserved.
//

#import "SettingsViewController.h"

//#ifdef FLAC_VERSION
//#import <EvaFlac/Eva.h>
//#else
#import <Eva/Eva.h>
//#endif

@interface MainViewController : UIViewController <SettingsControllerDelegate,EvaDelegate>{
    
     
    IBOutlet UITextField *inputTextField;
    
    IBOutlet UIButton *resetButton;
    IBOutlet UIButton *continueButton;
    IBOutlet UIButton *stopButton;
    
    IBOutlet UILabel *indicationLabel;
    
    IBOutlet UIProgressView *micLevel;

    IBOutlet UILabel *vadLabel;
    IBOutlet UILabel *responseLabel;
    

    //////////////////
}

// View modules //
@property(nonatomic,retain) IBOutlet UITextField *inputTextField;
@property(nonatomic,retain) IBOutlet UIButton *resetButton;
@property(nonatomic,retain) IBOutlet UIButton *continueButton;
@property(nonatomic,retain) IBOutlet UIButton *stopButton;
@property(nonatomic,retain) IBOutlet UIButton *cancelButton;

@property(nonatomic,retain) IBOutlet UILabel *indicationLabel;
@property(nonatomic,retain) IBOutlet UILabel *vadLabel;
@property(nonatomic,retain) IBOutlet UILabel *responseLabel;

@property(nonatomic,retain) IBOutlet UIProgressView *micLevel;
@property(nonatomic,retain) NSString *apiKeyString, *siteCodeString;
//////////////////
@property(atomic) BOOL isNewSession;

-(IBAction)newSessionButton:(id)sender;
-(IBAction)continueRecordButton:(id)sender;
-(IBAction)stopRecordButton:(id)sender;
-(IBAction)cancelRecordButton:(id)sender;
-(IBAction)sendTextQuery:(id)sender;

@end
