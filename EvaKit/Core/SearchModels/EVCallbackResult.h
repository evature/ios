//
//  EVCallbackResult.h
//  EvaKit
//
//  Created by Yegor Popovych on 10/28/15.
//  Copyright © 2015 Evature. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RXPromise/RXPromise.h>
#import "EVStyledString.h"


typedef NS_ENUM(int16_t, EVCallbackResultType) {
    EVCallbackResultTypeNone = 0,
    EVCallbackResultTypeBool,
    EVCallbackResultTypeString,
    EVCallbackResultTypeData,
    EVCallbackResultTypePromise,
    EVCallbackResultTypeCloseChatAction
};

@interface EVCallbackResultData : NSObject

@property (nonatomic, strong) NSString* sayIt;
@property (nonatomic, strong) EVStyledString* displayIt;
//@property (nonatomic, assign) NSInteger resultsCount;
@property (nonatomic, assign) BOOL appendToEvaSayIt;

+ (instancetype)resultData;

-(id)copyWithZone:(NSZone*)zone;


@end

@interface EVCallbackResult : NSObject

+ (instancetype)resultWithPromise:(RXPromise*)promise;
+ (instancetype)resultWithBool:(BOOL)boolValue;
+ (instancetype)resultWithString:(EVStyledString*)stringValue;
+ (instancetype)resultWithResultData:(EVCallbackResultData*)resultData;
+ (instancetype)resultWithNone;
+ (instancetype)resultWithCloseChatAction;

- (EVCallbackResultType)resultType;

- (BOOL)boolValue;
- (EVStyledString*)stringValue;
- (RXPromise*)promiseValue;
- (EVCallbackResultData*)resultDataValue;
- (BOOL)isNone;
- (BOOL)isCloseChatAction;

@end
