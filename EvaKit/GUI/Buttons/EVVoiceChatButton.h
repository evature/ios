//
//  EVVoiceChatButton.h
//  EvaKit
//
//  Created by Yegor Popovych on 7/2/15.
//  Copyright (c) 2015 Evature. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString* kEVVoiceChatButtonSettigsKey;

IB_DESIGNABLE
@interface EVVoiceChatButton : UIButton

//Connect controller for which Chat window will show. EVApplication will search for if it not connected.
@property (nonatomic, assign) IBOutlet UIViewController* connectedController;

// Button properties
@property (nonatomic, strong) IBInspectable UIColor *micLineColor;
@property (nonatomic, assign) IBInspectable CGFloat micLineWidth;
@property (nonatomic, strong) IBInspectable UIColor *micFillColor;
@property (nonatomic, assign) IBInspectable CGFloat micScaleFactor;

@property (nonatomic, strong) IBInspectable UIColor *borderLineColor;
@property (nonatomic, assign) IBInspectable CGFloat borderLineWidth;
@property (nonatomic, strong) IBInspectable UIColor *backgroundFillColor;

@property (nonatomic, strong) IBInspectable UIColor *highlightColor;

@property (nonatomic, assign) IBInspectable BOOL autoHide;

@property (nonatomic, assign) IBInspectable BOOL chatControllerStartRecordingOnShow;

// Chat View properties
@property (nonatomic, strong) IBInspectable UIColor *chatToolbarCenterButtonMicLineColor;
@property (nonatomic, assign) IBInspectable CGFloat chatToolbarCenterButtonMicLineWidth;
@property (nonatomic, strong) IBInspectable UIColor *chatToolbarCenterButtonMicColor;
@property (nonatomic, assign) IBInspectable CGFloat chatToolbarCenterButtonMicScale;
@property (nonatomic, strong) IBInspectable UIColor *chatToolbarCenterButtonBackgroundColor;
@property (nonatomic, strong) IBInspectable UIColor *chatToolbarCenterButtonBorderColor;
@property (nonatomic, strong) IBInspectable UIColor *chatToolbarCenterButtonHighlightColor;
@property (nonatomic, assign) IBInspectable CGFloat chatToolbarCenterButtonBorderWidth;
@property (nonatomic, assign) IBInspectable CGFloat chatToolbarCenterButtonSpinningBorderWidth;

@property (nonatomic, strong) IBInspectable UIColor *chatToolbarLeftRightButtonsBackgroundColor;
@property (nonatomic, strong) IBInspectable UIColor *chatToolbarLeftRightButtonsImageColor;
@property (nonatomic, strong) IBInspectable UIColor *chatToolbarLeftRightButtonsBorderColor;
@property (nonatomic, assign) IBInspectable CGFloat chatToolbarLeftRightButtonsBorderWidth;
@property (nonatomic, assign) IBInspectable CGFloat chatToolbarLeftRightButtonsImageScale;
@property (nonatomic, assign) IBInspectable CGFloat chatToolbarLeftRightButtonsUnactiveBackgroundScale;
@property (nonatomic, assign) IBInspectable CGFloat chatToolbarLeftRightButtonsActiveBackgroundScale;
@property (nonatomic, assign) IBInspectable CGFloat chatToolbarLeftRightButtonsMaxImageScale;
@property (nonatomic, assign) IBInspectable CGFloat chatToolbarLeftRightButtonsMaxBackgroundScale;

@property (nonatomic, assign) IBInspectable CGFloat chatToolbarLeftRightButtonsOffset;

@end


@interface EVVoiceChatButton (EVButtonPosition)

- (void)ev_removeAllConstraints;
- (void)ev_addSizeConstraints;
- (void)ev_pinToBottomCenteredWithOffset:(CGFloat)bottomOffset;
- (void)ev_pinToTopCenteredWithOffset:(CGFloat)topOffset;
- (void)ev_pinToBottomLeftCornerWithLeftOffset:(CGFloat)leftOffset andBottomOffset:(CGFloat)bottomOffset;
- (void)ev_pinToBottomRightCornerWithRightOffset:(CGFloat)rightOffset andBottomOffset:(CGFloat)bottomOffset;
- (void)ev_pinToEdge:(NSLayoutAttribute)attribute withOffset:(CGFloat)offset;

@end
