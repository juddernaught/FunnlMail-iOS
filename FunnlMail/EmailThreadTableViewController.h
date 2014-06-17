//
//  EmailThreadTableViewController.h
//  FunnlMail
//
//  Created by iauro001 on 6/17/14.
//  Copyright (c) 2014 FunnlMail. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FunnelModel.h"
#import "MainVCDelegate.h"
#import "MCSwipeTableViewCell.h"
#import "MessageService.h"
#import "EmailCell.h"
#import "MsgViewController.h"

@interface EmailThreadTableViewController : UIViewController <UITableViewDataSource,UITableViewDelegate>
{
    NSString *gmailThreadId;
}
@property (strong, nonatomic) NSArray *dataSourceArray;
@property (strong, nonatomic) UITableView *emailThreadTable;
@property (weak) id<MainVCDelegate> mainVCdelegate;
- (id)initWithGmailThreadID:(NSString*)gmailThreadID;
@end
