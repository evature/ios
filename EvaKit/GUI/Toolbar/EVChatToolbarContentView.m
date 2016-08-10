//
//  EVChatToolbarView.m
//  EvaKit
//
//  Created by Yegor Popovych on 7/9/15.
//  Copyright (c) 2015 Evature. All rights reserved.
//

#import "EVChatToolbarContentView.h"
#import "EVVoiceChatMicButtonLayer.h"
#import "EVSVGButtonWithCircleBackgroundLayer.h"
#import "EVResizableShapeLayer.h"
#import "EVSpringAnimation.h"
#import "EVLogger.h"

#define BUTTON_MARGIN 8.0f
//#define BUTTON_TOP_BOTTOM_MARGIN 8.0f
#define LONG_PRESS_WAIT_TIME 0.5

typedef NS_ENUM(uint8_t, EVMicButtonState) {
    EVMicButtonStateShowingMic = 0,
    EVMicButtonStateHidingMic,
    EVMicButtonStateShowingVoice,
    EVMicButtonStateHidingVoice
};

@interface EVChatToolbarContentView () {
    BOOL _buttonIsDragging;
    EVMicButtonState _micButtonState;
    BOOL _recording;
    BOOL _longPress;
}

@property (nonatomic, strong, readwrite) EVVoiceChatMicButtonLayer *micButtonLayer;
@property (nonatomic, strong, readwrite) EVSVGButtonWithCircleBackgroundLayer* leftButtonLayer;
@property (nonatomic, strong, readwrite) EVSVGButtonWithCircleBackgroundLayer* rightButtonLayer;
@property (nonatomic, strong, readwrite) NSMutableSet* changedProperties;

- (void)setupView;
- (void)recalculateButtonBackgroundSize;
- (void)setupButtonPositions;
- (void)moveCenterButtonBack;
- (void)longPressStart;

@end

@implementation EVChatToolbarContentView


#pragma mark === Layers and View Setup and Calculations ===

- (void)setupView {
//    UITapGestureRecognizer* tapRecognizer = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture:)] autorelease];
//    tapRecognizer.numberOfTapsRequired = 1;
//    [self addGestureRecognizer:tapRecognizer];
    
    UIPanGestureRecognizer* panRecognizer = [[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGesture:)] autorelease];
    panRecognizer.minimumNumberOfTouches = 1;
    panRecognizer.maximumNumberOfTouches = 1;
    [self addGestureRecognizer:panRecognizer];
    
    _buttonIsDragging = NO;
    _recording = NO;
    _longPress = NO;
    
    self.micButtonLayer = [EVVoiceChatMicButtonLayer layer];
    self.micButtonLayer.svgLineWidth = _centerButtonMicLineWidth;
    self.micButtonLayer.svgLineColor = _centerButtonMicLineColor.CGColor;
    self.micButtonLayer.svgFillColor = _centerButtonMicColor.CGColor;
    self.micButtonLayer.svgScaleFactor = _centerButtonMicScale;
    self.micButtonLayer.borderLineWidth = _centerButtonBorderWidth;
    self.micButtonLayer.backgroundFillColor = _centerButtonBackgroundColor.CGColor;
    self.micButtonLayer.borderLineColor = _centerButtonBorderColor.CGColor;
    self.micButtonLayer.highlightColor = _centerButtonHighlightColor.CGColor;
    self.micButtonLayer.spinningBorderWidth = _centerButtonSpinningBorderWidth;
    
    self.micButtonLayer.imageLayer.shadowColor = _centerButtonMicShadowColor.CGColor;
    self.micButtonLayer.imageLayer.shadowOffset = _centerButtonMicShadowOffset;
    self.micButtonLayer.imageLayer.shadowOpacity = _centerButtonMicShadowOpacity;
    self.micButtonLayer.imageLayer.shadowRadius = _centerButtonMicShadowRadius;
    
    self.micButtonLayer.backgroundLayer.shadowColor = _centerButtonBackgroundShadowColor.CGColor;
    self.micButtonLayer.backgroundLayer.shadowOffset = _centerButtonBackgroundShadowOffset;
    self.micButtonLayer.backgroundLayer.shadowOpacity = _centerButtonBackgroundShadowOpacity;
    self.micButtonLayer.backgroundLayer.shadowRadius = _centerButtonBackgroundShadowRadius;
    
    [self.layer addSublayer:self.micButtonLayer];
    
    
    self.leftButtonLayer = [EVSVGButtonWithCircleBackgroundLayer layer];
    self.rightButtonLayer = [EVSVGButtonWithCircleBackgroundLayer layer];
    
    self.leftButtonLayer.backgroundFillColor = self.rightButtonLayer.backgroundFillColor = _leftRightButtonsBackgroundColor.CGColor;
    ((EVResizableShapeLayer*)self.leftButtonLayer.imageLayer).fillColor = ((EVResizableShapeLayer*)self.rightButtonLayer.imageLayer).fillColor = _leftRightButtonsImageColor.CGColor;
    
    self.leftButtonLayer.zPosition = self.rightButtonLayer.zPosition = 100.0f;
    
    ((EVResizableShapeLayer*)self.leftButtonLayer.backgroundLayer).pathScale = ((EVResizableShapeLayer*)self.rightButtonLayer.backgroundLayer).pathScale = _leftRightButtonsUnactiveBackgroundScale;
    
    ((EVResizableShapeLayer*)self.leftButtonLayer.imageLayer).pathScale = ((EVResizableShapeLayer*)self.rightButtonLayer.imageLayer).pathScale = _leftRightButtonsImageScale;
    
    ((EVResizableShapeLayer*)self.leftButtonLayer.backgroundLayer).lineWidth = ((EVResizableShapeLayer*)self.rightButtonLayer.backgroundLayer).lineWidth = _leftRightButtonsBorderWidth;
    ((EVResizableShapeLayer*)self.leftButtonLayer.backgroundLayer).strokeColor = ((EVResizableShapeLayer*)self.rightButtonLayer.backgroundLayer).strokeColor = _leftRightButtonsBorderColor.CGColor;
    
    self.leftButtonLayer.imageLayer.shadowColor = self.rightButtonLayer.imageLayer.shadowColor = _leftRightButtonsImageShadowColor.CGColor;
    self.leftButtonLayer.imageLayer.shadowOffset = self.rightButtonLayer.imageLayer.shadowOffset = _leftRightButtonsImageShadowOffset;
    self.leftButtonLayer.imageLayer.shadowOpacity = self.rightButtonLayer.imageLayer.shadowOpacity = _leftRightButtonsImageShadowOpacity;
    self.leftButtonLayer.imageLayer.shadowRadius = self.rightButtonLayer.imageLayer.shadowRadius = _leftRightButtonsImageShadowRadius;
    
    self.leftButtonLayer.backgroundLayer.shadowColor = self.rightButtonLayer.backgroundLayer.shadowColor = _leftRightButtonsBackgroundShadowColor.CGColor;
    self.leftButtonLayer.backgroundLayer.shadowOffset = self.rightButtonLayer.backgroundLayer.shadowOffset = _leftRightButtonsBackgroundShadowOffset;
    self.leftButtonLayer.backgroundLayer.shadowOpacity = self.rightButtonLayer.backgroundLayer.shadowOpacity = _leftRightButtonsBackgroundShadowOpacity;
    self.leftButtonLayer.backgroundLayer.shadowRadius = self.rightButtonLayer.backgroundLayer.shadowRadius = _leftRightButtonsBackgroundShadowRadius;
    
    [self.leftButtonLayer setImageFromSVGFile:[[NSBundle bundleForClass:[self class]] pathForResource:@"EvaKit_Undo" ofType:@"svg"]];
    [self.rightButtonLayer setImageFromSVGFile:[[NSBundle bundleForClass:[self class]] pathForResource:@"EvaKit_Trash" ofType:@"svg"]];
    
    [self.layer addSublayer:self.leftButtonLayer];
    [self.layer addSublayer:self.rightButtonLayer];
    
    [self setupButtonPositions];
    
}

