//
//  EVChatMessage.h
//  EvaKit
//
//  Created by Yegor Popovych on 8/27/15.
//  Copyright (c) 2015 Evature. All rights reserved.
//

#import <JSQMessagesViewController/JSQMessages.h>
#import "EVSearchModel.h"

@interface EVChatMessage : JSQMessage

@property (nonatomic, strong, readwrite) EVSearchModel* searchModel;

+ (instancetype)serverMessageWithID:(NSString*)messageID text:(NSString *)text;
+ (instancetype)clientMessageWithText:(NSString *)text;

+ (instancetype)serverMessageWithID:(NSString*)messageID media:(id<JSQMessageMediaData>)media;
+ (instancetype)clientMessageWithMedia:(id<JSQMessageMediaData>)media;

+ (NSString*)clientID;
+ (NSString*)clientDisplayName;

- (BOOL)isClientMessage;

@end
