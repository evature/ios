//
//  EVDialog.h
//  EvaKit
//
//  Created by Yegor Popovych on 8/12/15.
//  Copyright (c) 2015 Evature. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EVDialogElement : NSObject

@property (nonatomic, strong, readwrite) NSString* content;
@property (nonatomic, strong, readwrite) NSString* type;
@property (nonatomic, strong, readwrite) NSString* relatedLocation;
@property (nonatomic, strong, readwrite) NSString* subType;
@property (nonatomic, strong, readwrite) NSArray* choices;

- (instancetype)initWithResponse:(NSDictionary *)response;

@end


@interface EVDialog : NSObject

@property (nonatomic, strong, readwrite) NSString* sayIt;
@property (nonatomic, strong, readwrite) NSArray* dialogElements;

- (instancetype)initWithResponse:(NSDictionary *)response;

@end