- (void)setupButtonPositions {
    
    CGRect frame = CGRectMake(0, 0, self.bounds.size.height-_leftRightButtonsOffset*2, self.bounds.size.height-_leftRightButtonsOffset*2);
    [self.micButtonLayer setFrame:frame];
    [self.micButtonLayer setPosition:CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds))];
    
    [self.leftButtonLayer setAnchorPoint:CGPointMake(0.0f, 0.5f)];
    [self.leftButtonLayer setFrame:frame];
    [self.leftButtonLayer setPosition:CGPointMake(CGRectGetMinX(self.bounds)+_leftRightButtonsOffset, CGRectGetMidY(self.bounds))];
    
    [self.rightButtonLayer setAnchorPoint:CGPointMake(1.0f, 0.5f)];
    [self.rightButtonLayer setFrame:frame];
    [self.rightButtonLayer setPosition:CGPointMake(CGRectGetMaxX(self.bounds)-_leftRightButtonsOffset, CGRectGetMidY(self.bounds))];
}


- (void)recalculateButtonBackgroundSize {
    CGFloat center = CGRectGetMidX(self.bounds);
    CGFloat centerButtonPos = self.micButtonLayer.position.x;
    CGFloat centerButtonWidth_2 = self.micButtonLayer.bounds.size.width / 2.0f;
    if (_buttonIsDragging) {
        if (centerButtonPos < center) {
            ((EVResizableShapeLayer*)self.leftButtonLayer.backgroundLayer).pathScale = _leftRightButtonsActiveBackgroundScale + ((center - fabs(centerButtonPos - centerButtonWidth_2 - self.leftButtonLayer.position.x)) / center)*(_leftRightButtonsMaxBackgroundScale - _leftRightButtonsActiveBackgroundScale);
            ((EVResizableShapeLayer*)self.leftButtonLayer.imageLayer).pathScale = _leftRightButtonsImageScale + ((center - fabs(centerButtonPos + centerButtonWidth_2 - self.leftButtonLayer.position.x)) / center) * (_leftRightButtonsMaxImageScale - _leftRightButtonsImageScale);
            ((EVResizableShapeLayer*)self.rightButtonLayer.backgroundLayer).pathScale = _leftRightButtonsActiveBackgroundScale;
            ((EVResizableShapeLayer*)self.rightButtonLayer.imageLayer).pathScale = _leftRightButtonsImageScale;
        } else if (centerButtonPos > center){
            ((EVResizableShapeLayer*)self.rightButtonLayer.backgroundLayer).pathScale = _leftRightButtonsActiveBackgroundScale + ((center - fabs(centerButtonPos + centerButtonWidth_2 - self.rightButtonLayer.position.x)) / center)*(_leftRightButtonsMaxBackgroundScale - _leftRightButtonsActiveBackgroundScale);
            ((EVResizableShapeLayer*)self.rightButtonLayer.imageLayer).pathScale = _leftRightButtonsImageScale + ((center - fabs(centerButtonPos + centerButtonWidth_2 - self.rightButtonLayer.position.x)) / center) * (_leftRightButtonsMaxImageScale - _leftRightButtonsImageScale);
            ((EVResizableShapeLayer*)self.leftButtonLayer.backgroundLayer).pathScale = _leftRightButtonsActiveBackgroundScale;
            ((EVResizableShapeLayer*)self.leftButtonLayer.imageLayer).pathScale = _leftRightButtonsImageScale;
        }
    } else {
        ((EVResizableShapeLayer*)self.rightButtonLayer.backgroundLayer).pathScale = _leftRightButtonsUnactiveBackgroundScale;
        ((EVResizableShapeLayer*)self.leftButtonLayer.backgroundLayer).pathScale = _leftRightButtonsUnactiveBackgroundScale;
        ((EVResizableShapeLayer*)self.leftButtonLayer.imageLayer).pathScale = _leftRightButtonsImageScale;
        ((EVResizableShapeLayer*)self.rightButtonLayer.imageLayer).pathScale = _leftRightButtonsImageScale;
    }
}


