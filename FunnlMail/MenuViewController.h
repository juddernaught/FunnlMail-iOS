//
//  MenuViewController.h
//  FunnlMail
//
//  Created by macbook on 6/4/14.
//  Copyright (c) 2014 FunnlMail. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MenuCell.h"
#import "AppDelegate.h"
@interface MenuViewController : UIViewController <UITableViewDataSource,UITableViewDelegate>
{
    UITableView *listView;
    NSMutableArray *listArray,*imageArray;
}
@end
