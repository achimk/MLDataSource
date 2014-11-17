//
//  MLPagedDataSource.m
//  MLDataSource
//
//  Created by Joachim Kret on 12/11/14.
//  Copyright (c) 2014 Joachim Kret. All rights reserved.
//

#import "MLPagedDataSource.h"

#pragma mark - MLDataSource

@interface MLDataSource ()

@property (nonatomic, readwrite, strong) NSError * error;
@property (nonatomic, readwrite, strong) NSArray * arrayOfData;

@end

#pragma mark - MLPagedDataSource

@interface MLPagedDataSource ()

@property (nonatomic, readwrite, assign) NSUInteger currentPage;
@property (nonatomic, readwrite, assign) MLDataSourceState state;

- (BOOL)canChangeFromState:(MLDataSourceState)fromState toState:(MLDataSourceState)toState;

@end

#pragma mark -

@implementation MLPagedDataSource

#pragma mark Init

- (id)init {
    return [self initWithArray:nil];
}

- (id)initWithArray:(NSArray *)array {
    if (self = [super initWithArray:array]) {
        _defaultPage = 0;
        _currentPage = _defaultPage;
        _state = MLDataSourceStateNormal;
    }
    
    return self;
}

#pragma mark Accessors

- (BOOL)canChangeToState:(MLDataSourceState)state {
    return [self canChangeFromState:self.state toState:state];
}

- (void)setState:(MLDataSourceState)state {
    if (state != _state && [self canChangeFromState:_state toState:state]) {
        MLDataSourceState fromState = _state;
        MLDataSourceState toState = state;
        id <MLPagedDataSourceProtocol> delegate = (id <MLPagedDataSourceProtocol>) self.delegate;
        
        if ([delegate respondsToSelector:@selector(dataSource:willChangeFromState:toState:)]) {
            [delegate dataSource:self willChangeFromState:fromState toState:toState];
        }
        
        _state = state;
        
        if ([delegate respondsToSelector:@selector(dataSource:didChangeFromState:toState:)]) {
            [delegate dataSource:self didChangeFromState:fromState toState:toState];
        }
    }
}

#pragma mark Fetch

- (void)performInitialFetch:(void (^)(MLDataSourceFulfiller, MLDataSourceRejecter))block {
    [self performFetchForState:MLDataSourceStateInitializing withBlock:block];
}

- (void)performRefreshFetch:(void (^)(MLDataSourceFulfiller, MLDataSourceRejecter))block {
    [self performFetchForState:MLDataSourceStateRefreshing withBlock:block];
}

- (void)performLoadingFetch:(void (^)(MLDataSourceFulfiller, MLDataSourceRejecter))block {
    [self performFetchForState:MLDataSourceStateLoading withBlock:block];
}

- (void)performFetch:(void (^)(MLDataSourceFulfiller, MLDataSourceRejecter))block {
    [self performFetchForState:MLDataSourceStateRefreshing withBlock:block];
}

- (void)performFetchForState:(MLDataSourceState)state withBlock:(void (^)(MLDataSourceFulfiller, MLDataSourceRejecter))block {
    NSAssert1([NSThread isMainThread], @"%@ should be called on main thread!", NSStringFromSelector(_cmd));
    NSParameterAssert(block);
    NSAssert1(MLDataSourceStateInitializing == state ||
              MLDataSourceStateRefreshing == state ||
              MLDataSourceStateLoading == state, @"Unsupported state: %ld", state);
    
    if (![self canChangeToState:state]) {
        return;
    }
    
    if ([self.delegate respondsToSelector:@selector(dataSource:shouldChangeFromState:toState:)]) {
        id <MLPagedDataSourceProtocol> delegate = (id <MLPagedDataSourceProtocol>) self.delegate;
        
        if (![delegate dataSource:self shouldChangeFromState:self.state toState:state]) {
            return;
        }
    }
    
    self.state = state;
    
    __weak typeof(self) weakSelf = self;
    MLDataSourceFulfiller fulfiller = ^(NSArray * data) {
        if (weakSelf) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            [strongSelf performFetchWithSuccess:data];
        }
    };
    
    MLDataSourceRejecter rejecter = ^(NSError * error) {
        if (weakSelf) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            [strongSelf performFetchWithFailure:error];
        }
    };
    
    block(fulfiller, rejecter);
}

- (void)performFetchWithSuccess:(NSArray *)data {
    NSAssert([NSThread isMainThread], @"Fulfiller must be called on main thread!");
    
    if ([self.delegate respondsToSelector:@selector(dataSourceWillChangeContent:)]) {
        [self.delegate dataSourceWillChangeContent:self];
    }
    
    NSMutableArray * tmp = [[NSMutableArray alloc] init];
    
    if (MLDataSourceStateLoading == self.state) {
        [tmp addObjectsFromArray:self.arrayOfData];
        self.currentPage = self.currentPage + 1;
    }
    else {
        self.currentPage = self.defaultPage;
    }
    
    [tmp addObjectsFromArray:data];
    self.arrayOfData = [NSArray arrayWithArray:tmp];
    self.state = MLDataSourceStateNormal;
    self.error = nil;
    
    if ([self.delegate respondsToSelector:@selector(dataSourceDidChangeContent:)]) {
        [self.delegate dataSourceDidChangeContent:self];
    }
}

- (void)performFetchWithFailure:(NSError *)error {
    NSAssert([NSThread isMainThread], @"Rejecter must be called on main thread!");
    
    self.state = MLDataSourceStateNormal;
    self.error = error;
}

#pragma mark Private Methods

- (BOOL)canChangeFromState:(MLDataSourceState)fromState toState:(MLDataSourceState)toState {
    BOOL canChange = NO;
    
    switch ((NSUInteger)toState) {
        case MLDataSourceStateNormal: {
            switch ((NSUInteger)fromState) {
                case MLDataSourceStateInitializing:
                case MLDataSourceStateRefreshing:
                case MLDataSourceStateLoading: {
                    canChange = YES;
                } break;
            }
        } break;
            
        case MLDataSourceStateInitializing:
        case MLDataSourceStateRefreshing: {
            switch ((NSUInteger)fromState) {
                case MLDataSourceStateNormal:
                case MLDataSourceStateLoading: {
                    canChange = YES;
                } break;
            }
        } break;
            
        case MLDataSourceStateLoading: {
            switch ((NSUInteger)fromState) {
                case MLDataSourceStateNormal: {
                    canChange = YES;
                } break;
            }
        } break;
    }
    
    return canChange;
}

@end
