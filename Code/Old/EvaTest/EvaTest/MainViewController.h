//
//  MainViewController.h
//  EvaTest
//
//  Created by idan S on 5/12/13.
//  Copyright (c) 2013 Evature. All rights reserved.
//

#import "FlipsideViewController.h"
#import <EvaFw/Eva.h>

@interface MainViewController : UIViewController <FlipsideViewControllerDelegate,EvaDelegate>{
    Eva *evaModule;
    
    // View modules //
    IBOutlet UITextField *apiKeyTextField;
    IBOutlet UITextField *siteCodeTextField;
    
    IBOutlet UIButton *startButton;
    IBOutlet UIButton *continueButton;
    IBOutlet UIButton *stopButton;
    
    IBOutlet UILabel *indicationLabel;
    //////////////////
}


// Would keep Eva Module //
@property(nonatomic,retain) Eva *evaModule;

// View modules //
@property(nonatomic,retain) IBOutlet UITextField *apiKeyTextField;
@property(nonatomic,retain) IBOutlet UITextField *siteCodeTextField;
@property(nonatomic,retain) IBOutlet UIButton *startButton;
@property(nonatomic,retain) IBOutlet UIButton *continueButton;
@property(nonatomic,retain) IBOutlet UIButton *stopButton;

@property(nonatomic,retain) IBOutlet UILabel *indicationLabel;
//////////////////

@property(nonatomic,retain) NSString *apiKeyString, *siteCodeString;

-(IBAction)setAPIKeysButton:(id)sender;
-(IBAction)startRecordButton:(id)sender;
-(IBAction)continueRecordButton:(id)sender;
-(IBAction)stopRecordButton:(id)sender;

- (IBAction)textFieldDoneEditing:(id)sender;

@end
