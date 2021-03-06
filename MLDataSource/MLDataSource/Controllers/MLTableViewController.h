//
//  MLTableViewController.h
//  MLDataSource
//
//  Created by Joachim Kret on 12/11/14.
//  Copyright (c) 2014 Joachim Kret. All rights reserved.
//

#import "MLViewController.h"

@interface MLTableViewController : MLViewController <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, readwrite, strong) IBOutlet UITableView * tableView;
@property (nonatomic, readwrite, assign) BOOL clearsSelectionOnViewWillAppear;
@property (nonatomic, readwrite, assign) BOOL clearsSelectionOnReloadData;
@property (nonatomic, readwrite, assign) BOOL reloadOnCurrentLocaleChange;
@property (nonatomic, readwrite, assign) BOOL reloadOnAppearsFirstTime;
@property (nonatomic, readwrite, assign) BOOL showsBackgroundView;

+ (UITableViewStyle)defaultTableViewStyle;

- (id)initWithStyle:(UITableViewStyle)style;

- (void)setNeedsReload;
- (BOOL)needsReload;

- (void)reloadIfNeeded;
- (void)reloadIfVisible;
- (void)reloadData;

@end

@interface MLTableViewController (MLSubclassOnly)

- (UIView *)backgroundViewForTableView:(UITableView *)tableView;

@end

@interface MLTableViewController (MLNotifications)

- (void)currentLocaleDidChangeNotification:(NSNotification *)aNotification;

@end