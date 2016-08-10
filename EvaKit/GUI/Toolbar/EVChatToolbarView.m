//
//  EVChatToolbarView.m
//  EvaKit
//
//  Created by Yegor Popovych on 7/9/15.
//  Copyright (c) 2015 Evature. All rights reserved.
//

#import "EVChatToolbarView.h"
#import "EVChatToolbarContentView.h"
#import "UIView+SizeCalculations.h"

#define BAR_HEIGHT_X1 48.0f

@implementation EVChatToolbarView

@dynamic delegate;

- (void)awakeFromNib {
    [super awakeFromNib];
//    NSLog(@"Scale: %lf", [UIScreen mainScreen].scale);
    self.preferredDefaultHeight = [self recalculateSizeForDeviceFrom1xSize:BAR_HEIGHT_X1];
    [(EVChatToolbarContentView*)self.contentView setTouchDelegate:self];
}

- (JSQMessagesToolbarContentView *)loadToolbarContentView {
    return [[[EVChatToolbarContentView alloc] init] autorelease];
}

- (void)leftButtonTouched:(EVChatToolbarContentView*)toolbarContentView {
    [self.delegate messagesInputToolbar:self didPressLeftBarButton:nil];
}

- (void)centerButtonTouched:(EVChatToolbarContentView*)toolbarContentView {
    [self.delegate messagesInputToolbar:self didPressCenterBarButton:nil];
}

- (void)rightButtonTouched:(EVChatToolbarContentView*)toolbarContentView {
    [self.delegate messagesInputToolbar:self didPressRightBarButton:nil];
    
}

- (void)centerButtonLongPressStarted:(EVChatToolbarContentView*)toolbarContentView {
    [self.delegate messagesInputToolbar:self centerButtonLongPressStarted:nil];
    
}

- (void)centerButtonLongPressEnded:(EVChatToolbarContentView*)toolbarContentView {
    [self.delegate messagesInputToolbar:self centerButtonLongPressEnded:nil];
}

@end
