//
//  EVCallbackResponse.h
//  EvaKit
//
//  Created by Yegor Popovych on 10/28/15.
//  Copyright © 2015 Evature. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RXPromise/RXPromise.h>
#import "EVStyledString.h"


typedef NS_ENUM(int16_t, EVCallbackResponseType) {
    EVCallbackResponseTypeNone = 0,
    EVCallbackResponseTypeBool,
    EVCallbackResponseTypeString,
    EVCallbackResponseTypeData,
    EVCallbackResponseTypePromise,
    EVCallbackResponseTypeCloseChatAction
};

@interface EVCallbackResponseData : NSObject

@property (nonatomic, strong) EVStyledString* sayIt;
@property (nonatomic, strong) EVStyledString* displayIt;
@property (nonatomic, assign) NSInteger resultsCount;
@property (nonatomic, assign) BOOL appendToEvaSayIt;

+ (instancetype)responseData;

@end

@interface EVCallbackResponse : NSObject

+ (instancetype)repsonseWithPromise:(RXPromise*)promise;
+ (instancetype)responseWithBool:(BOOL)boolValue;
+ (instancetype)responseWithString:(EVStyledString*)stringValue;
+ (instancetype)responseWithResponseData:(EVCallbackResponseData*)responseData;
+ (instancetype)responseWithNone;
+ (instancetype)responseWithCloseChatAction;

- (EVCallbackResponseType)responseType;

- (BOOL)boolValue;
- (EVStyledString*)stringValue;
- (RXPromise*)promiseValue;
- (EVCallbackResponseData*)responseDataValue;
- (BOOL)isNone;
- (BOOL)isCloseChatAction;

@end
