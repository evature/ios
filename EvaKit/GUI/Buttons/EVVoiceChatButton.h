//
//  EVVoiceChatButton.h
//  EvaKit
//
//  Created by Yegor Popovych on 7/2/15.
//  Copyright (c) 2015 Evature. All rights reserved.
//

#import <UIKit/UIKit.h>

IB_DESIGNABLE
@interface EVVoiceChatButton : UIButton

// Button properties
@property (nonatomic, strong) IBInspectable UIColor *micLineColor;
@property (nonatomic, assign) IBInspectable CGFloat micLineWidth;
@property (nonatomic, strong) IBInspectable UIColor *micFillColor;
@property (nonatomic, assign) IBInspectable CGFloat micScaleFactor;

@property (nonatomic, strong) IBInspectable UIColor *borderLineColor;
@property (nonatomic, assign) IBInspectable CGFloat borderLineWidth;
@property (nonatomic, strong) IBInspectable UIColor *backgroundFillColor;

@property (nonatomic, strong) IBInspectable UIColor *highlightColor;


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
