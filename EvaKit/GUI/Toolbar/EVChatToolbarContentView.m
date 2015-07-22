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

#define BUTTON_MARGIN 8.0f
#define BUTTON_TOP_BOTTOM_MARGIN 8.0f

@interface EVChatToolbarContentView () {
    BOOL _buttonIsDragging;
}

@property (nonatomic, strong, readwrite) EVVoiceChatMicButtonLayer *micButtonLayer;
@property (nonatomic, strong, readwrite) EVSVGButtonWithCircleBackgroundLayer* leftButtonLayer;
@property (nonatomic, strong, readwrite) EVSVGButtonWithCircleBackgroundLayer* rightButtonLayer;
@property (nonatomic, strong, readwrite) NSMutableSet* changedProperties;

- (void)setupView;
- (void)recalculateButtonBackgroundSize;
- (void)setupButtonPositions;

@end

@implementation EVChatToolbarContentView


#pragma mark === Layers and View Setup and Calculations ===

- (void)setupView {
    UITapGestureRecognizer* tapRecognizer = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture:)] autorelease];
    tapRecognizer.numberOfTapsRequired = 1;
    [self addGestureRecognizer:tapRecognizer];
    
    UIPanGestureRecognizer* panRecognizer = [[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGesture:)] autorelease];
    panRecognizer.minimumNumberOfTouches = 1;
    panRecognizer.maximumNumberOfTouches = 1;
    [self addGestureRecognizer:panRecognizer];
    
    _buttonIsDragging = NO;
    
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
    
    [self.leftButtonLayer setImageFromSVGFile:[[NSBundle bundleForClass:[self class]] pathForResource:@"Undo" ofType:@"svg"]];
    [self.rightButtonLayer setImageFromSVGFile:[[NSBundle bundleForClass:[self class]] pathForResource:@"Trash" ofType:@"svg"]];
    
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
        
        _leftRightButtonsOffset = BUTTON_MARGIN * [UIScreen mainScreen].scale;
        
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
    self.changedProperties = nil;
    [super dealloc];
}



#pragma mark === Gesture recognizers for tap and drag ===

- (IBAction)tapGesture:(UIGestureRecognizer*)recognizer {
    CGPoint touchPoint = [recognizer locationInView:self];
    touchPoint = [self.layer convertPoint:touchPoint toLayer:self.layer.superlayer];
    CALayer* theLayer = [self.layer hitTest:touchPoint];
    if (theLayer == self.micButtonLayer) {
        if (recognizer.state == UIGestureRecognizerStateEnded) {
            [CATransaction begin];
            [[self micButtonLayer] released];
            [CATransaction commit];
            [self.touchDelegate centerButtonTouched:self];
        }
    }
}

- (IBAction)panGesture:(UIPanGestureRecognizer*)recognizer {
    CGPoint location = [recognizer locationInView:self];
    if (_buttonIsDragging) {
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
            if (CGRectIntersectsRect(self.micButtonLayer.frame, self.leftButtonLayer.frame)) {
                CGFloat intersect = (self.micButtonLayer.frame.origin.x - self.leftButtonLayer.frame.origin.x) / self.micButtonLayer.frame.size.width;
                if (intersect <= 0.2) {
                    [self.touchDelegate leftButtonTouched:self];
                }
            } else if (CGRectIntersectsRect(self.micButtonLayer.frame, self.rightButtonLayer.frame)) {
                CGFloat intersect = (self.rightButtonLayer.frame.origin.x - self.micButtonLayer.frame.origin.x) / self.micButtonLayer.frame.size.width;
                if (intersect <= 0.2) {
                    [self.touchDelegate rightButtonTouched:self];
                }
            }
            [CATransaction begin];
            EVSpringAnimation *animation = [EVSpringAnimation animationWithKeyPath:@"position.x"
                                                                          duration:0.5f
                                                            usingSpringWithDumping:0.8f
                                                                   initialVelocity:1.2f
                                                                         fromValue:self.micButtonLayer.position.x
                                                                           toValue:self.bounds.size.width/2.0f];
            [self.micButtonLayer addAnimation:animation forKey:@"PositionStringAnimation"];
            self.micButtonLayer.position = CGPointMake(self.bounds.size.width/2.0f, self.bounds.size.height/2.0f);
            [self.micButtonLayer released];
            [self.micButtonLayer showMic];
            [CATransaction commit];
            _buttonIsDragging = NO;
            [self recalculateButtonBackgroundSize];
        } else if (recognizer.state == UIGestureRecognizerStateBegan) {
            [self.micButtonLayer hideMic];
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
        }
    }
}


#pragma mark === Animation external methods ===

- (void)audioSessionStarted {
    [CATransaction begin];
    [CATransaction setCompletionBlock:^{
        [self.micButtonLayer audioSessionStarted];
    }];
    [self.micButtonLayer hideMic];
    [CATransaction commit];
    
}

- (void)audioSessionStoped {
    [CATransaction begin];
    [CATransaction setCompletionBlock:^{
        [self.micButtonLayer showMic];
    }];
    [self.micButtonLayer audioSessionStoped];
    [CATransaction commit];
}

- (void)startWaitAnimation {
    [self.micButtonLayer startSpinning];
}

- (void)stopWaitAnimation {
    [self.micButtonLayer stopSpinning];
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

@end
