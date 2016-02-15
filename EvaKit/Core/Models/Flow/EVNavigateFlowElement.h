//
//  EvaKit
//
//  Copyright (c) 2015 Evature. All rights reserved.
//

#import "EVFlowElement.h"




@interface EVNavigateFlowElement : EVFlowElement

@property (nonatomic, assign, readwrite) NSString* pagePath;
@property (nonatomic, assign, readwrite) NSDictionary* filter;

@end
