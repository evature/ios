//
//  MainViewController.h
//  MyApp
//
//  Created by idan S on 5/23/13.
//  Copyright (c) 2013 Evature. All rights reserved.
//

#import "FlipsideViewController.h"
#import <EvaFW/Eva.h>

@interface MainViewController : UIViewController <FlipsideViewControllerDelegate,EvaDelegate>{
    Eva *evaModule;
}

@property(nonatomic,retain) Eva *evaModule;

- (IBAction)showInfo:(id)sender;

@end
