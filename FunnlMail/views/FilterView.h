//
//  FilterView.h
//  FunnlMail
//
//  Created by Michael Raber on 4/9/14.
//  Copyright (c) 2014 FunnlMail. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FilterModel.h"
#import "MainVCDelegate.h"


@interface FilterView : UIView<UITableViewDataSource, UITableViewDelegate>{
  UIView *filterNavigationView;
  UILabel *filterLabel;
}

@property (strong) UITableView *tableView;
@property (strong,nonatomic) FilterModel *filterModel;
@property (weak) id<MainVCDelegate> mainVCdelegate;

- (void) startLogin;

@end
