//
//  EvaFlipsideViewController.m
//  EvaTestApp
//
//  Created by idan S on 7/30/13.
//  Copyright (c) 2013 IdanS. All rights reserved.
//

#import "EvaFlipsideViewController.h"

@interface EvaFlipsideViewController ()

@end

@implementation EvaFlipsideViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Actions

- (IBAction)done:(id)sender
{
    [self.delegate flipsideViewControllerDidFinish:self];
}

@end
