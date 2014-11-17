//
//  MLDataSource.m
//  MLDataSource
//
//  Created by Joachim Kret on 12/11/14.
//  Copyright (c) 2014 Joachim Kret. All rights reserved.
//

#import "MLDataSource.h"

#pragma mark - MLDataSource

@interface MLDataSource ()

@property (nonatomic, readwrite, strong) NSError * error;
@property (nonatomic, readwrite, strong) NSArray * arrayOfData;

@end

#pragma mark -

@implementation MLDataSource

@dynamic empty;

#pragma mark Init

- (instancetype)init {
    return [self initWithArray:nil];
}

- (instancetype)initWithArray:(NSArray *)array {
    if (self = [super init]) {
        _arrayOfData = (array) ? array : @[];
    }
    
    return self;
}

#pragma mark Accessors

- (BOOL)isEmpty {
    return (0 == self.arrayOfData.count);
}

#pragma mark Fetch

- (void)performFetch:(void (^)(MLDataSourceFulfiller, MLDataSourceRejecter))block {
    NSAssert1([NSThread isMainThread], @"%@ should be called on main thread!", NSStringFromSelector(_cmd));
    NSParameterAssert(block);
    
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
    
    self.error = nil;
    
    block(fulfiller, rejecter);
}

- (void)performFetchWithSuccess:(NSArray *)data {
    NSAssert([NSThread isMainThread], @"Fulfiller must be called on main thread!");
    
    if ([self.delegate respondsToSelector:@selector(dataSourceWillChangeContent:)]) {
        [self.delegate dataSourceWillChangeContent:self];
    }
    
    NSMutableArray * tmp = [[NSMutableArray alloc] initWithArray:self.arrayOfData];
    [tmp addObjectsFromArray:data];
    self.arrayOfData = [NSArray arrayWithArray:tmp];
    
    if ([self.delegate respondsToSelector:@selector(dataSourceDidChangeContent:)]) {
        [self.delegate dataSourceDidChangeContent:self];
    }
}

- (void)performFetchWithFailure:(NSError *)error {
    NSAssert([NSThread isMainThread], @"Rejecter must be called on main thread!");
    
    self.error = error;
}

- (NSInteger)numberOfSections {
    return 1;
}

- (NSInteger)numberOfRowsInSection:(NSInteger)section {
    return self.arrayOfData.count;
}

//#pragma mark Proxy

//+ (Class)class {
//    return [NSArray class];
//}

//+ (BOOL)respondsToSelector:(SEL)aSelector {
//    id proxy = [[[self class] alloc] init];
//    return [proxy respondsToSelector:aSelector];
//}

//- (void)forwardInvocation:(NSInvocation *)invocation {
//    invocation.target = self.arrayOfData;
//    [invocation invoke];
//}
//
//- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel {
//    return [[self arrayOfData] methodSignatureForSelector:sel];
//}
//
//- (NSString *)description {
//    return self.arrayOfData.description;
//}

@end
