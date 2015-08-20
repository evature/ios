//
//  EVParsedText.h
//  EvaKit
//
//  Created by Yegor Popovych on 8/12/15.
//  Copyright (c) 2015 Evature. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EVTimesMarkup : NSObject

@property (nonatomic, strong, readwrite) NSString* text;
@property (nonatomic, strong, readwrite) NSString* type;
@property (nonatomic, assign, readwrite) NSInteger position;

- (instancetype)initWithResponse:(NSDictionary *)response;

@end

@interface EVLocationMarkup : NSObject

@property (nonatomic, strong, readwrite) NSString* text;
@property (nonatomic, assign, readwrite) NSInteger position;

- (instancetype)initWithResponse:(NSDictionary *)response;

@end

@interface EVParsedText : NSObject

@property (nonatomic, strong, readwrite) NSArray* times;
@property (nonatomic, strong, readwrite) NSArray* locations;

- (instancetype)initWithResponse:(NSDictionary *)response;

@end
