//
//  EVTravelers.m
//  EvaKit
//
//  Created by Yegor Popovych on 8/12/15.
//  Copyright (c) 2015 Evature. All rights reserved.
//

#import "EVTravelers.h"


@implementation EVTravelers

- (instancetype)initWithResponse:(NSDictionary *)response {
    self = [super init];
    if (self != nil) {
        if ([response objectForKey:@"Adult"]) {
            self.adult = [[response objectForKey:@"Adult"] integerValue];
        } else {
            self.adult = -1;
        }
        if ([response objectForKey:@"Child"]) {
            self.child = [[response objectForKey:@"Child"] integerValue];
        } else {
            self.child = -1;
        }
        if ([response objectForKey:@"Infant"]) {
            self.infant = [[response objectForKey:@"Infant"] integerValue];
        } else {
            self.infant = -1;
        }
        if ([response objectForKey:@"Elderly"]) {
            self.elderly = [[response objectForKey:@"Elderly"] integerValue];
        } else {
            self.elderly = -1;
        }
    }
    return self;
}

- (NSInteger)sepcifiedAdults {
    return self.adult;
}

/***
 * @return Integer number of children (not infants!) specified,  null if none were specified
 */
- (NSInteger)sepcifiedChildren {
    return self.child;
}

/***
 * @return Integer number of elderly (not adults!) specified,  null if none were specified
 */
- (NSInteger)sepcifiedElderly {
    return self.elderly;
}

/***
 * @return Integer number of infants (not children!) specified,  null if none were specified
 */
- (NSInteger)sepcifiedInfants {
    return self.infant;
}

/***
 * @return Total number of adults (adult+elderly) - if none are specified the result is zero
 */
- (NSInteger)getAllAdults {
    return [self getAdults] + [self getElderly];
}

/***
 * @return Total number of children (children+infants) - if none are specified the result is zero
 */
- (NSInteger)getAllChildren {
    return [self getChildren] + [self getInfants];
}

- (NSInteger)getAdults {
    return self.adult == -1 ? 0 : self.adult;
}

- (NSInteger)getChildren {
    return self.child == -1 ? 0 : self.child;
}

- (NSInteger)getElderly {
    return self.elderly == -1 ? 0 : self.elderly;
}

- (NSInteger)getInfants {
    return self.infant == -1 ? 0 : self.infant;
}

@end
