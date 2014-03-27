//
//  MailViewController.h
//  FunnlMail
//
//  Created by Daniel Judd on 3/26/14.
//  Copyright (c) 2014 FunnlMail. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MailViewController : UITableViewController

@property (strong, nonatomic) IBOutlet UITableView  *tableView;

@property (strong, nonatomic) NSMutableArray *emails;


@end
