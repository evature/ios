//
//  FlipsideViewController.m
//  EvaTest
//
//  Created by idan S on 5/12/13.
//  Copyright (c) 2013 Evature. All rights reserved.
//

#import "FlipsideViewController.h"
#import <Eva/Eva.h>

@interface FlipsideViewController ()

@end

@implementation FlipsideViewController
@synthesize dataTextView;
@synthesize repeatTextField;
@synthesize toggleRpeatButton;


int timesToRepeat = 0;
int size = -1;

-(void)viewWillAppear:(BOOL)animated{
    [dataTextView setText:[[NSUserDefaults standardUserDefaults] stringForKey:kLastJsonStringFromEva]];
    [Eva sharedInstance].delegate = self;
    [[Eva sharedInstance] setDebugMode:YES];
    size  = -1;
}

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

NSDate *startTime = nil;

- (void)iterateEva
{
    if (timesToRepeat > 0) {
        NSString *prevText= [dataTextView text];
        NSString *cutText = [prevText substringToIndex: MIN(1280, [prevText length])];
        [dataTextView setText:[NSString stringWithFormat:@"%d: \n%@", timesToRepeat, cutText]];
        NSLog(@"Starting repeat %d", timesToRepeat);
        timesToRepeat--;
        startTime = [NSDate date];
        [[Eva sharedInstance] repeatStreamer];
    }
    else {
        [toggleRepeatButton setTitle:@"Start"  forState:UIControlStateNormal];
        [dataTextView setText:[NSString stringWithFormat:@"%@ All DONE\n ",  [dataTextView text]]];
    }
}

- (void)evaDidReceiveData:(NSData *)dataFromServer{
    if (startTime == nil) {
        NSLog(@"start time = nil?");
    }
    NSDate *finishTime = [NSDate date];
    NSTimeInterval executionTime = [finishTime timeIntervalSinceDate:startTime];
    startTime = nil;

    NSString* dataStr = [[NSString alloc] initWithData:dataFromServer encoding:NSUTF8StringEncoding];
    NSLog(@"Response for %d:  %@", (timesToRepeat+1), dataStr);
    
    NSData *jsonData = [dataStr dataUsingEncoding:NSUTF8StringEncoding];
    NSError *e;
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&e];
    if (e != nil) {
        NSLog(@"Error converting to JSON %@", e);
    }
    
    if (size == -1) {
        size = [dict[@"body_size"] intValue];
        NSLog(@"Setting expectation size to %d", size);
    }
    else {
        if (size != [dict[@"body_size"] intValue]) {
            NSLog(@"Size difference!");
            timesToRepeat = 0;
        }
    }
    
    [dataTextView setText:[NSString stringWithFormat:@" received size %@ in %f sec  - %@",  dict[@"body_size"], executionTime, [dataTextView text]]];

    [self iterateEva];
}

- (void)evaDidFailWithError:(NSError *)error {
    if (startTime == nil) {
        NSLog(@"start time = nil?");
    }
    NSDate *finishTime = [NSDate date];
    NSTimeInterval executionTime = [finishTime timeIntervalSinceDate:startTime];
    startTime = nil;
    NSLog(@"Got error from Eva !!!");
    [dataTextView setText:[NSString stringWithFormat:@" failed: %@  in %f sec  - %@", [error description], executionTime, [dataTextView text]]];
    //[self iterateEva];
}

-(IBAction)toggleRepeat:(id)sender
{
    if ([[toggleRpeatButton titleLabel].text isEqualToString:@"Start"]) {
        [toggleRepeatButton setTitle:@"Stop"  forState:UIControlStateNormal];
        NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
        [f setNumberStyle:NSNumberFormatterDecimalStyle];
        NSNumber * timesRepeat = [f numberFromString: [repeatTextField text]];
        timesToRepeat = [timesRepeat intValue];
        [dataTextView setText:[NSString stringWithFormat:@"Repeating %d times:\n", timesToRepeat]];
        
        [self iterateEva];
    }
    else {
        [toggleRepeatButton setTitle:@"Start"  forState:UIControlStateNormal];
        [[Eva sharedInstance] stopRecordQueue: YES];
        timesToRepeat = 0;
    }
}


@end
