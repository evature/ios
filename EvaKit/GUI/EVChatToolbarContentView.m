//
//  EVChatToolbarView.m
//  EvaKit
//
//  Created by Yegor Popovych on 7/9/15.
//  Copyright (c) 2015 Evature. All rights reserved.
//

#import "EVChatToolbarContentView.h"
#import "EVVoiceChatMicButtonLayer.h"
#import "EVVoiceLevelMicButtonLayer.h"

@interface EVChatToolbarContentView () {
    BOOL _buttonIsDragging;
}

@property (nonatomic, retain, readwrite) EVVoiceChatMicButtonLayer *micButtonLayer;
@property (nonatomic, retain, readwrite) EVVoiceLevelMicButtonLayer *voiceGraphLayer;
@property (nonatomic, retain, readwrite) CAShapeLayer *overlayLayer;

@end

@implementation EVChatToolbarContentView

- (void)setupView {
//    [self.textView removeFromSuperview];
//    [self setValue:nil forKey:@"textView"];
//    self.leftBarButtonItem = nil;
//    self.rightBarButtonItem = nil;
//    [self.leftBarButtonContainerView removeFromSuperview];
//    [self.rightBarButtonContainerView removeFromSuperview];
//    [self setValue:nil forKey:@"leftBarButtonContainerView"];
//    [self setValue:nil forKey:@"rightBarButtonContainerView"];
    
    UITapGestureRecognizer* tapRecognizer = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture:)] autorelease];
    tapRecognizer.numberOfTapsRequired = 1;
    [self addGestureRecognizer:tapRecognizer];
    
    UIPanGestureRecognizer* panRecognizer = [[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGesture:)] autorelease];
    panRecognizer.minimumNumberOfTouches = 1;
    panRecognizer.maximumNumberOfTouches = 1;
    [self addGestureRecognizer:panRecognizer];
    
    _buttonIsDragging = NO;
    
    self.micButtonLayer = [EVVoiceChatMicButtonLayer layer];
    self.micButtonLayer.micLineWidth = 2.0f;
    self.micButtonLayer.micLineColor = [UIColor blackColor].CGColor;
    self.micButtonLayer.micFillColor = [UIColor redColor].CGColor;
    self.micButtonLayer.micScaleFactor = 0.8f;
    self.micButtonLayer.borderLineWidth = 8.0f;
    self.micButtonLayer.backgroundFillColor = [UIColor yellowColor].CGColor;
    self.micButtonLayer.borderLineColor = [UIColor blackColor].CGColor;
    [self.micButtonLayer setFrame:CGRectMake(0, 0, self.bounds.size.height, self.bounds.size.height)];
   
    self.voiceGraphLayer = [EVVoiceLevelMicButtonLayer layer];
    self.voiceGraphLayer.lineWidth = 3.0f;
    self.voiceGraphLayer.strokeColor = [UIColor whiteColor].CGColor;
    self.voiceGraphLayer.backgroundColor = nil;
    [self.voiceGraphLayer setFrame:CGRectMake(0, 0, self.frame.size.height, self.frame.size.height)];
    
    self.voiceGraphLayer.position = self.micButtonLayer.position = CGPointMake(self.bounds.size.width/2.0f, self.bounds.size.height/2.0f);
    //self.voiceGraphLayer.hidden = YES;
    
    self.overlayLayer = [CAShapeLayer layer];
    self.overlayLayer.fillColor = [UIColor colorWithWhite:0.5 alpha:0.5].CGColor;
    self.overlayLayer.strokeColor = nil;
    CGPathRef path = CGPathCreateWithEllipseInRect(CGRectMake(0, 0, self.bounds.size.height, self.bounds.size.height), NULL);
    self.overlayLayer.path = path;
    CFRelease(path);
    self.overlayLayer.frame = self.micButtonLayer.frame;
    self.overlayLayer.position = self.micButtonLayer.position;
    self.overlayLayer.hidden = YES;
    
    [self.layer addSublayer:self.micButtonLayer];
    [self.layer addSublayer:self.voiceGraphLayer];
    [self.layer addSublayer:self.overlayLayer];
    
    [self.voiceGraphLayer audioSessionStarted];
}

- (instancetype)init {
    self = [super init];
    if (self != nil) {
        [self setupView];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self != nil) {
        [self setupView];
    }
    return self;
}

