//
//  ViewController.m
//  EvaKitExample
//
//  Created by Yegor Popovych on 7/7/15.
//  Copyright (c) 2015 Evature. All rights reserved.
//

#import "ViewController.h"


@interface ViewController ()


@end

@implementation ViewController

//- (void)viewDidLoad {
//    [super viewDidLoad];
//    [self.layerView newMinVolume:5.0f andMaxVolume:70.0f];
//    [NSTimer scheduledTimerWithTimeInterval:0.15 target:self selector:@selector(updateGraph:) userInfo:nil repeats:YES];
//    // Do any additional setup after loading the view, typically from a nib.
//}
//
//- (void)updateGraph:(NSTimer *)timer {
//    CGFloat val = (rand()%255)/4.5f+6.0f;
//    [self.layerView newAudioLevelData:[NSData dataWithBytes:&val length:sizeof(CGFloat)]];
//}
//
//- (IBAction)rotate:(id)sender {
//    static BOOL rotated = YES;
//    if (rotated) {
//        [self.layerView audioSessionStarted];
//    } else {
//        [self.layerView audioSessionStoped];
//    }
//    rotated = !rotated;
//}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
