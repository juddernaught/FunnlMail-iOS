//
//  FilterViewVC.h
//  FunnlMail
//
//  Created by Michael Raber on 3/30/14.
//  Copyright (c) 2014 FunnlMail. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FilterModel.h"

@interface FilterViewVC : UIViewController<UITableViewDataSource, UITableViewDelegate>{
  UIView *filterNavigationView;
  UILabel *filterLabel;
}

@property (strong) UITableView *tableView;
@property (strong,nonatomic) FilterModel *filterModel;

@end
