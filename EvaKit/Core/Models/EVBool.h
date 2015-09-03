//
//  EVBool.h
//  EvaKit
//
//  Created by Yegor Popovych on 9/3/15.
//  Copyright (c) 2015 Evature. All rights reserved.
//

#import <Foundation/Foundation.h>

// This type needed for proper nil BOOL handling

typedef NS_ENUM(int8_t, EVBool) {
    EVBoolNotSet = -1,
    EVBoolFalse = NO,
    EVBoolTrue = YES
};

#define EV_TRUE EVBoolTrue
#define EV_FALSE EVBoolFalse

#define EV_IS_TRUE(__val) ((__val) == EV_TRUE)
#define EV_IS_BOOL_SET(__val) ((__val) != EVBoolNotSet)
#define EV_IS_FALSE(__val) ((__val) == EV_FALSE)
