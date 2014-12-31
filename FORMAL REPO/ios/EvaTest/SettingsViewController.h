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
}

@property (weak, nonatomic) id <SettingsControllerDelegate> delegate;
@property(nonatomic,retain) IBOutlet UITextField *apiKeyTextField;
@property(nonatomic,retain) IBOutlet UITextField *siteCodeTextField;


-(IBAction)setAPIKeysButton:(id)sender;

- (IBAction)textFieldDoneEditing:(id)sender;

@end
