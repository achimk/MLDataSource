//
//  MLViewController.h
//  MLDataSource
//
//  Created by Joachim Kret on 12/11/14.
//  Copyright (c) 2014 Joachim Kret. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MLViewController : UIViewController

@property (nonatomic, readonly, assign) BOOL appearsFirstTime;
@property (nonatomic, readonly, assign, getter = isViewVisible) BOOL viewVisible;

@end

@interface MLViewController (MLSubclassOnly)

- (void)finishInitialize;

@end