- (void)layoutSubviews {
    [super layoutSubviews];
    [self setupButtonPositions];
    [self recalculateButtonBackgroundSize];
}

#pragma mark === Initialization and default values ====

- (instancetype)init {
    self = [super init];
    if (self != nil) {
        self.changedProperties = [NSMutableSet set];
        
        _centerButtonBackgroundColor = [[UIColor colorWithRed:208.0f/255.0f green:67.0f/255.0f blue:62.0f/255.0f alpha:0.9f] retain];
        _centerButtonBorderColor = [[UIColor whiteColor] retain];
        _centerButtonHighlightColor = [[UIColor colorWithWhite:0.0f alpha:0.5f] retain];
        _centerButtonBorderWidth = 2.0f;
        _centerButtonSpinningBorderWidth = 3.0f;
        
        _centerButtonMicShadowColor = [[UIColor blackColor] retain];
        _centerButtonBackgroundShadowColor = [_centerButtonMicShadowColor retain];
        _centerButtonMicShadowOffset = _centerButtonBackgroundShadowOffset = CGSizeMake(0, -3.0f);
        _centerButtonBackgroundShadowOpacity = _centerButtonMicShadowOpacity = 0.0f;
        _centerButtonMicShadowRadius = _centerButtonBackgroundShadowRadius = 3.0f;
        
        _centerButtonMicLineColor = [[UIColor whiteColor] retain];
        
        _centerButtonMicLineWidth = 0.0f;
        _centerButtonMicColor = [[UIColor whiteColor] retain];
        _centerButtonMicScale = 0.7f;
        
        _leftRightButtonsBackgroundColor = [_centerButtonBackgroundColor retain];
        _leftRightButtonsBorderWidth = _centerButtonBorderWidth;
        _leftRightButtonsImageScale = 0.6f;
        _leftRightButtonsUnactiveBackgroundScale = 0.00001f;
        _leftRightButtonsActiveBackgroundScale = 0.75f;
        _leftRightButtonsMaxImageScale = 0.8f;
        _leftRightButtonsMaxBackgroundScale = 1.0f;
        _leftRightButtonsImageColor = [_centerButtonMicColor retain];
        _leftRightButtonsBorderColor = [_centerButtonBorderColor retain];
        _leftRightButtonsBackgroundShadowColor = [_centerButtonBackgroundShadowColor retain];
        _leftRightButtonsImageShadowColor = [_centerButtonMicShadowColor retain];
        _leftRightButtonsImageShadowOffset = _centerButtonMicShadowOffset;
        _leftRightButtonsBackgroundShadowOffset = _centerButtonBackgroundShadowOffset;
        _leftRightButtonsBackgroundShadowOpacity = _centerButtonBackgroundShadowOpacity;
        _leftRightButtonsBackgroundShadowRadius = _centerButtonBackgroundShadowRadius;
        _leftRightButtonsImageShadowOpacity = _centerButtonMicShadowOpacity;
        _leftRightButtonsImageShadowRadius = _centerButtonMicShadowRadius;
        
        _leftRightButtonsOffset = BUTTON_MARGIN; //* [UIScreen mainScreen].scale;
        _micButtonState = EVMicButtonStateShowingMic;
        
        [self awakeFromNib];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self setupView];
}

- (void)dealloc {
    self.leftButtonLayer = nil;
    self.rightButtonLayer = nil;
    self.micButtonLayer = nil;
    self.leftRightButtonsBackgroundColor = nil;
    self.leftRightButtonsBorderColor = nil;
    self.leftRightButtonsImageColor = nil;
    self.centerButtonBackgroundColor = nil;
    self.centerButtonBorderColor = nil;
    self.centerButtonHighlightColor = nil;
    self.centerButtonMicColor = nil;
    self.centerButtonMicLineColor = nil;
    self.leftRightButtonsBackgroundShadowColor = nil;
    self.leftRightButtonsImageShadowColor = nil;
    self.centerButtonBackgroundShadowColor = nil;
    self.centerButtonMicShadowColor = nil;
    self.changedProperties = nil;
    [super dealloc];
}


