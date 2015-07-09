//
//  EVVoiceChatViewController.m
//  EvaKit
//
//  Created by Yegor Popovych on 7/8/15.
//  Copyright (c) 2015 Evature. All rights reserved.
//

#import "EVVoiceChatViewController.h"
#import "EVChatToolbarcontentView.h"

@implementation EVVoiceChatViewController


+ (UINib *)nib
{
    return [UINib nibWithNibName:NSStringFromClass([EVVoiceChatViewController class])
                          bundle:[NSBundle bundleForClass:[EVVoiceChatViewController class]]];
}

+ (instancetype)messagesViewController
{
    return [[[self class] alloc] initWithNibName:NSStringFromClass([EVVoiceChatViewController class])
                                          bundle:[NSBundle bundleForClass:[EVVoiceChatViewController class]]];
}


- (instancetype)init {
    self = [super init];
    if (self != nil) {
        self.senderId = @"eva";
        self.senderDisplayName = @"Eva";
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.collectionView.collectionViewLayout.incomingAvatarViewSize = CGSizeZero;
    self.collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero;
}

- (id<JSQMessageAvatarImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView avatarImageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

@end
