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
#import "EVApplicationDelegate.h"

@interface EVVoiceChatViewController : JSQMessagesViewController <EVChatToolbarViewDelegate, EVApplicationDelegate>

@property (assign, nonatomic) IBOutlet NSLayoutConstraint *toolbarHeightConstraint;
@property (assign, nonatomic) IBOutlet NSLayoutConstraint *toolbarBottomLayoutGuide;
@property (assign, nonatomic) IBOutlet NSLayoutConstraint *topBarSizeConstraint;
@property (assign, nonatomic) IBOutlet NSLayoutConstraint *topBarTopConstraint;

@property (assign, nonatomic) BOOL startRecordingOnShow;

@property (nonatomic, strong) JSQMessagesBubbleImage* outgoingBubbleImage;
@property (nonatomic, strong) JSQMessagesBubbleImage* incomingBubbleImage;

@property (nonatomic, assign) EVVoiceChatButton* openButton;
@property (nonatomic, assign) EVApplication* evApplication;

- (IBAction)hideChatView:(id)sender;

- (void)updateViewFromSettings:(NSDictionary*)settings;

- (BOOL)isMyMessageInRow:(NSInteger)row;

@end
