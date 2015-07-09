//
//  EVApplication.m
//  EvaKit
//
//  Created by Yegor Popovych on 7/7/15.
//  Copyright (c) 2015 Evature. All rights reserved.
//

#import "EVApplication.h"
#import <UIKit/UIKit.h>
#import "EVVoiceChatViewController.h"

@implementation EVApplication

- (id)traverseResponderChainForUIViewControllerForView:(UIView*)view {
    id nextResponder = [view nextResponder];
    if ([nextResponder isKindOfClass:[UIViewController class]]) {
        return nextResponder;
    } else if ([nextResponder isKindOfClass:[UIView class]]) {
        return [self traverseResponderChainForUIViewControllerForView:nextResponder];
    } else {
        return nil;
    }
}

+ (instancetype)sharedApplication {
    static EVApplication* sharedInstance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedInstance = [[EVApplication alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self != nil) {
        self.chatViewControllerClass = [EVVoiceChatViewController class];
    }
    return self;
}


- (void)showChatViewController:(id)sender {
    UIViewController *ctrl = nil;
    if ([sender isKindOfClass:[UIViewController class]]) {
        ctrl = sender;
    } else if ([sender isKindOfClass:[UIView class]]) {
        ctrl = [self traverseResponderChainForUIViewControllerForView:sender];
    }
    [ctrl presentViewController:[[[self.chatViewControllerClass alloc] init] autorelease] animated:YES completion:^{
        NSLog(@"Finished");
    }];
    NSLog(@"Need show view controller");
}

@end
