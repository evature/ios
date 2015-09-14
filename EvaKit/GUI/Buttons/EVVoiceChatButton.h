//
//  EVVoiceChatButton.h
//  EvaKit
//
//  Created by Yegor Popovych on 7/2/15.
//  Copyright (c) 2015 Evature. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EVViewControllerVisibilityObserverDelegate.h"

IB_DESIGNABLE
@interface EVVoiceChatButton : UIButton <EVViewControllerVisibilityObserverDelegate>

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

@property (nonatomic, strong) IBInspectable UIColor *micShadowColor;
@property (nonatomic, assign) IBInspectable CGSize micShadowOffset;
@property (nonatomic, assign) IBInspectable CGFloat micShadowRadius;
@property (nonatomic, assign) IBInspectable float micShadowOpacity;


@property (nonatomic, strong) IBInspectable UIColor *backgroundShadowColor;
@property (nonatomic, assign) IBInspectable CGSize backgroundShadowOffset;
@property (nonatomic, assign) IBInspectable CGFloat backgroundShadowRadius;
@property (nonatomic, assign) IBInspectable float backgroundShadowOpacity;

@property (nonatomic, assign) IBInspectable BOOL autoHide;
@property (nonatomic, assign) IBInspectable BOOL chatControllerStartRecordingOnShow;
@property (nonatomic, assign) IBInspectable BOOL chatControllerSemanticHighlightingEnabled;
@property (nonatomic, assign) IBInspectable BOOL chatControllerSemanticHighlightTimes;
@property (nonatomic, assign) IBInspectable BOOL chatControllerSemanticHighlightLocations;

// Chat View properties
@property (nonatomic, assign) IBInspectable UIColor *chatToolbarCenterButtonMicLineColor;
@property (nonatomic, assign) IBInspectable CGFloat chatToolbarCenterButtonMicLineWidth;
@property (nonatomic, assign) IBInspectable UIColor *chatToolbarCenterButtonMicColor;
@property (nonatomic, assign) IBInspectable CGFloat chatToolbarCenterButtonMicScale;
@property (nonatomic, assign) IBInspectable UIColor *chatToolbarCenterButtonBackgroundColor;
@property (nonatomic, assign) IBInspectable UIColor *chatToolbarCenterButtonBorderColor;
@property (nonatomic, assign) IBInspectable UIColor *chatToolbarCenterButtonHighlightColor;
@property (nonatomic, assign) IBInspectable CGFloat chatToolbarCenterButtonBorderWidth;
@property (nonatomic, assign) IBInspectable CGFloat chatToolbarCenterButtonSpinningBorderWidth;

@property (nonatomic, assign) IBInspectable UIColor *chatToolbarCenterButtonMicShadowColor;
@property (nonatomic, assign) IBInspectable CGSize chatToolbarCenterButtonMicShadowOffset;
@property (nonatomic, assign) IBInspectable CGFloat chatToolbarCenterButtonMicShadowRadius;
@property (nonatomic, assign) IBInspectable float chatToolbarCenterButtonMicShadowOpacity;
@property (nonatomic, assign) IBInspectable UIColor *chatToolbarCenterButtonBackgroundShadowColor;
@property (nonatomic, assign) IBInspectable CGSize chatToolbarCenterButtonBackgroundShadowOffset;
@property (nonatomic, assign) IBInspectable CGFloat chatToolbarCenterButtonBackgroundShadowRadius;
@property (nonatomic, assign) IBInspectable float chatToolbarCenterButtonBackgroundShadowOpacity;

@property (nonatomic, assign) IBInspectable UIColor *chatToolbarLeftRightButtonsBackgroundColor;
@property (nonatomic, assign) IBInspectable UIColor *chatToolbarLeftRightButtonsImageColor;
@property (nonatomic, assign) IBInspectable UIColor *chatToolbarLeftRightButtonsBorderColor;
@property (nonatomic, assign) IBInspectable CGFloat chatToolbarLeftRightButtonsBorderWidth;
@property (nonatomic, assign) IBInspectable CGFloat chatToolbarLeftRightButtonsImageScale;
@property (nonatomic, assign) IBInspectable CGFloat chatToolbarLeftRightButtonsUnactiveBackgroundScale;
@property (nonatomic, assign) IBInspectable CGFloat chatToolbarLeftRightButtonsActiveBackgroundScale;
@property (nonatomic, assign) IBInspectable CGFloat chatToolbarLeftRightButtonsMaxImageScale;
@property (nonatomic, assign) IBInspectable CGFloat chatToolbarLeftRightButtonsMaxBackgroundScale;

@property (nonatomic, assign) IBInspectable UIColor *chatToolbarLeftRightButtonsImageShadowColor;
@property (nonatomic, assign) IBInspectable CGSize chatToolbarLeftRightButtonsImageShadowOffset;
@property (nonatomic, assign) IBInspectable CGFloat chatToolbarLeftRightButtonsImageShadowRadius;
@property (nonatomic, assign) IBInspectable float chatToolbarLeftRightButtonsImageShadowOpacity;
@property (nonatomic, assign) IBInspectable UIColor *chatToolbarLeftRightButtonsBackgroundShadowColor;
@property (nonatomic, assign) IBInspectable CGSize chatToolbarLeftRightButtonsBackgroundShadowOffset;
@property (nonatomic, assign) IBInspectable CGFloat chatToolbarLeftRightButtonsBackgroundShadowRadius;
@property (nonatomic, assign) IBInspectable float chatToolbarLeftRightButtonsBackgroundShadowOpacity;

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
