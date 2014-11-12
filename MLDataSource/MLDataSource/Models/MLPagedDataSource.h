//
//  MLPagedDataSource.h
//  MLDataSource
//
//  Created by Joachim Kret on 12/11/14.
//  Copyright (c) 2014 Joachim Kret. All rights reserved.
//

#import "MLDataSource.h"

typedef NS_ENUM(NSUInteger, MLDataSourceState) {
    MLDataSourceStateNormal,
    MLDataSourceStateInitializing,
    MLDataSourceStateRefreshing,
    MLDataSourceStateLoading,
};

@protocol MLPagedDataSourceProtocol <MLDataSourceDelegate>

@optional
- (void)dataSource:(MLDataSource *)dataSource willChangeFromState:(MLDataSourceState)fromState toState:(MLDataSourceState)toState;
- (void)dataSource:(MLDataSource *)dataSource didChangeFromState:(MLDataSourceState)fromState toState:(MLDataSourceState)toState;
- (BOOL)dataSource:(MLDataSource *)dataSource shouldChangeFromState:(MLDataSourceState)fromState toState:(MLDataSourceState)toState;

@end

@interface MLPagedDataSource : MLDataSource

@property (nonatomic, readwrite, assign) NSUInteger defaultPage;
@property (nonatomic, readonly, assign) NSUInteger currentPage;
@property (nonatomic, readonly, assign) MLDataSourceState state;

- (BOOL)canChangeToState:(MLDataSourceState)state;

- (void)performInitialFetch:(void (^)(MLDataSourceFulfiller, MLDataSourceRejecter))block;
- (void)performRefreshFetch:(void (^)(MLDataSourceFulfiller, MLDataSourceRejecter))block;
- (void)performLoadingFetch:(void (^)(MLDataSourceFulfiller, MLDataSourceRejecter))block;
- (void)performFetchForState:(MLDataSourceState)state withBlock:(void (^)(MLDataSourceFulfiller, MLDataSourceRejecter))block;

@end