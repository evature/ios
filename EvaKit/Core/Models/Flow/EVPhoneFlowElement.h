//
//  EvaKit
//
//  Copyright (c) 2015 Evature. All rights reserved.
//

#import "EVFlowElement.h"
#import "EVCRMAttributes.h"

typedef NS_ENUM(int16_t, EVPhoneActionFlowElementActionType) {
    EVPhoneActionFlowElementActionTypeOther = -1,
    EVPhoneActionFlowElementActionTypeCall = 0,
    EVPhoneActionFlowElementActionTypeOpenMap
};


@interface EVPhoneActionFlowElement : EVFlowElement


@property (nonatomic, assign, readwrite) EVPhoneActionFlowElementActionType action;
@property (nonatomic, assign, readwrite) EVCRMPhoneType phoneType;
@property (nonatomic, assign, readwrite) EVCRMPageType page;
@property (nonatomic, strong, readwrite) NSString* subPage;



@end
