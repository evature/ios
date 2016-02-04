//
//  EVStatementFlowElement.h
//  EvaKit
//
//  Copyright (c) 2015 Evature. All rights reserved.
//

#import "EVFlowElement.h"




@interface EVPhoneFlowElement : EVFlowElement

typedef NS_ENUM(int16_t, EVPhoneType) {
    EVPhoneTypeOther = -1,
    EVPhoneTypeMobile = 0,
    EVPhoneTypeHome,
    EVPhoneTypeLandLine,
    EVPhoneTypWork,
};

@property (nonatomic, assign, readwrite) EVPhoneType phoneType;
@property (nonatomic, assign, readwrite) NSString* phoneNumber;


@end
