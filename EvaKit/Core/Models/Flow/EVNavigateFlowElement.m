//
//  EvaKit
//
//  Copyright (c) 2015 Evature. All rights reserved.
//

#import "EVNavigateFlowElement.h"

@implementation EVNavigateFlowElement


+ (void)load {
    [self registerClass:self forElementType:EVFlowElementTypeNavigate];
}

- (instancetype)initWithResponse:(NSDictionary*)response andLocations:(NSArray*)locations {
    self = [super initWithResponse:response andLocations:locations];
    if (self != nil) {
        self.pagePath = [response objectForKey:@"URL"];
        self.filter = [response objectForKey:@"Filter"];
    }
    return self;
}

@end
