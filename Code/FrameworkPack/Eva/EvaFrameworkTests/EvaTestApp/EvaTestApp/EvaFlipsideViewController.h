//
//  EvaFlipsideViewController.h
//  EvaTestApp
//
//  Created by idan S on 7/30/13.
//  Copyright (c) 2013 IdanS. All rights reserved.
//

#import <UIKit/UIKit.h>

@class EvaFlipsideViewController;

@protocol EvaFlipsideViewControllerDelegate
- (void)flipsideViewControllerDidFinish:(EvaFlipsideViewController *)controller;
@end

@interface EvaFlipsideViewController : UIViewController

@property (weak, nonatomic) id <EvaFlipsideViewControllerDelegate> delegate;

- (IBAction)done:(id)sender;

@end
