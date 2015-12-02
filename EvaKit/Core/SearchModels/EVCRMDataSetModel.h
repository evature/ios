//
//  EVCruiseSearchModel.h
//  EvaKit
//
//  Created by Yegor Popovych on 8/24/15.
//  Copyright (c) 2015 Evature. All rights reserved.
//

#import "EVSearchModel.h"
#import "EVCRMDataSetDelegate.h"
#import "EVCRMAttributes.h"

@interface EVCRMDataSetModel : EVSearchModel

@property (nonatomic, assign, readwrite) EVCRMPageType page;
@property (nonatomic, assign, readwrite) NSString* fieldPath;
@property (nonatomic, assign, readwrite) NSNumber* valueType;
@property (nonatomic, assign, readwrite) NSObject* value;

- (instancetype)initWithComplete:(BOOL)isComplete
                          inPage:(EVCRMPageType)page
                        setField:(NSString*)field
                     ofValueType:(NSNumber*)valueType
                         toValue:(NSObject*)value;

+ (instancetype)modelComplete:(BOOL)isComplete
                       inPage:(EVCRMPageType)page
                     setField:(NSString*)field
                  ofValueType:(NSNumber*)valueType
                      toValue:(NSObject*)value;



@end
