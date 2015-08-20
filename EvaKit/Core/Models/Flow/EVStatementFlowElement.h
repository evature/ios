//
//  EVStatementFlowElement.h
//  EvaKit
//
//  Created by Yegor Popovych on 8/13/15.
//  Copyright (c) 2015 Evature. All rights reserved.
//

#import "EVFlowElement.h"

typedef NS_ENUM(int16_t, EVStatementFlowElementType) {
    EVStatementFlowElementTypeOther = -1,
    EVStatementFlowElementTypeUnderstanding = 0,
    EVStatementFlowElementTypeChat,
    EVStatementFlowElementTypeUnsupported,
    EVStatementFlowElementTypeUnknownExpression
};

@interface EVStatementFlowElement : EVFlowElement

@property (nonatomic, assign, readwrite) EVStatementFlowElementType statementType;

@end
