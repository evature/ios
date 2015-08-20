//
//  EVReplyFlowElement.h
//  EvaKit
//
//  Created by Yegor Popovych on 8/13/15.
//  Copyright (c) 2015 Evature. All rights reserved.
//

#import "EVFlowElement.h"

@interface EVReplyFlowElement : EVFlowElement

@property (nonatomic, strong, readwrite) NSString* attributeKey;
@property (nonatomic, strong, readwrite) NSString* attributeType;

@end
