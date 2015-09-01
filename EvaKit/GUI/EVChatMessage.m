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
NSString* const kSenderDisplayNameEva = @"Eva";

@implementation EVChatMessage

+ (instancetype)serverMessageWithID:(NSString*)messageID text:(NSString *)text {
    //return [self messageWithSenderId:messageID displayName:kSenderDisplayNameEva text:text];
    return [[[self alloc] initWithSenderId:messageID senderDisplayName:kSenderDisplayNameEva date:[NSDate date] text:text] autorelease];
}

+ (instancetype)clientMessageWithText:(NSString *)text {
    return [[[self alloc] initWithSenderId:kSenderIdMe senderDisplayName:kSenderDisplayNameMe date:[NSDate date] text:text] autorelease];
}

+ (instancetype)serverMessageWithID:(NSString*)messageID media:(id<JSQMessageMediaData>)media {
    return [[[self alloc] initWithSenderId:messageID senderDisplayName:kSenderDisplayNameEva date:[NSDate date] media:media] autorelease];
    //return [self messageWithSenderId:messageID displayName:kSenderDisplayNameEva media:media];
}

+ (instancetype)clientMessageWithMedia:(id<JSQMessageMediaData>)media {
    return [[[self alloc] initWithSenderId:kSenderIdMe senderDisplayName:kSenderDisplayNameMe date:[NSDate date] media:media] autorelease];
    //return [self messageWithSenderId:kSenderIdMe displayName:kSenderDisplayNameMe media:media];
}

- (instancetype)initWithSenderId:(NSString *)senderId
               senderDisplayName:(NSString *)senderDisplayName
                            date:(NSDate *)date
                            text:(NSString *)text {
    return [super initWithSenderId:senderId senderDisplayName:senderDisplayName date:date text:text];
}

- (instancetype)initWithSenderId:(NSString *)senderId
               senderDisplayName:(NSString *)senderDisplayName
                            date:(NSDate *)date
                           media:(id<JSQMessageMediaData>)media {
    return [super initWithSenderId:senderId senderDisplayName:senderDisplayName date:date media:media];
}

- (BOOL)isClientMessage {
    return [self.senderId isEqualToString:kSenderIdMe];
}

+ (NSString*)clientID {
    return kSenderIdMe;
}

+ (NSString*)clientDisplayName {
    return kSenderDisplayNameMe;
}

@end
