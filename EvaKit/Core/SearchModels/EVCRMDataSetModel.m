//
//  EVCruiseSearchModel.m
//  EvaKit
//
//  Copyright (c) 2015 Evature. All rights reserved.
//

#import "EVCRMDataSetModel.h"
#import "EVCRMDataSetDelegate.h"

@interface EVCRMDataSetModel ()

@property (nonatomic, strong, readwrite) EVCRMAttributes* attributes;

@end

@implementation EVCRMDataSetModel


- (instancetype)initWithComplete:(BOOL)isComplete
                          inPage:(EVCRMPageType)page
                        setField:(NSString*)field
                     ofValueType:(NSNumber*)valueType
                         toValue:(NSObject*)value {
    self = [super initWithComplete:isComplete];
    if (self != nil) {
        self.page = page;
        self.fieldPath = field;
        self.valueType = valueType;
        self.value = value;
    }
    return self;
    
}

+ (instancetype)modelComplete:(BOOL)isComplete
                       inPage:(EVCRMPageType)page
                     setField:(NSString*)field
                  ofValueType:(NSNumber*)valueType
                      toValue:(NSObject*)value {

    return [[[self alloc] initWithComplete:isComplete
                                    inPage:page
                                  setField:field
                               ofValueType:valueType
                                   toValue:value] autorelease];
}



- (void)triggerSearchForDelegate:(id<EVSearchDelegate>)delegate {
    if ([delegate conformsToProtocol:@protocol(EVCRMDataSetDelegate)]) {
        [(id<EVCRMDataSetDelegate>)delegate setField:self.fieldPath
                                            forObject:(EVCRMPageType)self.page
                                              withId:0
                                             toValue: @{ @"type": self.valueType,
                                                         @"value": self.value }
                                             ];
    }
}

- (void)dealloc {
    self.attributes = nil;
    [super dealloc];
}

@end
