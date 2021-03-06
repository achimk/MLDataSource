//
//  MLCollectionViewController.h
//  MLDataSource
//
//  Created by Joachim Kret on 12/11/14.
//  Copyright (c) 2014 Joachim Kret. All rights reserved.
//

#import "MLViewController.h"

@interface MLCollectionViewController : MLViewController <UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, readwrite, strong) IBOutlet UICollectionView * collectionView;
@property (nonatomic, readonly, strong) UICollectionViewLayout * collectionViewLayout;
@property (nonatomic, readwrite, assign) BOOL clearsSelectionOnViewWillAppear;
@property (nonatomic, readwrite, assign) BOOL clearsSelectionOnReloadData;
@property (nonatomic, readwrite, assign) BOOL reloadOnCurrentLocaleChange;
@property (nonatomic, readwrite, assign) BOOL reloadOnAppearsFirstTime;
@property (nonatomic, readwrite, assign) BOOL showsBackgroundView;

+ (Class)defaultCollectionViewLayoutClass;

- (id)initWithCollectionViewLayout:(UICollectionViewLayout *)layout;

- (void)setNeedsReload;
- (BOOL)needsReload;

- (void)reloadIfNeeded;
- (void)reloadIfVisible;
- (void)reloadData;

@end

@interface MLCollectionViewController (MLSubclassOnly)

- (UIView *)backgroundViewForCollectionView:(UICollectionView *)collectionView;

@end

@interface MLCollectionViewController (MLNotifications)

- (void)currentLocaleDidChangeNotification:(NSNotification *)aNotification;

@end