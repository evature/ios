//
//  SettingsViewController.h
//  EvaTest
//
//  Created by Iftah on 12/31/14.
//  Copyright (c) 2014 Evature. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Eva/Eva.h>

@class SettingsViewController;

@protocol SettingsControllerDelegate
- (void)settingsDidFinish:(SettingsViewController *)controller;
@end

@interface SettingsViewController : UIViewController {
// View modules //
    IBOutlet UITextField *apiKeyTextField;
    IBOutlet UITextField *siteCodeTextField;
    IBOutlet UITextField *hostTextField;
    IBOutlet UITextField *vrServiceTextField;
}

@property (weak, nonatomic) id <SettingsControllerDelegate> delegate;
@property(nonatomic,retain) IBOutlet UITextField *apiKeyTextField;
@property(nonatomic,retain) IBOutlet UITextField *siteCodeTextField;
@property(nonatomic,retain) IBOutlet UITextField *hostTextField;
@property(nonatomic,retain) IBOutlet UITextField *vrServiceTextField;


-(IBAction)textFieldDoneEditing:(id)sender;

@end
