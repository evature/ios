//
//  EVStatementFlowElement.h
//  EvaKit
//
//  Copyright (c) 2015 Evature. All rights reserved.
//

#import "EVFlowElement.h"

typedef NS_ENUM(int16_t, EVDataFlowElementVerbType) {
    EVDataFlowElementVerbTypeOther = -1,
    EVDataFlowElementVerbTypeSet = 0,
    EVDataFlowElementVerbTypeGet
};


typedef NS_ENUM(int16_t, EVCRMValueType) {
    EVDataFlowElementValueTypeNumber,    // value is of type NSNumber*
    EVDataFlowElementValueTypeString,     // value is of type NSString*
    EVDataFlowElementValueTypeDate        // value is of type NSDate*
};



@interface EVDataFlowElement : EVFlowElement

@property (nonatomic, assign, readwrite) EVDataFlowElementVerbType verb;
@property (nonatomic, assign, readwrite) NSString* fieldPath;
@property (nonatomic, assign, readwrite) NSNumber* valueType;
@property (nonatomic, assign, readwrite) NSObject* value;


@end
