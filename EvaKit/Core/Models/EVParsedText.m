//
//  EVParsedText.m
//  EvaKit
//
//  Created by Yegor Popovych on 8/12/15.
//  Copyright (c) 2015 Evature. All rights reserved.
//

#import "EVParsedText.h"

@implementation EVTimesMarkup

- (instancetype)initWithResponse:(NSDictionary *)response {
    self = [super init];
    if (self != nil) {
        self.text = [response objectForKey:@"Text"];
        self.position = [response objectForKey:@"Position"] == nil ? -1 : [[response objectForKey:@"Position"] integerValue];
        self.type = [response objectForKey:@"Type"];
    }
    return self;
}

- (void)dealloc {
    self.type = nil;
    self.text = nil;
    [super dealloc];
}

@end

@implementation EVLocationMarkup

- (instancetype)initWithResponse:(NSDictionary *)response {
    self = [super init];
    if (self != nil) {
        self.text = [response objectForKey:@"Text"];
        self.position = [response objectForKey:@"Position"] == nil ? -1 : [[response objectForKey:@"Position"] integerValue];
    }
    return self;
}

- (void)dealloc {
    self.text = nil;
    [super dealloc];
}

@end

@implementation EVParsedText

- (instancetype)initWithResponse:(NSDictionary *)response {
    self = [super init];
    if (self != nil) {
        if ([response objectForKey:@"Locations"] != nil) {
            NSMutableArray* locations = [NSMutableArray array];
            for (NSDictionary* location in [response objectForKey:@"Locations"]) {
                [locations addObject:[[[EVLocationMarkup alloc] initWithResponse:location] autorelease]];
            }
            self.locations = [NSArray arrayWithArray:locations];
        } else {
            self.locations = [NSArray array];
        }
        if ([response objectForKey:@"Times"] != nil) {
            NSMutableArray* times = [NSMutableArray array];
            for (NSDictionary* time in [response objectForKey:@"Times"]) {
                [times addObject:[[[EVTimesMarkup alloc] initWithResponse:time] autorelease]];
            }
            self.times = [NSArray arrayWithArray:times];
        } else {
            self.times = [NSArray array];
        }
    }
    return self;
}

- (void)dealloc {
    self.locations = nil;
    self.times = nil;
    [super dealloc];
}

@end
