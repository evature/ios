//
//  ViewController.m
//  EvaKitExample
//
//  Created by Yegor Popovych on 7/7/15.
//  Copyright (c) 2015 Evature. All rights reserved.
//

#import "ViewController.h"
#import "EVVoiceChatMicButtonLayer.h"

@interface ViewController ()

@property (nonatomic, retain) EVVoiceChatMicButtonLayer* layer;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.layer = [EVVoiceChatMicButtonLayer layer];
    self.layer.micLineWidth = 2.0f;
    self.layer.micLineColor = [UIColor blackColor].CGColor;
    self.layer.micFillColor = [UIColor redColor].CGColor;
    self.layer.micScaleFactor = 0.8f;
    self.layer.borderLineWidth = 10.0f;
    self.layer.backgroundFillColor = [UIColor yellowColor].CGColor;
    self.layer.borderLineColor = [UIColor blackColor].CGColor;
    [self.layer setFrame:CGRectMake(0, 0, self.layerView.frame.size.width, self.layerView.frame.size.height)];
    [self.layerView.layer addSublayer:self.layer];
    // Do any additional setup after loading the view, typically from a nib.
}

- (IBAction)rotate:(id)sender {
    static BOOL rotated = NO;
    if (rotated) {
        [self.layer showMicLayer];
        [self.layer stopSpinning];
    } else {
        [self.layer hideMicLayer];
        [self.layer startSpinning];
    }
    rotated = !rotated;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
