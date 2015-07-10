//
//  EVVoiceChatOpenButton.h
//  EvaKit
//
//  Created by Yegor Popovych on 7/2/15.
//  Copyright (c) 2015 Evature. All rights reserved.
//

#import <UIKit/UIKit.h>

IB_DESIGNABLE
@interface EVVoiceChatOpenButton : UIButton

@property (nonatomic, retain) IBInspectable UIColor *micLineColor;
@property (nonatomic, assign) IBInspectable CGFloat micLineWidth;
@property (nonatomic, retain) IBInspectable UIColor *micFillColor;
@property (nonatomic, assign) IBInspectable CGFloat micScaleFactor;

@property (nonatomic, retain) IBInspectable UIColor *borderLineColor;
@property (nonatomic, assign) IBInspectable CGFloat borderLineWidth;
@property (nonatomic, retain) IBInspectable UIColor *backgroundColor;

@property (nonatomic, retain) IBInspectable UIColor *highlightColor;

@end
