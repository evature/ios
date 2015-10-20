//
//  EVChatToolbarView.h
//  EvaKit
//
//  Created by Yegor Popovych on 7/9/15.
//  Copyright (c) 2015 Evature. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EVChatToolbarContentView.h"

@class EVChatToolbarView;

@protocol EVChatToolbarViewDelegate <JSQMessagesInputToolbarDelegate>

- (void)messagesInputToolbar:(EVChatToolbarView *)toolbar
     didPressCenterBarButton:(UIButton *)sender;

- (void)messagesInputToolbar:(EVChatToolbarView *)toolbar centerButtonLongPressStarted:(UIButton*)sender;
- (void)messagesInputToolbar:(EVChatToolbarView *)toolbar centerButtonLongPressEnded:(UIButton*)sender;

@end

@interface EVChatToolbarView : JSQMessagesInputToolbar <EVChatToolbarContentViewTouchDelegate>

@property (nonatomic, assign) id<EVChatToolbarViewDelegate> delegate;

@end

