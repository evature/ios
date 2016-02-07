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

+ (instancetype)serverMessageWithID:(NSString*)messageID text:(id)text {
    //return [self messageWithSenderId:messageID displayName:kSenderDisplayNameEva text:text];
    return [[[self alloc] initWithSenderId:messageID senderDisplayName:kSenderDisplayNameEva date:[NSDate date] text:text] autorelease];
}

+ (instancetype)clientMessageWithText:(id)text {
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
                            text:(id)text {
    self = [super initWithSenderId:senderId senderDisplayName:senderDisplayName date:date text:[(EVStyledString*)text string]];
    if (self != nil) {
        self.styledText = text;
        if (senderDisplayName == kSenderDisplayNameEva) {
            if (self.styledText.hasStyle) {
                NSAttributedString *orig = [self.styledText attributedString];
                UIColor* EV_EVA_TEXT_COLOR = [UIColor colorWithRed:0.96f green:0.96f blue:0.96f alpha:1.0f]; // TODO: use same constant
                NSMutableAttributedString *str = [[[NSMutableAttributedString alloc] initWithString:[orig string] attributes:@{NSForegroundColorAttributeName:EV_EVA_TEXT_COLOR}] autorelease];

                
                [orig enumerateAttributesInRange:NSMakeRange(0, [orig length]) options:NSAttributedStringEnumerationLongestEffectiveRangeNotRequired usingBlock:^(NSDictionary *attributes, NSRange range, BOOL *stop) {
                    [str addAttributes:attributes range:range];
                }];
                
                self.styledText = [EVStyledString styledStringWithAttributedString:str];
            }
        }

    }
    return self;
}

- (instancetype)initWithSenderId:(NSString *)senderId
               senderDisplayName:(NSString *)senderDisplayName
                            date:(NSDate *)date
                           media:(id<JSQMessageMediaData>)media {
    self = [super initWithSenderId:senderId senderDisplayName:senderDisplayName date:date media:media];
    if (self != nil) {
        self.styledText = nil;
    }
    return self;
}

- (void)dealloc {
//    self.searchModel = nil;
    self.styledText = nil;
    [super dealloc];
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
