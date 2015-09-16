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
#import "EVSearchDelegate.h"

@interface EVVoiceChatViewController : JSQMessagesViewController <EVChatToolbarViewDelegate, EVApplicationDelegate>

@property (assign, nonatomic) IBOutlet NSLayoutConstraint *toolbarHeightConstraint;
@property (assign, nonatomic) IBOutlet NSLayoutConstraint *toolbarBottomLayoutGuide;
@property (assign, nonatomic) IBOutlet NSLayoutConstraint *topBarSizeConstraint;
@property (assign, nonatomic) IBOutlet NSLayoutConstraint *topBarTopConstraint;


// This options can be set from Button or Settings Dictionary
@property (assign, nonatomic) BOOL startRecordingOnShow;
@property (assign, nonatomic) BOOL speakEnabled;
@property (assign, nonatomic) BOOL semanticHighlightingEnabled;
@property (assign, nonatomic) BOOL semanticHighlightTimes;
@property (assign, nonatomic) BOOL semanticHighlightLocations;
@property (nonatomic, assign) id<EVSearchDelegate> delegate;
// End of options

@property (nonatomic, strong) JSQMessagesBubbleImage* outgoingBubbleImage;
@property (nonatomic, strong) JSQMessagesBubbleImage* incomingBubbleImage;

@property (nonatomic, assign) EVApplication* evApplication;

- (IBAction)hideChatView:(id)sender;

- (void)updateViewFromSettings:(NSDictionary*)settings;

- (BOOL)isMyMessageInRow:(NSInteger)row;

@end
