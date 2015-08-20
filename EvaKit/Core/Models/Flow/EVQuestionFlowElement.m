//
//  EVQuestionFlowElement.m
//  EvaKit
//
//  Created by Yegor Popovych on 8/13/15.
//  Copyright (c) 2015 Evature. All rights reserved.
//

#import "EVQuestionFlowElement.h"

@implementation EVQuestionFlowElement

static NSDictionary* questionTypes = nil;
static NSDictionary* questionCategories = nil;

+ (void)load {
    questionTypes = [@{@"Unknown": @(EVQuestionFlowElementTypeUnknown),
                       @"Open": @(EVQuestionFlowElementTypeOpen),
                       @"Multiple Choice": @(EVQuestionFlowElementTypeMultipleChoice),
                       @"YesNo": @(EVQuestionFlowElementTypeYesNo)
                       } retain];
    questionCategories = [@{@"Unknown": @(EVQuestionFlowElementCategoryUnknown),
                            @"Location Ambiguity": @(EVQuestionFlowElementCategoryLocationAmbiguity),
                            @"Missing Date": @(EVQuestionFlowElementCategoryMissingDate),
                            @"Missing Duration": @(EVQuestionFlowElementCategoryMissingDuration),
                            @"Missing Location": @(EVQuestionFlowElementCategoryMissingLocation),
                            @"Informative": @(EVQuestionFlowElementCategoryInformative)
                            } retain];
    [self registerClass:self forElementType:EVFlowElementTypeQuestion];
}

- (instancetype)initWithResponse:(NSDictionary*)response andLocations:(NSArray*)locations {
    self = [super initWithResponse:response andLocations:locations];
    if (self != nil) {
        if ([response objectForKey:@"QuestionType"] != nil) {
            NSNumber* val = [questionTypes objectForKey:[response objectForKey:@"QuestionType"]];
            if (val != nil) {
                self.questionType = [val shortValue];
            } else {
                self.questionType = EVQuestionFlowElementTypeUnknown;
            }
        } else {
            self.questionType = EVQuestionFlowElementTypeUnknown;
        }
        if ([response objectForKey:@"QuestionCategory"] != nil) {
            NSNumber* val = [questionCategories objectForKey:[response objectForKey:@"QuestionCategory"]];
            if (val != nil) {
                self.questionCategory = [val shortValue];
            } else {
                self.questionCategory = EVQuestionFlowElementCategoryUnknown;
            }
        } else {
            self.questionCategory = EVQuestionFlowElementCategoryUnknown;
        }
        if ([response objectForKey:@"ActionType"] != nil) {
            self.actionType = [[self class] typeForTypeString:[response objectForKey:@"ActionType"]];
        }
        self.questionSubCategory = [response objectForKey:@"QuestionSubCategory"];
        self.choices = [response objectForKey:@"QuestionChoices"];
    }
    return self;
}

@end
