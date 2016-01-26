//
//  EVCallbackResult.m
//  EvaKit
//
//  Created by Yegor Popovych on 10/28/15.
//  Copyright © 2015 Evature. All rights reserved.
//

#import "EVCallbackResult.h"

@interface EVCallbackResult () {
    EVCallbackResultType _type;
}

@property (nonatomic, copy) id data;

- (instancetype)initWithType:(EVCallbackResultType)type andData:(id)data;

@end

@implementation EVCallbackResult

+ (instancetype)resultWithPromise:(RXPromise*)promise {
    return [[[self alloc] initWithType:EVCallbackResultTypePromise andData:promise] autorelease];
}

+ (instancetype)resultWithBool:(BOOL)boolValue {
    return [[[self alloc] initWithType:EVCallbackResultTypeBool andData:[NSNumber numberWithBool:boolValue]] autorelease];
}

+ (instancetype)resultWithString:(EVStyledString*)stringValue {
    return [[[self alloc] initWithType:EVCallbackResultTypeString andData:stringValue] autorelease];
}

+ (instancetype)resultWithResultData:(EVCallbackResultData*)resultData {
    return [[[self alloc] initWithType:EVCallbackResultTypeData andData:resultData] autorelease];
}

+ (instancetype)resultWithNone {
    return [[[self alloc] initWithType:EVCallbackResultTypeNone andData:nil] autorelease];
}

+ (instancetype)resultWithCloseChatAction {
    return [[[self alloc] initWithType:EVCallbackResultTypeCloseChatAction andData:nil] autorelease];
}

- (instancetype)initWithType:(EVCallbackResultType)type andData:(id)data {
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

- (EVCallbackResultType)resultType {
    return _type;
}

- (BOOL)boolValue {
    if (_type != EVCallbackResultTypeBool && _type != EVCallbackResultTypeNone) {
        @throw [NSException exceptionWithName:@"EVCallbackResultWrongType" reason:@"Can't get BOOL from Response" userInfo:@{@"EVCallbackResult": self}];
    }
    return _type == EVCallbackResultTypeNone || [self.data boolValue];
}

- (EVStyledString*)stringValue {
    switch (_type) {
        case EVCallbackResultTypeBool:
            return [EVStyledString styledStringWithString:[self.data description]];
            break;
        case EVCallbackResultTypeString:
            return self.data;
            break;
        default:
            @throw [NSException exceptionWithName:@"EVCallbackResultWrongType" reason:@"Can't get NSString from Response" userInfo:@{@"EVCallbackResult": self}];
            break;
    }
    return nil;
}


- (BOOL)isNone {
    return _type == EVCallbackResultTypeNone;
}

- (BOOL)isCloseChatAction {
    return _type == EVCallbackResultTypeCloseChatAction;
}

- (EVCallbackResultData*)resultDataValue {
    if (_type != EVCallbackResultTypeData) {
        @throw [NSException exceptionWithName:@"EVCallbackResultWrongType" reason:@"Can't get Data from Response" userInfo:@{@"EVCallbackResult": self}];
    }
    return self.data;
}

- (RXPromise*)promiseValue {
    if (_type != EVCallbackResultTypePromise) {
        @throw [NSException exceptionWithName:@"EVCallbackResultWrongType" reason:@"Can't get Promise from Response" userInfo:@{@"EVCallbackResult": self}];
    }
    return self.data;
}

@end

@implementation EVCallbackResultData

+ (instancetype)resultData {
    return [[[self alloc] init] autorelease];
}

-(id)copyWithZone:(NSZone*)zone {
    EVCallbackResultData *copy = [[[self class] allocWithZone: zone] init];
    copy.sayIt = self.sayIt;
    copy.displayIt = self.displayIt;
    copy.appendToEvaSayIt = self.appendToEvaSayIt;
    return copy;
}


- (void)dealloc {
    self.sayIt = nil;
    self.displayIt = nil;
    [super dealloc];
}

@end
