//
//  FMNotificationsViewController.h
//  FunnlMail
//
//  Created by shrinivas on 09/10/14.
//  Copyright (c) 2014 FunnlMail. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FunnelModel.h"
#import "FunnelService.h"
#import "UIColor+HexString.h"
#import "FMNotificationsTableViewCell.h"
#import "UIView+Toast.h"

@interface FMNotificationsViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>
{
  NSMutableArray *dataSource;
  UITableView *notificationsTable;
  FunnelModel *tempFunnlModel;
  NSArray *randomColors;
}
@end
