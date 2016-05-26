//
//  EVChatMessage.h
//  EvaKit
//
//  Created by Yegor Popovych on 8/27/15.
//  Copyright (c) 2015 Evature. All rights reserved.
//

#import <JSQMessages/JSQMessages.h>
#import "EVSearchModel.h"
#import "EVStyledString.h"

@interface EVChatMessage : JSQMessage

//@property (nonatomic, strong, readwrite) EVSearchModel* searchModel;
@property (nonatomic, strong, readwrite) EVStyledString* styledText;

+ (instancetype)serverMessageWithID:(NSString*)messageID text:(EVStyledString*)text;
+ (instancetype)clientMessageWithText:(EVStyledString*)text;

+ (instancetype)serverMessageWithID:(NSString*)messageID media:(id<JSQMessageMediaData>)media;
+ (instancetype)clientMessageWithMedia:(id<JSQMessageMediaData>)media;

+ (NSString*)clientID;
+ (NSString*)clientDisplayName;

- (BOOL)isClientMessage;

@end
