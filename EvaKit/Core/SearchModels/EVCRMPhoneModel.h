//
//  EvaKit
//
//  Copyright (c) 2015 Evature. All rights reserved.
//

#import "EVSearchModel.h"
#import "EVCRMPhoneActionDelegate.h"
#import "EVCRMAttributes.h"

@interface EVCRMPhoneModel : EVSearchModel

@property (nonatomic, assign, readonly) EVCRMPageType page;
@property (nonatomic, strong, readonly) NSString* subPage;
@property (nonatomic, assign, readonly) EVCRMPhoneType phoneType;

- (instancetype)initWithComplete:(BOOL)isComplete
                          inPage:(EVCRMPageType)page
                         subPage:(NSString*)subPage
                        phoneType:(EVCRMPhoneType)phoneType;

+ (instancetype)modelComplete:(BOOL)isComplete
                       inPage:(EVCRMPageType)page
                      subPage:(NSString*)subPage
                    phoneType:(EVCRMPhoneType)phoneType;



@end
