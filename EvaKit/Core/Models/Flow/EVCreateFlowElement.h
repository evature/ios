//
//  EvaKit
//
//  Copyright (c) 2015 Evature. All rights reserved.
//

#import "EVFlowElement.h"

typedef NS_ENUM(int16_t, EVCreateFlowElementItemType) {
    EVCreateFlowElementItemTypeUnknown = -1,
    EVCreateFlowElementItemTypeAppointment = 0,
};

@interface EVCreateFlowElement : EVFlowElement

@property (nonatomic, assign, readwrite) NSDictionary* details;
@property (nonatomic, assign, readwrite) EVCreateFlowElementItemType itemType;


@end
