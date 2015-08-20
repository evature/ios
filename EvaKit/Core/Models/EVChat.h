//
//  EVChat.h
//  EvaKit
//
//  Created by Yegor Popovych on 8/11/15.
//  Copyright (c) 2015 Evature. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EVChat : NSObject

@property (nonatomic, assign, readwrite) BOOL hello;
@property (nonatomic, assign, readwrite) BOOL yes;
@property (nonatomic, assign, readwrite) BOOL no;
@property (nonatomic, assign, readwrite) BOOL meaningOfLife;
@property (nonatomic, assign, readwrite) BOOL who;
@property (nonatomic, assign, readwrite) NSString* name;
@property (nonatomic, assign, readwrite) BOOL newSession;

- (instancetype)initWithResponse:(NSDictionary *)response;

@end
