//
//  EVSabre.h
//  EvaKit
//
//  Created by Yegor Popovych on 8/12/15.
//  Copyright (c) 2015 Evature. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EVSabre : NSObject

@property (nonatomic, strong, readwrite) NSArray* cryptic;
@property (nonatomic, strong, readwrite) NSArray* warnings;

- (instancetype)initWithResponse:(NSDictionary *)response;

@end
