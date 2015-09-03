//
//  EVChat.h
//  EvaKit
//
//  Created by Yegor Popovych on 8/11/15.
//  Copyright (c) 2015 Evature. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EVBool.h"

@interface EVChat : NSObject

@property (nonatomic, assign, readwrite) EVBool hello;
@property (nonatomic, assign, readwrite) EVBool yes;
@property (nonatomic, assign, readwrite) EVBool no;
@property (nonatomic, assign, readwrite) EVBool meaningOfLife;
@property (nonatomic, assign, readwrite) EVBool who;
@property (nonatomic, assign, readwrite) NSString* name;
@property (nonatomic, assign, readwrite) EVBool newSession;

- (instancetype)initWithResponse:(NSDictionary *)response;

@end
