//
//  MLLoadingTableViewCell.m
//  MLDataSource
//
//  Created by Joachim Kret on 17/11/14.
//  Copyright (c) 2014 Joachim Kret. All rights reserved.
//

#import "MLLoadingTableViewCell.h"

#pragma mark - MLLoadingTableViewCell

@interface MLLoadingTableViewCell ()

@property (nonatomic, readwrite, strong) UIActivityIndicatorView * activityIndicatorView;

@end

#pragma mark -

@implementation MLLoadingTableViewCell

- (void)finishInitialize {
    [super finishInitialize];
    
    _activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    _activityIndicatorView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:_activityIndicatorView];
    
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:_activityIndicatorView
                                                                 attribute:NSLayoutAttributeCenterX
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeCenterX
                                                                multiplier:1.0f
                                                                  constant:0.0f]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:_activityIndicatorView
                                                                 attribute:NSLayoutAttributeCenterY
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeCenterY
                                                                multiplier:1.0f
                                                                  constant:0.0f]];
    [self.contentView setNeedsUpdateConstraints];
}

#pragma mark Prepare

- (void)prepareForReuse {
    [super prepareForReuse];
    
    [self.activityIndicatorView stopAnimating];
}

- (void)configureForData:(id)dataObject tableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath {
    [self.activityIndicatorView startAnimating];
}

@end
