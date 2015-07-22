//
//  EVChatToolbarView.m
//  EvaKit
//
//  Created by Yegor Popovych on 7/9/15.
//  Copyright (c) 2015 Evature. All rights reserved.
//

#import "EVChatToolbarView.h"
#import "EVChatToolbarContentView.h"

#define BAR_HEIGHT_X1 48.0f

@implementation EVChatToolbarView

@dynamic delegate;

- (void)awakeFromNib {
    [super awakeFromNib];
    self.preferredDefaultHeight = BAR_HEIGHT_X1*[UIScreen mainScreen].scale;
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

@end
