//
//  EVQuestionFlowElement.h
//  EvaKit
//
//  Created by Yegor Popovych on 8/13/15.
//  Copyright (c) 2015 Evature. All rights reserved.
//

#import "EVFlowElement.h"

typedef NS_ENUM(int16_t, EVQuestionFlowElementType) {
    EVQuestionFlowElementTypeUnknown = -1,
    EVQuestionFlowElementTypeOpen = 0,
    EVQuestionFlowElementTypeMultipleChoice,
    EVQuestionFlowElementTypeYesNo
};

typedef NS_ENUM(int16_t, EVQuestionFlowElementCategory) {
    EVQuestionFlowElementCategoryUnknown = -1,
    EVQuestionFlowElementCategoryLocationAmbiguity = 0,
    EVQuestionFlowElementCategoryMissingDate,
    EVQuestionFlowElementCategoryMissingDuration,
    EVQuestionFlowElementCategoryMissingLocation,
    EVQuestionFlowElementCategoryInformative
};

@interface EVQuestionFlowElement : EVFlowElement

@property (nonatomic, assign, readwrite) EVQuestionFlowElementType questionType;
@property (nonatomic, assign, readwrite) EVQuestionFlowElementCategory questionCategory;
@property (nonatomic, strong, readwrite) NSString* questionSubCategory;
@property (nonatomic, strong, readwrite) NSArray* choices;
@property (nonatomic, assign, readwrite) EVFlowElementType actionType;

@end
