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

}
@property (nonatomic,retain) NSMutableArray *listArray,*imageArray;
@property (nonatomic,retain) UITableView *listView;

@property (nonatomic,retain) UIImageView *userImageView;
@property (nonatomic,retain) UILabel *emailLabel, *userNameLabel;
@end
