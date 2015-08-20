//
//  EVSearchDelegate.h
//  EvaKit
//
//  Created by Yegor Popovych on 8/18/15.
//  Copyright (c) 2015 Evature. All rights reserved.
//

#import "EVSearchContextBase.h"

@class EVResponse;
// This is simple parent protocol for all search delegates. Use more concrete delegates rather than this
@protocol EVSearchDelegate <NSObject>

@optional
- (void)evSearchGotResponse:(EVResponse*)response;
- (void)evSearchGotAnError:(NSError*)error;
- (EVSearchContextType)searchContext;

@end