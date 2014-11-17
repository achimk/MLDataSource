//
//  MLLoadingTableViewCell.h
//  MLDataSource
//
//  Created by Joachim Kret on 17/11/14.
//  Copyright (c) 2014 Joachim Kret. All rights reserved.
//

#import "MLTableViewCell.h"

@interface MLLoadingTableViewCell : MLTableViewCell

@property (nonatomic, readonly, strong) UIActivityIndicatorView * activityIndicatorView;

@end
