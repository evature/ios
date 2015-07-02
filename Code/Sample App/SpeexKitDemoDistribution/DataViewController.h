//
//  DataViewController.h
//  EvaDemo
//
//  Created by idan S on 4/7/13.
//  Copyright (c) 2013 Politepix. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Common.h"

@class DataViewController;

@protocol DataViewControllerDelegate
- (void)dataViewControllerDidFinish:(DataViewController *)controller;
@end

@interface DataViewController : UIViewController{
    IBOutlet UITextView *dataTextView;
}

@property (assign, nonatomic) IBOutlet id <DataViewControllerDelegate> delegate;
@property (nonatomic, retain) IBOutlet UITextView *dataTextView;

- (IBAction)done:(id)sender;

@end
