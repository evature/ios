//
//  EVViewControllerVisibilityObserver.h
//  EvaKit
//
//  Created by Yegor Popovych on 7/23/15.
//  Copyright (c) 2015 Evature. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EVViewControllerVisibilityObserverDelegate.h"

@interface EVViewControllerVisibilityObserver : NSObject

@property (nonatomic, assign, readonly) UIViewController* controller;
@property (nonatomic, assign, readonly) id<EVViewControllerVisibilityObserverDelegate> delegate;

- (instancetype)initWithController:(UIViewController*)controller andDelegate:(id<EVViewControllerVisibilityObserverDelegate>)delegate;

@end
