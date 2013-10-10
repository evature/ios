//
//  MainViewController.h
//  EvaDemo
//
//  Created by idan S on 2/7/13.
//  Copyright (c) 2013 Evature. All rights reserved.
//

#import "FlipsideViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface MainViewController : UIViewController <FlipsideViewControllerDelegate>
{
    CAEmitterLayer *emitterLayer;
}

@property (retain , nonatomic) CAEmitterLayer *emitterLayer;

@end