- (void)moveCenterButtonBack {
    EV_LOG_DEBUG(@"Moving center button back");
    CGRect frame = [self.micButtonLayer frame];
    if (CGRectIntersectsRect(frame, self.leftButtonLayer.frame)) {
        CGFloat intersect = (frame.origin.x - self.leftButtonLayer.frame.origin.x) / frame.size.width;
        if (intersect <= 0.2) {
            [self.touchDelegate leftButtonTouched:self];
        }
    } else if (CGRectIntersectsRect(frame, self.rightButtonLayer.frame)) {
        CGFloat intersect = (self.rightButtonLayer.frame.origin.x - frame.origin.x) / frame.size.width;
        if (intersect <= 0.2) {
            [self.touchDelegate rightButtonTouched:self];
        }
    }
    
    
    //[CATransaction begin];
    //[CATransaction setValue:@0.5 forKey:kCATransactionAnimationDuration];
    EVSpringAnimation *animation = [EVSpringAnimation animationWithKeyPath:@"position.x"
                                                                  duration:0.5f
                                                    usingSpringWithDumping:0.8f
                                                           initialVelocity:1.2f
                                                                 fromValue:self.micButtonLayer.position.x
                                                                   toValue:self.bounds.size.width/2.0f];
    
    [self.micButtonLayer addAnimation:animation forKey:@"PositionSpringAnimation"];
    [CATransaction begin];
    [CATransaction setValue: (id) kCFBooleanTrue forKey: kCATransactionDisableActions];
    self.micButtonLayer.position = CGPointMake(self.bounds.size.width/2.0f, self.bounds.size.height/2.0f);
    [CATransaction commit];

    [self.micButtonLayer released];
    
    
    [self.micButtonLayer showMic];
    //[CATransaction commit];
    
    _buttonIsDragging = NO;
    [self recalculateButtonBackgroundSize];
}

#pragma mark === Gesture recognizers for tap and drag ===

//- (IBAction)tapGesture:(UIGestureRecognizer*)recognizer {
//    CGPoint touchPoint = [recognizer locationInView:self];
//    touchPoint = [self.layer convertPoint:touchPoint toLayer:self.layer.superlayer];
//    CALayer* theLayer = [self.layer hitTest:touchPoint];
//    if (theLayer == self.micButtonLayer) {
//        if (recognizer.state == UIGestureRecognizerStateEnded) {
//            [CATransaction begin];
//            [[self micButtonLayer] released];
//            [CATransaction commit];
//            [self.touchDelegate centerButtonTouched:self];
//        }
//    }
//}

