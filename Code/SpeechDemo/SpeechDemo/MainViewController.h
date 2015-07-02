//
//  MainViewController.h
//  SpeechDemo
//
//  Created by idan S on 4/27/13.
//  Copyright (c) 2013 Idan Sheetrit. All rights reserved.
//

#import "FlipsideViewController.h"
#import <SpeechToTextModule.h>

@interface MainViewController : UIViewController <FlipsideViewControllerDelegate>{
    SpeechToTextModule *speechModule;
}

- (IBAction)showInfo:(id)sender;
-(IBAction)stopRecord:(id)sender;

@end
