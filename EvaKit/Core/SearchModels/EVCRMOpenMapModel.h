//
//  EvaKit
//
//  Copyright (c) 2016 Evature. All rights reserved.
//

#import "EVSearchModel.h"
#import "EVCRMPhoneActionDelegate.h"
#import "EVCRMAttributes.h"

@interface EVCRMOpenMapModel : EVSearchModel

@property (nonatomic, assign, readonly) EVCRMPageType page;
@property (nonatomic, strong, readonly) NSString* subPage;

- (instancetype)initWithComplete:(BOOL)isComplete
                          inPage:(EVCRMPageType)page
                         subPage:(NSString*)subPage;

+ (instancetype)modelComplete:(BOOL)isComplete
                       inPage:(EVCRMPageType)page
                      subPage:(NSString*)subPage;



@end