- (IBAction)panGesture:(UIPanGestureRecognizer*)recognizer {
    CGPoint location = [recognizer locationInView:self];
    if (_buttonIsDragging && !_recording) {
        CGFloat buttonCenter = self.micButtonLayer.bounds.size.width/2.0f;
        if (location.x < buttonCenter+_leftRightButtonsOffset) {
            location.x = buttonCenter+_leftRightButtonsOffset;
        } else if (location.x > (self.bounds.size.width - buttonCenter-_leftRightButtonsOffset)) {
            location.x = (self.bounds.size.width - buttonCenter-_leftRightButtonsOffset);
        }
        [self recalculateButtonBackgroundSize];
        [CATransaction begin];
        //[CATransaction setValue: (id) kCFBooleanTrue forKey: kCATransactionDisableActions];
        [CATransaction setAnimationDuration:0.08];
        self.micButtonLayer.position = CGPointMake(location.x, self.bounds.size.height/2.0f);
        [CATransaction commit];
        if (recognizer.state == UIGestureRecognizerStateEnded) {
            [self moveCenterButtonBack];
        } else if (recognizer.state == UIGestureRecognizerStateBegan) {
            [self.micButtonLayer removeAllAnimations];
            [self.micButtonLayer hideMic];
            [NSObject cancelPreviousPerformRequestsWithTarget:self];
        }
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    if ([touches count] == 1) {
        CGPoint point = [[touches anyObject] locationInView:self];
        point = [self.layer convertPoint:point toLayer:self.layer.superlayer];
        CALayer* theLayer = [self.layer hitTest:point];
        if (theLayer == self.micButtonLayer) {
            _buttonIsDragging = YES;
            [self.micButtonLayer touched];
            if (!_recording) {
                [self performSelector:@selector(longPressStart) withObject:nil afterDelay:LONG_PRESS_WAIT_TIME];
            }
        } else if (!_recording && (theLayer == self.leftButtonLayer || theLayer == self.rightButtonLayer)) {
            _buttonIsDragging = YES;
            CGFloat x = 0.0;
            if (theLayer == self.leftButtonLayer) {
                x = theLayer.position.x + theLayer.frame.size.width/2.0;
                ((EVResizableShapeLayer*)self.leftButtonLayer.backgroundLayer).pathScale = _leftRightButtonsMaxBackgroundScale;
            } else {
                x = theLayer.position.x - theLayer.frame.size.width/2.0;
                ((EVResizableShapeLayer*)self.rightButtonLayer.backgroundLayer).pathScale = _leftRightButtonsMaxBackgroundScale;
            }
            CABasicAnimation* anim = [CABasicAnimation animationWithKeyPath:@"position.x"];
            [anim setFromValue:@(self.micButtonLayer.position.x)];
            [anim setToValue:@(x)];
            [anim setDuration:0.4];
            [anim setRemovedOnCompletion:NO];
            [anim setFillMode:kCAFillModeBoth];
            [self.micButtonLayer addAnimation:anim forKey:@"LeftRightClick"];
            [self.micButtonLayer hideMic];
        }
    }
}

- (void)longPressStart {
    _longPress = YES;
    [self.touchDelegate centerButtonLongPressStarted:self];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    if ([touches count] == 1) {
        CGPoint touchPoint = [[touches anyObject] locationInView:self];
        touchPoint = [self.layer convertPoint:touchPoint toLayer:self.layer.superlayer];
        CALayer* theLayer = [self.layer hitTest:touchPoint];
        if (theLayer == self.micButtonLayer) {
            _buttonIsDragging = NO;
            [[self micButtonLayer] released];
            [NSObject cancelPreviousPerformRequestsWithTarget:self];
            if (_longPress) {
                [self.touchDelegate centerButtonLongPressEnded:self];
                _longPress = NO;
            } else {
                [self.touchDelegate centerButtonTouched:self];
            }
        } else if (!_recording && (theLayer == self.leftButtonLayer || theLayer == self.rightButtonLayer)) {
            self.micButtonLayer.position = [self.micButtonLayer.presentationLayer position];
            [self.micButtonLayer removeAnimationForKey:@"LeftRightClick"];
            [self moveCenterButtonBack];
        }
    }
}

#pragma mark === Animation external methods ===

- (void)audioSessionStarted {
    _recording = YES;
    [CATransaction begin];
    [CATransaction setCompletionBlock:^{
        if (_micButtonState == EVMicButtonStateHidingMic) {
            [self.micButtonLayer audioSessionStarted];
            _micButtonState = EVMicButtonStateShowingVoice;
        }
    }];
    [self moveCenterButtonBack];
    [self.micButtonLayer hideMic];
    _micButtonState = EVMicButtonStateHidingMic;
    [CATransaction commit];
}

- (void)audioSessionStoped {
    [CATransaction begin];
    [CATransaction setCompletionBlock:^{
        if (_micButtonState == EVMicButtonStateHidingVoice) {
            [self.micButtonLayer showMic];
            _micButtonState = EVMicButtonStateShowingMic;
        }
    }];
    [self.micButtonLayer audioSessionStoped];
    _micButtonState = EVMicButtonStateHidingVoice;
    [CATransaction commit];
}

- (void)startWaitAnimation {
    [self.micButtonLayer startSpinning];
}

- (void)stopWaitAnimation {
    [self.micButtonLayer stopSpinning];
    _recording = NO;
}

- (void)newAudioLevelData:(NSData*)data {
    [self.micButtonLayer newAudioLevelData:data];
}
- (void)newMinVolume:(CGFloat)minVolume andMaxVolume:(CGFloat)maxVolume {
    [self.micButtonLayer newMinVolume:minVolume andMaxVolume:maxVolume];
}

#pragma mark === Setters for properties ===

- (void)setCenterButtonMicLineColor:(UIColor*)centerButtonMicLineColor {
    [_centerButtonMicLineColor release];
    _centerButtonMicLineColor = [centerButtonMicLineColor retain];
    [self.changedProperties addObject:@"centerButtonMicLineColor"];
    self.micButtonLayer.svgLineColor = centerButtonMicLineColor.CGColor;
}

- (void)setCenterButtonMicLineWidth:(CGFloat)centerButtonMicLineWidth {
    _centerButtonMicLineWidth = centerButtonMicLineWidth;
    [self.changedProperties addObject:@"centerButtonMicLineWidth"];
    self.micButtonLayer.svgLineWidth = centerButtonMicLineWidth;
}

- (void)setCenterButtonMicColor:(UIColor*)centerButtonMicColor {
    [_centerButtonMicColor release];
    _centerButtonMicColor = [centerButtonMicColor retain];
    [self.changedProperties addObject:@"centerButtonMicColor"];
    self.micButtonLayer.svgFillColor = centerButtonMicColor.CGColor;
    if (![self.changedProperties containsObject:@"leftRightButtonsImageColor"]) {
        [_leftRightButtonsImageColor release];
        _leftRightButtonsImageColor = [centerButtonMicColor retain];
        ((EVResizableShapeLayer*)self.leftButtonLayer.imageLayer).fillColor = ((EVResizableShapeLayer*)self.rightButtonLayer.imageLayer).fillColor = _leftRightButtonsImageColor.CGColor;
    }
}

- (void)setCenterButtonMicScale:(CGFloat)centerButtonMicScale {
    _centerButtonMicScale = centerButtonMicScale;
    [self.changedProperties addObject:@"centerButtonMicScale"];
    self.micButtonLayer.svgScaleFactor = centerButtonMicScale;
    if (![self.changedProperties containsObject:@"leftRightButtonsImageScale"]) {
        _leftRightButtonsImageScale = centerButtonMicScale;
        ((EVResizableShapeLayer*)self.leftButtonLayer.imageLayer).pathScale = ((EVResizableShapeLayer*)self.rightButtonLayer.imageLayer).pathScale = centerButtonMicScale;
    }
}

- (void)setCenterButtonBackgroundColor:(UIColor*)centerButtonBackgroundColor {
    [_centerButtonBackgroundColor release];
    _centerButtonBackgroundColor = [centerButtonBackgroundColor retain];
    [self.changedProperties addObject:@"centerButtonBackgroundColor"];
    self.micButtonLayer.backgroundFillColor = centerButtonBackgroundColor.CGColor;
    if (![self.changedProperties containsObject:@"leftRightButtonsBackgroundColor"]) {
        [_leftRightButtonsBackgroundColor release];
        _leftRightButtonsBackgroundColor = [centerButtonBackgroundColor retain];
        self.leftButtonLayer.backgroundFillColor = self.rightButtonLayer.backgroundFillColor = _leftRightButtonsBackgroundColor.CGColor;
    }
}

- (void)setCenterButtonBorderWidth:(CGFloat)centerButtonBorderWidth {
    _centerButtonBorderWidth = centerButtonBorderWidth;
    self.micButtonLayer.borderLineWidth = centerButtonBorderWidth;
    [self.changedProperties addObject:@"centerButtonBorderWidth"];
    if (![self.changedProperties containsObject:@"leftRightButtonsBorderWidth"]) {
        _leftRightButtonsBorderWidth = centerButtonBorderWidth;
        self.leftButtonLayer.borderLineWidth = self.rightButtonLayer.borderLineWidth = _leftRightButtonsBorderWidth;
    }
}

- (void)setCenterButtonBorderColor:(UIColor*)centerButtonBorderColor {
    [_centerButtonBorderColor release];
    _centerButtonBorderColor = [centerButtonBorderColor retain];
    [self.changedProperties addObject:@"centerButtonBorderColor"];
    self.micButtonLayer.borderLineColor = centerButtonBorderColor.CGColor;
    if (![self.changedProperties containsObject:@"leftRightButtonsBorderColor"]) {
        [_leftRightButtonsBorderColor release];
        _leftRightButtonsBorderColor = [centerButtonBorderColor retain];
        self.leftButtonLayer.borderLineColor = self.rightButtonLayer.borderLineColor = _leftRightButtonsBorderColor.CGColor;
    }
}

- (void)setCenterButtonHighlightColor:(UIColor*)centerButtonHighlightColor {
    [_centerButtonHighlightColor release];
    _centerButtonHighlightColor = [centerButtonHighlightColor retain];
    [self.changedProperties addObject:@"centerButtonHighlightColor"];
    self.micButtonLayer.highlightColor = centerButtonHighlightColor.CGColor;
}

- (void)setCenterButtonSpinningBorderWidth:(CGFloat)centerButtonSpinningBorderWidth {
    _centerButtonSpinningBorderWidth = centerButtonSpinningBorderWidth;
    [self.changedProperties addObject:@"centerButtonSpinningBorderWidth"];
    self.micButtonLayer.spinningBorderWidth = centerButtonSpinningBorderWidth;
}

- (void)setLeftRightButtonsBackgroundColor:(UIColor*)leftRightButtonsBackgroundColor {
    [_leftRightButtonsBackgroundColor release];
    _leftRightButtonsBackgroundColor = [leftRightButtonsBackgroundColor retain];
    [self.changedProperties addObject:@"leftRightButtonsBackgroundColor"];
    self.leftButtonLayer.backgroundFillColor = self.rightButtonLayer.backgroundFillColor = leftRightButtonsBackgroundColor.CGColor;
}

- (void)setLeftRightButtonsImageColor:(UIColor*)leftRightButtonsImageColor {
    [_leftRightButtonsImageColor release];
    _leftRightButtonsImageColor = [leftRightButtonsImageColor retain];
    [self.changedProperties addObject:@"leftRightButtonsImageColor"];
    ((EVResizableShapeLayer*)self.leftButtonLayer.imageLayer).fillColor = ((EVResizableShapeLayer*)self.rightButtonLayer.imageLayer).fillColor = _leftRightButtonsImageColor.CGColor;
}

- (void)setLeftRightButtonsBorderColor:(UIColor*)leftRightButtonsBorderColor {
    [_leftRightButtonsBorderColor release];
    _leftRightButtonsBorderColor = [leftRightButtonsBorderColor retain];
    [self.changedProperties addObject:@"leftRightButtonsBorderColor"];
    self.leftButtonLayer.borderLineColor = self.rightButtonLayer.borderLineColor = _leftRightButtonsBorderColor.CGColor;
}

- (void)setLeftRightButtonsBorderWidth:(CGFloat)leftRightButtonsBorderWidth {
    _leftRightButtonsBorderWidth = leftRightButtonsBorderWidth;
    self.leftButtonLayer.borderLineWidth = self.rightButtonLayer.borderLineWidth = _leftRightButtonsBorderWidth;
    [self.changedProperties addObject:@"leftRightButtonsBorderWidth"];
}

- (void)setLeftRightButtonsImageScale:(CGFloat)leftRightButtonsImageScale {
    _leftRightButtonsImageScale = leftRightButtonsImageScale;
    ((EVResizableShapeLayer*)self.leftButtonLayer.imageLayer).pathScale = ((EVResizableShapeLayer*)self.rightButtonLayer.imageLayer).pathScale = leftRightButtonsImageScale;
    [self.changedProperties addObject:@"leftRightButtonsImageScale"];
}


- (void)setLeftRightButtonsUnactiveBackgroundScale:(CGFloat)leftRightButtonsUnactiveBackgroundScale {
    _leftRightButtonsUnactiveBackgroundScale = leftRightButtonsUnactiveBackgroundScale;
    [self.changedProperties addObject:@"leftRightButtonsUnactiveBackgroundScale"];
    [self recalculateButtonBackgroundSize];
}

- (void)setLeftRightButtonsActiveBackgroundScale:(CGFloat)leftRightButtonsActiveBackgroundScale {
    _leftRightButtonsActiveBackgroundScale = leftRightButtonsActiveBackgroundScale;
    [self.changedProperties addObject:@"leftRightButtonsActiveBackgroundScale"];
    [self recalculateButtonBackgroundSize];
}

- (void)setLeftRightButtonsMaxImageScale:(CGFloat)leftRightButtonsMaxImageScale {
    _leftRightButtonsMaxImageScale = leftRightButtonsMaxImageScale;
    [self.changedProperties addObject:@"leftRightButtonsMaxImageScale"];
    [self recalculateButtonBackgroundSize];
}

- (void)setLeftRightButtonsMaxBackgroundScale:(CGFloat)leftRightButtonsMaxBackgroundScale {
    _leftRightButtonsMaxBackgroundScale = leftRightButtonsMaxBackgroundScale;
    [self.changedProperties addObject:@"leftRightButtonsMaxBackgroundScale"];
    [self recalculateButtonBackgroundSize];
}

- (void)setLeftRightButtonsOffset:(CGFloat)leftRightButtonsOffset {
    _leftRightButtonsOffset = leftRightButtonsOffset;
    [self.changedProperties addObject:@"leftRightButtonsOffset"];
    [self setupButtonPositions];
}

- (void)setCenterButtonMicShadowColor:(UIColor*)centerButtonMicShadowColor {
    [_centerButtonMicShadowColor release];
    _centerButtonMicShadowColor = [centerButtonMicShadowColor retain];
    [self.changedProperties addObject:@"centerButtonMicShadowColor"];
    self.micButtonLayer.imageLayer.shadowColor = centerButtonMicShadowColor.CGColor;
    if (![self.changedProperties containsObject:@"leftRightButtonsImageShadowColor"]) {
        [_leftRightButtonsImageShadowColor release];
        _leftRightButtonsImageShadowColor = [centerButtonMicShadowColor retain];
        self.leftButtonLayer.imageLayer.shadowColor = self.rightButtonLayer.imageLayer.shadowColor = _leftRightButtonsImageShadowColor.CGColor;
    }
}

- (void)setCenterButtonMicShadowOffset:(CGSize)centerButtonMicShadowOffset {
    _centerButtonMicShadowOffset = centerButtonMicShadowOffset;
    [self.changedProperties addObject:@"centerButtonMicShadowOffset"];
    self.micButtonLayer.imageLayer.shadowOffset = centerButtonMicShadowOffset;
    if (![self.changedProperties containsObject:@"leftRightButtonsImageShadowOffset"]) {
        _leftRightButtonsImageShadowOffset = centerButtonMicShadowOffset;
        self.leftButtonLayer.imageLayer.shadowOffset = self.rightButtonLayer.imageLayer.shadowOffset = centerButtonMicShadowOffset;
    }
}

- (void)setCenterButtonMicShadowRadius:(CGFloat)centerButtonMicShadowRadius {
    _centerButtonMicShadowRadius = centerButtonMicShadowRadius;
    [self.changedProperties addObject:@"centerButtonMicShadowRadius"];
    self.micButtonLayer.imageLayer.shadowRadius = centerButtonMicShadowRadius;
    if (![self.changedProperties containsObject:@"leftRightButtonsImageShadowRadius"]) {
        _leftRightButtonsImageShadowRadius = centerButtonMicShadowRadius;
        self.leftButtonLayer.imageLayer.shadowRadius = self.rightButtonLayer.imageLayer.shadowRadius = centerButtonMicShadowRadius;
    }
}

- (void)setCenterButtonMicShadowOpacity:(float)centerButtonMicShadowOpacity {
    _centerButtonMicShadowOpacity = centerButtonMicShadowOpacity;
    [self.changedProperties addObject:@"centerButtonMicShadowOpacity"];
    self.micButtonLayer.imageLayer.shadowOpacity = centerButtonMicShadowOpacity;
    if (![self.changedProperties containsObject:@"leftRightButtonsImageShadowOpacity"]) {
        _leftRightButtonsImageShadowOpacity = centerButtonMicShadowOpacity;
        self.leftButtonLayer.imageLayer.shadowOpacity = self.rightButtonLayer.imageLayer.shadowOpacity = centerButtonMicShadowOpacity;
    }
}

- (void)setCenterButtonBackgroundShadowColor:(UIColor*)centerButtonBackgroundShadowColor {
    [_centerButtonBackgroundShadowColor release];
    _centerButtonBackgroundShadowColor = [centerButtonBackgroundShadowColor retain];
    [self.changedProperties addObject:@"centerButtonBackgroundShadowColor"];
    self.micButtonLayer.backgroundLayer.shadowColor = centerButtonBackgroundShadowColor.CGColor;
    if (![self.changedProperties containsObject:@"leftRightButtonsBackgroundShadowColor"]) {
        [_leftRightButtonsBackgroundShadowColor release];
        _leftRightButtonsBackgroundShadowColor = [centerButtonBackgroundShadowColor retain];
        self.leftButtonLayer.backgroundLayer.shadowColor = self.rightButtonLayer.backgroundLayer.shadowColor = _leftRightButtonsBackgroundShadowColor.CGColor;
    }
}

- (void)setCenterButtonBackgroundShadowOffset:(CGSize)centerButtonBackgroundShadowOffset {
    _centerButtonBackgroundShadowOffset = centerButtonBackgroundShadowOffset;
    [self.changedProperties addObject:@"centerButtonBackgroundShadowOffset"];
    self.micButtonLayer.backgroundLayer.shadowOffset = centerButtonBackgroundShadowOffset;
    if (![self.changedProperties containsObject:@"leftRightButtonsBackgroundShadowOffset"]) {
        _leftRightButtonsBackgroundShadowOffset = centerButtonBackgroundShadowOffset;
        self.leftButtonLayer.backgroundLayer.shadowOffset = self.rightButtonLayer.backgroundLayer.shadowOffset = centerButtonBackgroundShadowOffset;
    }
}

- (void)setCenterButtonBackgroundShadowRadius:(CGFloat)centerButtonBackgroundShadowRadius {
    _centerButtonBackgroundShadowRadius = centerButtonBackgroundShadowRadius;
    [self.changedProperties addObject:@"centerButtonBackgroundShadowRadius"];
    self.micButtonLayer.backgroundLayer.shadowRadius = centerButtonBackgroundShadowRadius;
    if (![self.changedProperties containsObject:@"leftRightButtonsBackgroundShadowRadius"]) {
        _leftRightButtonsBackgroundShadowRadius = centerButtonBackgroundShadowRadius;
        self.leftButtonLayer.backgroundLayer.shadowRadius = self.rightButtonLayer.backgroundLayer.shadowRadius = centerButtonBackgroundShadowRadius;
    }
}

- (void)setCenterButtonBackgroundShadowOpacity:(float)centerButtonBackgroundShadowOpacity {
    _centerButtonBackgroundShadowOpacity = centerButtonBackgroundShadowOpacity;
    [self.changedProperties addObject:@"centerButtonBackgroundShadowOpacity"];
    self.micButtonLayer.backgroundLayer.shadowOpacity = centerButtonBackgroundShadowOpacity;
    if (![self.changedProperties containsObject:@"leftRightButtonsBackgroundShadowOpacity"]) {
        _leftRightButtonsBackgroundShadowOpacity = centerButtonBackgroundShadowOpacity;
        self.leftButtonLayer.backgroundLayer.shadowOpacity = self.rightButtonLayer.backgroundLayer.shadowOpacity = centerButtonBackgroundShadowOpacity;
    }
}

- (void)setLeftRightButtonsImageShadowColor:(UIColor*)leftRightButtonsImageShadowColor {
    [_leftRightButtonsImageShadowColor release];
    _leftRightButtonsImageShadowColor = [leftRightButtonsImageShadowColor retain];
    [self.changedProperties addObject:@"leftRightButtonsImageShadowColor"];
    self.leftButtonLayer.imageLayer.shadowColor = self.rightButtonLayer.imageLayer.shadowColor = leftRightButtonsImageShadowColor.CGColor;
}

- (void)setLeftRightButtonsImageShadowOffset:(CGSize)leftRightButtonsImageShadowOffset {
    _leftRightButtonsImageShadowOffset = leftRightButtonsImageShadowOffset;
    [self.changedProperties addObject:@"leftRightButtonsImageShadowOffset"];
    self.leftButtonLayer.imageLayer.shadowOffset = self.rightButtonLayer.imageLayer.shadowOffset = leftRightButtonsImageShadowOffset;
}

- (void)setLeftRightButtonsImageShadowRadius:(CGFloat)leftRightButtonsImageShadowRadius {
    _leftRightButtonsImageShadowRadius = leftRightButtonsImageShadowRadius;
    [self.changedProperties addObject:@"leftRightButtonsImageShadowRadius"];
    self.leftButtonLayer.imageLayer.shadowRadius = self.rightButtonLayer.imageLayer.shadowRadius = leftRightButtonsImageShadowRadius;
}

- (void)setLeftRightButtonsImageShadowOpacity:(float)leftRightButtonsImageShadowOpacity {
    _leftRightButtonsImageShadowOpacity = leftRightButtonsImageShadowOpacity;
    [self.changedProperties addObject:@"leftRightButtonsImageShadowOpacity"];
    self.leftButtonLayer.imageLayer.shadowOpacity = self.rightButtonLayer.imageLayer.shadowOpacity = leftRightButtonsImageShadowOpacity;
}

- (void)setLeftRightButtonsBackgroundShadowColor:(UIColor*)leftRightButtonsBackgroundShadowColor {
    [_leftRightButtonsBackgroundShadowColor release];
    _leftRightButtonsBackgroundShadowColor = [leftRightButtonsBackgroundShadowColor retain];
    [self.changedProperties addObject:@"leftRightButtonsBackgroundShadowColor"];
    self.leftButtonLayer.backgroundLayer.shadowColor = self.rightButtonLayer.backgroundLayer.shadowColor = leftRightButtonsBackgroundShadowColor.CGColor;
}

- (void)setLeftRightButtonsBackgroundShadowOffset:(CGSize)leftRightButtonsBackgroundShadowOffset {
    _leftRightButtonsBackgroundShadowOffset = leftRightButtonsBackgroundShadowOffset;
    [self.changedProperties addObject:@"leftRightButtonsBackgroundShadowOffset"];
    self.leftButtonLayer.backgroundLayer.shadowOffset = self.rightButtonLayer.backgroundLayer.shadowOffset = leftRightButtonsBackgroundShadowOffset;
}

- (void)setLeftRightButtonsBackgroundShadowRadius:(CGFloat)leftRightButtonsBackgroundShadowRadius {
    _leftRightButtonsBackgroundShadowRadius = leftRightButtonsBackgroundShadowRadius;
    [self.changedProperties addObject:@"leftRightButtonsBackgroundShadowRadius"];
    self.leftButtonLayer.backgroundLayer.shadowRadius = self.rightButtonLayer.backgroundLayer.shadowRadius = leftRightButtonsBackgroundShadowRadius;
}

- (void)setLeftRightButtonsBackgroundShadowOpacity:(float)leftRightButtonsBackgroundShadowOpacity {
    _leftRightButtonsBackgroundShadowOpacity = leftRightButtonsBackgroundShadowOpacity;
    [self.changedProperties addObject:@"leftRightButtonsBackgroundShadowOpacity"];
    self.leftButtonLayer.backgroundLayer.shadowOpacity = self.rightButtonLayer.backgroundLayer.shadowOpacity = leftRightButtonsBackgroundShadowOpacity;
}

@end
