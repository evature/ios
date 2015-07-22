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

@interface EVApplication ()

@property (nonatomic, strong, readwrite) NSMutableDictionary* chatViewControllerPathRewrites;

@end

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
        self.chatViewControllerPathRewrites = [NSMutableDictionary dictionary];
        [self.chatViewControllerPathRewrites setObject:@"inputToolbar.contentView." forKey:@"toolbar."];
    }
    return self;
}


- (void)showChatViewController:(id)sender withViewSettings:(NSDictionary*)viewSettings {
    UIViewController *ctrl = nil;
    if ([sender isKindOfClass:[UIViewController class]]) {
        ctrl = sender;
    } else if ([sender isKindOfClass:[UIView class]]) {
        ctrl = [self traverseResponderChainForUIViewControllerForView:sender];
    }
    EVVoiceChatViewController* viewCtrl = [[[self.chatViewControllerClass alloc] init] autorelease];
    viewCtrl.openButton = sender;
    [viewCtrl updateViewFromSettings:viewSettings];
    [ctrl presentViewController:viewCtrl animated:YES completion:^{
        NSLog(@"Finished");
    }];
}

@end
