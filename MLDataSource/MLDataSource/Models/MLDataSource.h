//
//  MLDataSource.h
//  MLDataSource
//
//  Created by Joachim Kret on 12/11/14.
//  Copyright (c) 2014 Joachim Kret. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^MLDataSourceFulfiller)(NSArray *);
typedef void (^MLDataSourceRejecter)(NSError *);

@class MLDataSource;

@protocol MLDataSourceProtocol <NSObject>

@required
- (void)performFetch:(void (^)(MLDataSourceFulfiller, MLDataSourceRejecter))block;
- (NSInteger)numberOfSections;
- (NSInteger)numberOfRowsInSection:(NSInteger)section;

@end

@protocol MLDataSourceDelegate <NSObject>

@optional
- (void)dataSourceWillChangeContent:(MLDataSource *)dataSource;
- (void)dataSourceDidChangeContent:(MLDataSource *)dataSource;

@end

@interface MLDataSource : NSObject <MLDataSourceProtocol> {
    NSError * _error;
    NSArray * _arrayOfData;
}

@property (nonatomic, readonly, assign, getter=isEmpty) BOOL empty;
@property (nonatomic, readonly, strong) NSError * error;
@property (nonatomic, readwrite, weak) id <MLDataSourceDelegate> delegate;

- (instancetype)initWithArray:(NSArray *)array;

@end


@interface MLDataSource (MLSubclassOnly)

- (void)performFetchWithSuccess:(NSArray *)data;
- (void)performFetchWithFailure:(NSError *)error;

@end