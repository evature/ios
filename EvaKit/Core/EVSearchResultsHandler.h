//
//  EVSearchResultsHandler.h
//  EvaKit
//
//  Created by Yegor Popovych on 8/25/15.
//  Copyright (c) 2015 Evature. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EVResponse.h"
#import "EVFlow.h"
#import "EVSearchDelegate.h"
#import "EVSearchModel.h"

@interface EVSearchResultsHandler : NSObject

+ (EVCallbackResult*)handleSearchResultWithResponse:(EVResponse*)response flow:(EVFlowElement*)flow andResponseDelegate:(id<EVSearchDelegate>)delegate  andStartRecordOnQestion:(BOOL)startRecordOnQuestion;

@end
