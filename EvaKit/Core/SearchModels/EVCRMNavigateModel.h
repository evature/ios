//
//  EVCruiseSearchModel.h
//  EvaKit
//
//  Created by Yegor Popovych on 8/24/15.
//  Copyright (c) 2015 Evature. All rights reserved.
//

#import "EVSearchModel.h"
#import "EVCRMNavigateDelegate.h"
#import "EVCRMAttributes.h"

@interface EVCRMNavigateModel : EVSearchModel

@property (nonatomic, strong, readonly) EVCRMAttributes* attributes;
@property (nonatomic, assign, readonly) EVCRMPageType page;
@property (nonatomic, strong, readonly) NSString* subPage;


- (instancetype)initWithComplete:(BOOL)isComplete
                          inPage:(EVCRMPageType)page
                         subPage:(NSString*)subPage
                   crmAttributes:(EVCRMAttributes *)attributes;

+ (instancetype)modelComplete:(BOOL)isComplete
                       inPage:(EVCRMPageType)page
                      subPage:(NSString*)subPage
                crmAttributes:(EVCRMAttributes *)attributes;



@end
