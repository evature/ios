//
//  EVDialog.m
//  EvaKit
//
//  Created by Yegor Popovych on 8/12/15.
//  Copyright (c) 2015 Evature. All rights reserved.
//

#import "EVDialog.h"

@implementation EVDialogElement

- (instancetype)initWithResponse:(NSDictionary *)response {
    self = [super init];
    if (self != nil) {
        self.content = [response objectForKey:@"Content"];
        self.type = [response objectForKey:@"Type"];
        self.relatedLocation = [response objectForKey:@"RelatedLoation"];
        self.subType = [response objectForKey:@"SubType"];
        if ([response objectForKey:@"Choices"] != nil) {
            NSMutableArray* choices = [NSMutableArray array];
            for (NSString* choice in [response objectForKey:@"Choices"]) {
                [choices addObject:choice];
            }
            self.choices = [NSArray arrayWithArray:choices];
        }
    }
    return self;
}

@end


@implementation EVDialog

- (instancetype)initWithResponse:(NSDictionary *)response {
    self = [super init];
    if (self != nil) {
        self.sayIt = [response objectForKey:@"SayIt"];
        if ([response objectForKey:@"Elements"] != nil) {
            NSMutableArray* elements = [NSMutableArray array];
            for (NSDictionary* element in [response objectForKey:@"Elements"]) {
                [elements addObject:[[[EVDialogElement alloc] initWithResponse:element] autorelease]];
            }
            self.dialogElements = [NSArray arrayWithArray:elements];
        }
    }
    return self;
}

@end
