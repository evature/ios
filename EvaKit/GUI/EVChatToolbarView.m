//
//  EVChatToolbarView.m
//  EvaKit
//
//  Created by Yegor Popovych on 7/9/15.
//  Copyright (c) 2015 Evature. All rights reserved.
//

#import "EVChatToolbarView.h"
#import "EVChatToolbarContentView.h"

@implementation EVChatToolbarView

- (JSQMessagesToolbarContentView *)loadToolbarContentView {
    return [[[EVChatToolbarContentView alloc] init] autorelease];
}

@end
