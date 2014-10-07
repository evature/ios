//
//  FlipsideViewController.h
//  EvaTest
//
//  Created by idan S on 5/12/13.
//  Copyright (c) 2013 Evature. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Eva/Eva.h>
#import "Common.h"

@class FlipsideViewController;

@protocol FlipsideViewControllerDelegate
- (void)flipsideViewControllerDidFinish:(FlipsideViewController *)controller;
@end

@interface FlipsideViewController : UIViewController <EvaDelegate>{
    IBOutlet UITextField *repeatTextField;
    IBOutlet UIButton *toggleRepeatButton;
}

@property (weak, nonatomic) id <FlipsideViewControllerDelegate> delegate;
@property (nonatomic, retain) IBOutlet UITextView *dataTextView;

@property(nonatomic,retain) IBOutlet UITextField* repeatTextField;
@property(nonatomic,retain) IBOutlet UIButton *toggleRpeatButton;

- (IBAction)done:(id)sender;

@end
