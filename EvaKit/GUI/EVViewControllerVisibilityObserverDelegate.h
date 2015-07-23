//
//  EVViewControllerVisibilityObserverDelegate.h
//  EvaKit
//
//  Created by Yegor Popovych on 7/23/15.
//  Copyright (c) 2015 Evature. All rights reserved.
//

@protocol EVViewControllerVisibilityObserverDelegate <NSObject>

- (void)controllerWillShow:(UIViewController*)controller;
- (void)controllerDidHide:(UIViewController*)controller;
- (void)controllerWillRemove:(UIViewController*)controller;

@end
