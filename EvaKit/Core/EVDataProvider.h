//
//  EVDataProvider.h
//  EvaKit
//
//  Created by Yegor Popovych on 7/30/15.
//  Copyright (c) 2015 Evature. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol EVDataProviderDelegate;

@protocol EVDataProvider <NSObject>

@property (nonatomic, assign, readwrite) id<EVDataProviderDelegate> dataProviderDelegate;

- (void)stopDataProvider;

@end


@protocol EVDataProviderDelegate <NSObject>

@required
- (void)provider:(id<EVDataProvider>)provider hasNewData:(NSData*)data;
- (void)provider:(id<EVDataProvider>)provider gotAnError:(NSError*)error;

@optional
- (void)providerStarted:(id<EVDataProvider>)provider;
- (void)providerFinished:(id<EVDataProvider>)provider;

@end