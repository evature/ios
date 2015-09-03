//
//  EVMoney.h
//  EvaKit
//
//  Created by Yegor Popovych on 8/11/15.
//  Copyright (c) 2015 Evature. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EVBool.h"

typedef NS_ENUM(int16_t, EVMoneyRestictionType) {
    EVMoneyRestictionTypeUnknown = -1,
    EVMoneyRestictionTypeLess = 0,
    EVMoneyRestictionTypeMore,
    EVMoneyRestictionTypeLeast,
    EVMoneyRestictionTypeMost,
    EVMoneyRestictionTypeMedium
};

@interface EVMoney : NSObject

@property (nonatomic, strong, readwrite) NSString* amount;
@property (nonatomic, strong, readwrite) NSString* currency;

@property (nonatomic, assign, readwrite) EVMoneyRestictionType restriction;

@property (nonatomic, assign, readwrite) EVBool perPerson;
@property (nonatomic, strong, readwrite) NSString* endOfRange;

- (instancetype)initWithResponse:(NSDictionary *)response;

@end
