//
//  EVSearchContextBase.h
//  EvaKit
//
//  Created by Yegor Popovych on 8/20/15.
//  Copyright (c) 2015 Evature. All rights reserved.
//

#import <Foundation/Foundation.h>

#define EV_CHECK_BITMASK(__var, __mask) ((__var & (__mask)) == __mask)

typedef NS_ENUM(unsigned int, EVSearchContextType) {
    EVSearchContextTypeFlight = 1,
    EVSearchContextTypeHotel = 2,
    EVSearchContextTypeCar = 4,
    EVSearchContextTypeCruise = 8,
    EVSearchContextTypeVacation = 16,
    EVSearchContextTypeSki = 32,
    EVSearchContextTypeExplore = 64,
};

@interface EVSearchContextBase : NSObject {
    @protected
    EVSearchContextType _type;
}

@property (nonatomic, assign, readonly) EVSearchContextType type;

- (NSString*)requestParameterValue;

@end
