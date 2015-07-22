//
//  EVVoiceChatViewController.h
//  EvaKit
//
//  Created by Yegor Popovych on 7/8/15.
//  Copyright (c) 2015 Evature. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EVChatToolbarView.h"
#import "EVVoiceChatButton.h"

@interface EVVoiceChatViewController : JSQMessagesViewController <EVChatToolbarViewDelegate>

@property (assign, nonatomic) IBOutlet NSLayoutConstraint *toolbarHeightConstraint;
@property (assign, nonatomic) IBOutlet NSLayoutConstraint *toolbarBottomLayoutGuide;
@property (assign, nonatomic) IBOutlet NSLayoutConstraint *topBarSizeConstraint;
@property (assign, nonatomic) IBOutlet NSLayoutConstraint *topBarTopConstraint;


@property (nonatomic, strong) JSQMessagesBubbleImage* outgoingBubbleImage;
@property (nonatomic, strong) JSQMessagesBubbleImage* incomingBubbleImage;

@property (nonatomic, assign) EVVoiceChatButton* openButton;

- (IBAction)hideChatView:(id)sender;

- (void)updateViewFromSettings:(NSDictionary*)settings;

@end
