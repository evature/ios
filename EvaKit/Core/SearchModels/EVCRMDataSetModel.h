//
//  EvaKit
//
//  Created by Yegor Popovych on 8/24/15.
//  Copyright (c) 2015 Evature. All rights reserved.
//

#import "EVSearchModel.h"
#import "EVCRMDataDelegate.h"
#import "EVCRMAttributes.h"

@interface EVCRMDataSetModel : EVSearchModel

@property (nonatomic, assign, readonly) EVCRMPageType page;
@property (nonatomic, strong, readonly) NSString* subPage;
@property (nonatomic, strong, readonly) NSString* field;
@property (nonatomic, strong, readonly) NSNumber* valueType;
@property (nonatomic, strong, readonly) id value;

- (instancetype)initWithComplete:(BOOL)isComplete
                          inPage:(EVCRMPageType)page
                         subPage:(NSString*)subPage
                        setField:(NSString*)field
                     ofValueType:(NSNumber*)valueType
                         toValue:(id)value;

+ (instancetype)modelComplete:(BOOL)isComplete
                       inPage:(EVCRMPageType)page
                      subPage:(NSString*)subPage
                     setField:(NSString*)field
                  ofValueType:(NSNumber*)valueType
                      toValue:(id)value;



@end
