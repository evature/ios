//
//  EvaKit
//
//  Copyright (c) 2015 Evature. All rights reserved.
//

#import "EVCRMDataSetModel.h"
#import "EVCRMDataDelegate.h"

@interface EVCRMDataSetModel ()

@property (nonatomic, assign, readwrite) EVCRMPageType page;
@property (nonatomic, strong, readwrite) NSString* subPage;
@property (nonatomic, strong, readwrite) NSString* field;
@property (nonatomic, strong, readwrite) NSNumber* valueType;
@property (nonatomic, strong, readwrite) id value;

@end

@implementation EVCRMDataSetModel


- (instancetype)initWithComplete:(BOOL)isComplete
                          inPage:(EVCRMPageType)page
                         subPage:(NSString*)subPage
                        setField:(NSString*)field
                     ofValueType:(NSNumber*)valueType
                         toValue:(id)value {
    self = [super initWithComplete:isComplete];
    if (self != nil) {
        self.page = page;
        self.subPage = subPage;
        self.field = field;
        self.valueType = valueType;
        self.value = value;
    }
    return self;
    
}

+ (instancetype)modelComplete:(BOOL)isComplete
                       inPage:(EVCRMPageType)page
                      subPage:(NSString*)subPage
                     setField:(NSString*)field
                  ofValueType:(NSNumber*)valueType
                      toValue:(id)value {

    return [[[self alloc] initWithComplete:isComplete
                                    inPage:page
                                   subPage:subPage
                                  setField:field
                               ofValueType:valueType
                                   toValue:value] autorelease];
}



- (EVCallbackResult*)triggerSearchForDelegate:(id<EVSearchDelegate>)delegate {
    if (self.value != nil && self.valueType != nil) {
        if ([delegate respondsToSelector:@selector(setField:inPage:withId:toValue:)]) {
            return [(id<EVCRMDataDelegate>)delegate setField:self.field
                                                inPage:(EVCRMPageType)self.page
                                                  withId:self.subPage
                                                 toValue: @{ @"type": self.valueType,
                                                             @"value": self.value }
                                                 ];
        }
    }
    return [EVCallbackResult resultWithNone];
}

- (void)dealloc {
    self.field = nil;
    self.subPage = nil;
    self.value = nil;
    self.valueType = nil;
    [super dealloc];
}

@end
