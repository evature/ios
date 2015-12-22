//
//  EVCruiseSearchModel.m
//  EvaKit
//
//  Copyright (c) 2015 Evature. All rights reserved.
//

#import "EVCRMDataSetModel.h"
#import "EVCRMDataSetDelegate.h"

@interface EVCRMDataSetModel ()

@property (nonatomic, assign, readwrite) EVCRMPageType page;
@property (nonatomic, strong, readwrite) NSString* fieldPath;
@property (nonatomic, strong, readwrite) NSNumber* valueType;
@property (nonatomic, strong, readwrite) id value;

@end

@implementation EVCRMDataSetModel


- (instancetype)initWithComplete:(BOOL)isComplete
                          inPage:(EVCRMPageType)page
                        setField:(NSString*)field
                     ofValueType:(NSNumber*)valueType
                         toValue:(id)value {
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
                      toValue:(id)value {

    return [[[self alloc] initWithComplete:isComplete
                                    inPage:page
                                  setField:field
                               ofValueType:valueType
                                   toValue:value] autorelease];
}



- (EVCallbackResponse*)triggerSearchForDelegate:(id<EVSearchDelegate>)delegate {
    if ([delegate conformsToProtocol:@protocol(EVCRMDataSetDelegate)]) {
        return [(id<EVCRMDataSetDelegate>)delegate setField:self.fieldPath
                                            inPage:(EVCRMPageType)self.page
                                              withId:0
                                             toValue: @{ @"type": self.valueType,
                                                         @"value": self.value }
                                             ];
    }
    return [EVCallbackResponse responseWithNone];
}

- (void)dealloc {
    self.fieldPath = nil;
    self.value = nil;
    self.valueType = nil;
    [super dealloc];
}

@end