- (void)setFrame:(CGRect)frame {
    
}

- (IBAction)tapGesture:(UIGestureRecognizer*)recognizer {
    CGPoint touchPoint = [recognizer locationInView:self];
    touchPoint = [self.layer convertPoint:touchPoint toLayer:self.layer.superlayer];
    CALayer* theLayer = [self.layer hitTest:touchPoint];
    if (theLayer == self.voiceGraphLayer || theLayer == self.micButtonLayer || theLayer == self.overlayLayer) {
        if (recognizer.state == UIGestureRecognizerStateEnded) {
            [CATransaction begin];
            self.overlayLayer.hidden = YES;
            //self.voiceGraphLayer.frame = self.micButtonLayer.frame = CGRectMake(0, 0, self.bounds.size.height/1.2f, self.bounds.size.height/1.2f);
            //self.voiceGraphLayer.position = self.micButtonLayer.position = CGPointMake(self.bounds.size.width/2.0f, self.bounds.size.height/2.0f);
            [CATransaction commit];
        }
    }
}

- (IBAction)panGesture:(UIPanGestureRecognizer*)recognizer {
    CGPoint location = [recognizer locationInView:self];
    if (_buttonIsDragging) {
        CGFloat buttonCenter = self.voiceGraphLayer.bounds.size.width/2.0f;
        if (location.x < buttonCenter) {
            location.x = buttonCenter;
        } else if (location.x > (self.bounds.size.width - buttonCenter)) {
            location.x = (self.bounds.size.width - buttonCenter);
        }
        
        [CATransaction begin];
        //[CATransaction setValue: (id) kCFBooleanTrue forKey: kCATransactionDisableActions];
        [CATransaction setAnimationDuration:0.08];
        self.voiceGraphLayer.position = self.micButtonLayer.position = self.overlayLayer.position = CGPointMake(location.x, self.bounds.size.height/2.0f);
        [CATransaction commit];
        if (recognizer.state == UIGestureRecognizerStateEnded) {
            [CATransaction begin];
            //self.voiceGraphLayer.frame = self.micButtonLayer.frame = CGRectMake(0, 0, self.bounds.size.height/1.2f, self.bounds.size.height/1.2f);
            self.voiceGraphLayer.position = self.micButtonLayer.position = self.overlayLayer.position = CGPointMake(self.bounds.size.width/2.0f, self.bounds.size.height/2.0f);
            [CATransaction commit];
            self.overlayLayer.hidden = YES;
            _buttonIsDragging = NO;
        }
//        } else if (recognizer.state == UIGestureRecognizerStateBegan) {
//            [CATransaction begin];
//            self.voiceGraphLayer.frame = self.micButtonLayer.frame = CGRectMake(0, 0, self.bounds.size.height-2, self.bounds.size.height-2);
//            self.voiceGraphLayer.position = self.micButtonLayer.position = CGPointMake(self.bounds.size.width/2.0f, self.bounds.size.height/2.0f);
//            [CATransaction commit];
//        }
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    if ([touches count] == 1) {
        CGPoint point = [[touches anyObject] locationInView:self];
        point = [self.layer convertPoint:point toLayer:self.layer.superlayer];
        CALayer* theLayer = [self.layer hitTest:point];
        if (theLayer == self.voiceGraphLayer || theLayer == self.micButtonLayer) {
            _buttonIsDragging = YES;
            self.overlayLayer.hidden = NO;
//            [CATransaction begin];
//            //self.voiceGraphLayer.frame = self.micButtonLayer.frame = CGRectMake(0, 0, self.bounds.size.height-2, self.bounds.size.height-2);
//            self.voiceGraphLayer.position = self.micButtonLayer.position = CGPointMake(self.bounds.size.width/2.0f, self.bounds.size.height/2.0f);
//            [CATransaction commit];
        }
    }
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self setupView];
}

- (void)newAudioLevelData:(NSData*)data {
    [self.voiceGraphLayer newAudioLevelData:data];
}
- (void)newMinVolume:(CGFloat)minVolume andMaxVolume:(CGFloat)maxVolume {
    [self.voiceGraphLayer newMinVolume:minVolume andMaxVolume:maxVolume];
}

@end
