//
//  EVCallbackResponse.m
//  EvaKit
//
//  Created by Yegor Popovych on 10/28/15.
//  Copyright © 2015 Evature. All rights reserved.
//

#import "EVCallbackResponse.h"

@interface EVCallbackResponse () {
    EVCallbackResponseType _type;
}

@property (nonatomic, copy) id data;

- (instancetype)initWithType:(EVCallbackResponseType)type andData:(id)data;

@end

@implementation EVCallbackResponse

+ (instancetype)repsonseWithPromise:(RXPromise*)promise {
    return [[[self alloc] initWithType:EVCallbackResponseTypePromise andData:promise] autorelease];
}

+ (instancetype)responseWithBool:(BOOL)boolValue {
    return [[[self alloc] initWithType:EVCallbackResponseTypeBool andData:[NSNumber numberWithBool:boolValue]] autorelease];
}

+ (instancetype)responseWithString:(EVStyledString*)stringValue {
    return [[[self alloc] initWithType:EVCallbackResponseTypeString andData:stringValue] autorelease];
}

+ (instancetype)responseWithResponseData:(EVCallbackResponseData*)responseData {
    return [[[self alloc] initWithType:EVCallbackResponseTypeData andData:responseData] autorelease];
}

+ (instancetype)responseWithNone {
    return [[[self alloc] initWithType:EVCallbackResponseTypeNone andData:nil] autorelease];
}

+ (instancetype)responseWithCloseChatAction {
    return [[[self alloc] initWithType:EVCallbackResponseTypeCloseChatAction andData:nil] autorelease];
}

- (instancetype)initWithType:(EVCallbackResponseType)type andData:(id)data {
    self = [super init];
    if (self != nil) {
        _type = type;
        self.data = data;
    }
    return self;
}

- (void)dealloc {
    self.data = nil;
    [super dealloc];
}

- (EVCallbackResponseType)responseType {
    return _type;
}

- (BOOL)boolValue {
    if (_type != EVCallbackResponseTypeBool && _type != EVCallbackResponseTypeNone) {
        @throw [NSException exceptionWithName:@"EVCallbackResponseWrongType" reason:@"Can't get BOOL from Response" userInfo:@{@"EVCallbackResponse": self}];
    }
    return [self.data boolValue];
}

- (EVStyledString*)stringValue {
    switch (_type) {
        case EVCallbackResponseTypeBool:
            return [EVStyledString styledStringWithString:[self.data description]];
            break;
        case EVCallbackResponseTypeString:
            return self.data;
            break;
        default:
            @throw [NSException exceptionWithName:@"EVCallbackResponseWrongType" reason:@"Can't get NSString from Response" userInfo:@{@"EVCallbackResponse": self}];
            break;
    }
    return nil;
}

- (BOOL)isNone {
    return _type == EVCallbackResponseTypeNone;
}

- (BOOL)isCloseChatAction {
    return _type == EVCallbackResponseTypeCloseChatAction;
}

- (EVCallbackResponseData*)responseDataValue {
    if (_type != EVCallbackResponseTypeData) {
        @throw [NSException exceptionWithName:@"EVCallbackResponseWrongType" reason:@"Can't get Data from Response" userInfo:@{@"EVCallbackResponse": self}];
    }
    return self.data;
}

- (RXPromise*)promiseValue {
    if (_type != EVCallbackResponseTypePromise) {
        @throw [NSException exceptionWithName:@"EVCallbackResponseWrongType" reason:@"Can't get Promise from Response" userInfo:@{@"EVCallbackResponse": self}];
    }
    return self.data;
}

@end

@implementation EVCallbackResponseData

+ (instancetype)responseData {
    return [[[self alloc] init] autorelease];
}

- (void)dealloc {
    self.sayIt = nil;
    self.displayIt = nil;
    [super dealloc];
}

@end
