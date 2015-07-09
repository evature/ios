//
//  EVChatToolbarView.m
//  EvaKit
//
//  Created by Yegor Popovych on 7/9/15.
//  Copyright (c) 2015 Evature. All rights reserved.
//

#import "EVChatToolbarContentView.h"

@implementation EVChatToolbarContentView

- (void)awakeFromNib {
    [super awakeFromNib];
//    [self.textView removeFromSuperview];
//    [self setValue:nil forKey:@"textView"];
    self.leftBarButtonItem = nil;
    self.rightBarButtonItem = nil;
    [self.leftBarButtonContainerView removeFromSuperview];
    [self.rightBarButtonContainerView removeFromSuperview];
    [self setValue:nil forKey:@"leftBarButtonContainerView"];
    [self setValue:nil forKey:@"rightBarButtonContainerView"];
}

@end
