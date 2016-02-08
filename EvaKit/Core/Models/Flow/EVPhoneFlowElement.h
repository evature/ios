//
//  EVStatementFlowElement.h
//  EvaKit
//
//  Copyright (c) 2015 Evature. All rights reserved.
//

#import "EVFlowElement.h"
#import "EVCRMAttributes.h"



@interface EVPhoneFlowElement : EVFlowElement


@property (nonatomic, assign, readwrite) EVCRMPhoneType phoneType;
@property (nonatomic, assign, readwrite) EVCRMPageType page;
@property (nonatomic, strong, readwrite) NSString* subPage;



@end
