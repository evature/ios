//
//  EVCruiseSearchModel.h
//  EvaKit
//
//  Created by Yegor Popovych on 8/24/15.
//  Copyright (c) 2015 Evature. All rights reserved.
//

#import "EVSearchModel.h"
#import "EVCRMDataGetDelegate.h"
#import "EVCRMAttributes.h"

@interface EVCRMDataGetModel : EVSearchModel

@property (nonatomic, assign, readonly) EVCRMPageType page;
@property (nonatomic, strong, readonly) NSString* subPage;
@property (nonatomic, strong, readonly) NSString* field;

- (instancetype)initWithComplete:(BOOL)isComplete
                          inPage:(EVCRMPageType)page
                         subPage:(NSString*)subPage
                        setField:(NSString*)field;

+ (instancetype)modelComplete:(BOOL)isComplete
                       inPage:(EVCRMPageType)page
                      subPage:(NSString*)subPage
                     setField:(NSString*)field;



@end
