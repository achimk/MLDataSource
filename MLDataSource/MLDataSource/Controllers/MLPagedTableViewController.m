//
//  MLPagedTableViewController.m
//  MLDataSource
//
//  Created by Joachim Kret on 17/11/14.
//  Copyright (c) 2014 Joachim Kret. All rights reserved.
//

#import "MLPagedTableViewController.h"

#import "MLTableViewCell.h"
#import "MLLoadingTableViewCell.h"
#import "MLPagedDataSource.h"

#define NUMBER_OF_OBJECTS_PER_PAGE      10

#pragma mark - MLPagedTableViewController

@interface MLPagedTableViewController () <MLPagedDataSourceProtocol>

@property (nonatomic, readwrite, strong) UIRefreshControl * refreshControl;
@property (nonatomic, readwrite, strong) MLPagedDataSource * dataSource;

@end

#pragma mark -

@implementation MLPagedTableViewController

#pragma mark Initialize

- (void)finishInitialize {
    [super finishInitialize];
    
    _dataSource = [[MLPagedDataSource alloc] initWithArray:nil];
    _dataSource.delegate = self;
}

#pragma mark View

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [MLTableViewCell registerCellWithTableView:self.tableView];
    [MLLoadingTableViewCell registerCellWithTableView:self.tableView];
    
    UIRefreshControl * refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    [self.tableView insertSubview:refreshControl atIndex:0];
    self.refreshControl = refreshControl;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (self.appearsFirstTime) {
        [self initialize:nil];
    }
}

#pragma mark Actions

- (IBAction)initialize:(id)sender {
    [self loadDataForState:MLDataSourceStateInitializing];
}

- (IBAction)refresh:(id)sender {
    [self loadDataForState:MLDataSourceStateRefreshing];
}

- (IBAction)page:(id)sender {
    [self loadDataForState:MLDataSourceStateLoading];
}

- (void)loadDataForState:(MLDataSourceState)state {
    __weak typeof (self) weakSelf = self;
    void (^block)(MLDataSourceFulfiller, MLDataSourceRejecter) = ^(MLDataSourceFulfiller fulfiller, MLDataSourceRejecter rejecter) {
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (weakSelf) {
                __strong typeof (weakSelf) strongSelf = weakSelf;
                NSMutableArray * arrayOfData = [[NSMutableArray alloc] initWithCapacity:NUMBER_OF_OBJECTS_PER_PAGE];
                NSInteger count = 0;
                
                if (MLDataSourceStateLoading == strongSelf.dataSource.state) {
                    count = [strongSelf.dataSource numberOfRowsInSection:0];
                }
                
                for (NSInteger i = 0; i < NUMBER_OF_OBJECTS_PER_PAGE; i++) {
                    [arrayOfData addObject:@(i + count)];
                }
                
                fulfiller(arrayOfData);
            }
        });
    };
    
    [[self dataSource] performFetchForState:state withBlock:block];
}

#pragma mark Accessors

- (BOOL)showsLoadingCell {
    return (MLDataSourceStateNormal == self.dataSource.state || MLDataSourceStateLoading == self.dataSource.state) && !self.dataSource.isEmpty && !self.dataSource.error;
}

- (BOOL)isLoadingCell:(NSIndexPath *)indexPath {
    return [indexPath isEqual:[self indexPathForLoadingCell]];
}

- (NSIndexPath *)indexPathForLoadingCell {
    if (!self.showsLoadingCell) {
        return nil;
    }
    
    NSInteger section = [self.dataSource numberOfSections] - 1;
    NSInteger row = [self.dataSource numberOfRowsInSection:section];
    return [NSIndexPath indexPathForRow:row inSection:section];
}

#pragma mark UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44.0f;
}

#pragma mark UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell * cell = nil;
    
    if ([self isLoadingCell:indexPath]) {
        MLLoadingTableViewCell * loadingCell = [MLLoadingTableViewCell cellForTableView:tableView indexPath:indexPath];
        [loadingCell.activityIndicatorView startAnimating];
        [self page:nil];
        cell = loadingCell;
    }
    else {
        MLTableViewCell * dataCell = [MLTableViewCell cellForTableView:tableView indexPath:indexPath];
        dataCell.textLabel.text = [NSString stringWithFormat:@"Row: %ld", indexPath.row];
        cell = dataCell;
    }
    
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.dataSource numberOfSections];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.dataSource numberOfRowsInSection:section] + ((self.showsLoadingCell) ? 1 : 0);
}

#pragma mark MLDataSourceDelegate

- (void)dataSourceWillChangeContent:(MLDataSource *)dataSource {
//    NSLog(@"-> %@", NSStringFromSelector(_cmd));
}

- (void)dataSourceDidChangeContent:(MLDataSource *)dataSource {
//    NSLog(@"-> %@", NSStringFromSelector(_cmd));
}

#pragma mark MLPagedDataSourceProtocol

- (void)dataSource:(MLDataSource *)dataSource willChangeFromState:(MLDataSourceState)fromState toState:(MLDataSourceState)toState {

//    NSLog(@"-> %@, (%ld -> %ld)", NSStringFromSelector(_cmd), fromState, toState);
}

- (void)dataSource:(MLDataSource *)dataSource didChangeFromState:(MLDataSourceState)fromState toState:(MLDataSourceState)toState {
    
//    NSLog(@"-> %@, (%ld -> %ld)", NSStringFromSelector(_cmd), fromState, toState);
    
    if (toState == MLDataSourceStateNormal) {
        if (self.refreshControl.isRefreshing) {
            [self.refreshControl endRefreshing];
        }
    }
    
    if (toState != MLDataSourceStateLoading) {
        [self.tableView reloadData];
    }
}

- (BOOL)dataSource:(MLDataSource *)dataSource shouldChangeFromState:(MLDataSourceState)fromState toState:(MLDataSourceState)toState {
    BOOL shouldChange = YES;
    
//    NSLog(@"-> %@, (%@)", NSStringFromSelector(_cmd), (shouldChange) ? @"YES" : @"NO");
    
    return shouldChange;
}

@end
