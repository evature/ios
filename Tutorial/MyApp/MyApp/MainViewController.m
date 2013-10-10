//
//  MainViewController.m
//  MyApp
//
//  Created by idan S on 5/23/13.
//  Copyright (c) 2013 Evature. All rights reserved.
//

#import "MainViewController.h"

@interface MainViewController ()

@end

@implementation MainViewController
@synthesize evaModule;

#pragma mark - Eva Delegate
- (void)evaDidReceiveData:(NSData *)dataFromServer{
    NSString* dataStr = [[NSString alloc] initWithData:dataFromServer encoding:NSASCIIStringEncoding];
    
    NSLog(@"Chunk from delegate %@", dataStr);
}

- (void)evaDidFailWithError:(NSError *)error{
    NSLog(@"Got error from Eva");
}

#pragma mark - Views

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    evaModule = [[Eva alloc] init];
    
    evaModule.delegate = self;
    
    // Initialize Eva keys //
    [evaModule setAPIkey:@"YOUR-API_KEY"
            withSiteCode:@"YOUR-SITE-CODE"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Flipside View

- (void)flipsideViewControllerDidFinish:(FlipsideViewController *)controller
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)showInfo:(id)sender
{    
    FlipsideViewController *controller = [[FlipsideViewController alloc] initWithNibName:@"FlipsideViewController" bundle:nil];
    controller.delegate = self;
    controller.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentViewController:controller animated:YES completion:nil];
}

@end
