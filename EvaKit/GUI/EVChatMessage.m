//
//  EVChatMessage.m
//  EvaKit
//
//  Created by Yegor Popovych on 8/27/15.
//  Copyright (c) 2015 Evature. All rights reserved.
//

#import "EVChatMessage.h"

NSString* const kSenderIdMe = @"me";
NSString* const kSenderDisplayNameMe = @"Me";
NSString* const kSenderIdEva = @"eva";
NSString* const kSenderDisplayNameEva = @"Eva";

@implementation EVChatMessage

+ (instancetype)serverMessageWithText:(NSString *)text {
    return [super messageWithSenderId:kSenderIdEva displayName:kSenderDisplayNameEva text:text];
}

+ (instancetype)clientMessageWithText:(NSString *)text {
    return [super messageWithSenderId:kSenderIdMe displayName:kSenderDisplayNameMe text:text];
}

+ (instancetype)serverMessageWithMedia:(id<JSQMessageMediaData>)media {
    return [super messageWithSenderId:kSenderIdEva displayName:kSenderDisplayNameEva media:media];
}

+ (instancetype)clientMessageWithMedia:(id<JSQMessageMediaData>)media {
    return [super messageWithSenderId:kSenderIdMe displayName:kSenderDisplayNameMe media:media];
}

- (BOOL)isServerMessage {
    return [self.senderId isEqualToString:kSenderIdEva];
}

+ (NSString*)serverID {
    return kSenderIdEva;
}

+ (NSString*)clientID {
    return kSenderIdMe;
}

+ (NSString*)clientDisplayName {
    return kSenderDisplayNameMe;
}

@end
