//
//  MainViewController.m
//  EvaDemo
//
//  Created by idan S on 2/7/13.
//  Copyright (c) 2013 Evature. All rights reserved.
//

#import "MainViewController.h"
//#import "speex.h"
#import "config.h"
//#import <CSource/>
//#import <speex/speex.h>
//#import <speex-1.2rc1/include/speex/speex.h>
//#import <speex.h>




#define MIC_BUTTON_RADIOUS 30
#define MIC_BUTTON_SPACE_FROM_BOTTOM 30
#define MIC_BUTTON_SPACE_OF_INTERNAL_CIRCLE 4

@interface MainViewController ()

@end

@implementation MainViewController
@synthesize emitterLayer;



- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    //[self createSiriEffect];
    [self createMicButton];
    
    
  //  NSLog(@"Speex version = %s",SPEEX_VERSION);
   /* SpeexBits bits;
    
    void *enc_state;
    //The two are initialized by:
    speex_bits_init(&bits);
    enc_state = speex_encoder_init(&speex_nb_mode);*/
    //speex_encode(nil, nil, nil);
    
   
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

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showAlternate"]) {
        [[segue destinationViewController] setDelegate:self];
    }
}

#pragma mark -
#pragma mark Mic view& Effect

-(void)createMicButton{
    UIImage *micButtonImage = [UIImage imageNamed:@"SiriMic.png"];
    
    UIButton *micButton = [UIButton buttonWithType:UIButtonTypeCustom];
    micButton.frame =  CGRectMake(self.view.bounds.size.width/2 - MIC_BUTTON_RADIOUS, self.view.bounds.size.height - MIC_BUTTON_RADIOUS*2 - MIC_BUTTON_SPACE_FROM_BOTTOM, MIC_BUTTON_RADIOUS*2, MIC_BUTTON_RADIOUS*2);//CGRectMake(280.0, 10.0, 29.0, 29.0);
    [micButton setBackgroundImage:micButtonImage forState:UIControlStateNormal];
    
    [self.view addSubview:micButton];
    
    [micButton addTarget:self action:@selector(createSiriEffect) forControlEvents:UIControlEventTouchUpInside];
}

-(void)createSiriEffect{
// create emitter layer
    //emitterLayer = [CAEmitterLayer layer];
emitterLayer = [CAEmitterLayer layer];
emitterLayer.frame = CGRectMake(0, 0, self.view.bounds.size.width,  self.view.bounds.size.height);

emitterLayer.emitterMode = kCAEmitterLayerOutline;
emitterLayer.emitterShape = kCAEmitterLayerLine;
emitterLayer.renderMode = kCAEmitterLayerAdditive;
[emitterLayer setEmitterSize:CGSizeMake(4, 4)];

// create the ball emitter cell
CAEmitterCell *ball = [CAEmitterCell emitterCell];
ball.color = [[UIColor colorWithRed:111.0/255.0 green:80.0/255.0 blue:241.0/255.0 alpha:0.10] CGColor];
ball.contents = (id)[[UIImage imageNamed:@"ball.png"] CGImage] ; // ball.png is simply an image of white circle

[ball setName:@"ball"];

emitterLayer.emitterCells = [NSArray arrayWithObject:ball];
[self.view.layer addSublayer:emitterLayer];

float factor = 1.5; // you should play around with this value
[emitterLayer setValue:[NSNumber numberWithInt:(factor * 500)] forKeyPath:@"emitterCells.ball.birthRate"];
[emitterLayer setValue:[NSNumber numberWithFloat:factor * 0.25] forKeyPath:@"emitterCells.ball.lifetime"];
[emitterLayer setValue:[NSNumber numberWithFloat:(factor * 0.15)] forKeyPath:@"emitterCells.ball.lifetimeRange"];


// animation code
CAKeyframeAnimation* circularAnimation = [CAKeyframeAnimation animationWithKeyPath:@"emitterPosition"];
CGMutablePathRef path = CGPathCreateMutable();
CGRect pathRect =CGRectMake(self.view.bounds.size.width/2 - MIC_BUTTON_RADIOUS+ MIC_BUTTON_SPACE_OF_INTERNAL_CIRCLE, self.view.bounds.size.height - MIC_BUTTON_RADIOUS*2 - MIC_BUTTON_SPACE_FROM_BOTTOM + MIC_BUTTON_SPACE_OF_INTERNAL_CIRCLE, (MIC_BUTTON_RADIOUS-MIC_BUTTON_SPACE_OF_INTERNAL_CIRCLE)*2, (MIC_BUTTON_RADIOUS-MIC_BUTTON_SPACE_OF_INTERNAL_CIRCLE)*2);
    
     // define circle bounds with rectangle
CGPathAddEllipseInRect(path, NULL, pathRect);
circularAnimation.path = path;
CGPathRelease(path);
circularAnimation.duration = 1.5; // 2
circularAnimation.repeatDuration = 0;
circularAnimation.repeatCount = 3;
circularAnimation.calculationMode = kCAAnimationPaced;
[emitterLayer addAnimation:circularAnimation forKey:@"circularAnimation"];
}

@end
