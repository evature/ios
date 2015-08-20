//
//  EVWarning.h
//  EvaKit
//
//  Created by Yegor Popovych on 8/11/15.
//  Copyright (c) 2015 Evature. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EVWarning : NSObject

@property (nonatomic, strong, readwrite) NSString* type;
@property (nonatomic, strong, readwrite) NSString* text;
@property (nonatomic, assign, readwrite) NSInteger position;

- (instancetype)initWithResponse:(NSArray *)response;

@end
