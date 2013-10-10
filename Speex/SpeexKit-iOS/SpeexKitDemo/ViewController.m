//
//  ViewController.m
//  SpeexKitDemo
//
//  Created by Ryan Wang on 7/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ViewController.h"
#import <SpeexKit/SpeexKit.h>

#define MAX_FRAME_BYTES 2000
#define MAX_FRAME_SIZE 2000

#include <stdio.h>

#define NN 160

int test_main2()
{
    short in[NN];
    int i;
    SpeexPreprocessState *st;
    int count=0;
    float f;
    
    st = speex_preprocess_state_init(NN, 8000);
    i=1;
    speex_preprocess_ctl(st, SPEEX_PREPROCESS_SET_DENOISE, &i);
    i=0;
    speex_preprocess_ctl(st, SPEEX_PREPROCESS_SET_AGC, &i);
    i=8000;
    speex_preprocess_ctl(st, SPEEX_PREPROCESS_SET_AGC_LEVEL, &i);
    i=0;
    speex_preprocess_ctl(st, SPEEX_PREPROCESS_SET_DEREVERB, &i);
    f=.0;
    speex_preprocess_ctl(st, SPEEX_PREPROCESS_SET_DEREVERB_DECAY, &f);
    f=.0;
    speex_preprocess_ctl(st, SPEEX_PREPROCESS_SET_DEREVERB_LEVEL, &f);
    while (1)
    {
        int vad;
        fread(in, sizeof(short), NN, stdin);
        if (feof(stdin))
            break;
        vad = speex_preprocess_run(st, in);
        /*fprintf (stderr, "%d\n", vad);*/
        fwrite(in, sizeof(short), NN, stdout);
        count++;
    }
    speex_preprocess_state_destroy(st);
    return 0;
}

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    button.frame = CGRectMake(100, 30, 100, 40);
    [button setTitle:@"Decode" forState:UIControlStateNormal];
    [self.view addSubview:button];
    [button addTarget:self action:@selector(startDecode) forControlEvents:UIControlEventTouchUpInside];
    
    
    [self test];
    //test_main2();
    
}

- (void)test {
    NSLog(@"version : %@",[SpeexDecoder version]);
    NSLog(@"longVersion : %@",[SpeexDecoder longVersion]);

    
}

- (void)startDecode {
    NSString *infilePath = [[NSBundle mainBundle] pathForResource:@"output" ofType:@"spx"];
//    NSString *outfilePath = [NSHomeDirectory() stringByAppendingFormat:@"/Documents/decode1.wav"];
    //    [decoder decodeInFilePath:infilePath outFilePath:outfilePath];
    SpeexDecoder *decoder = [[[SpeexDecoder alloc] initWithEncodedFile:infilePath delegate:self] autorelease];
    
    [decoder start];

}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

@end
