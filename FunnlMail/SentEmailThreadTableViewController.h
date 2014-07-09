//
//  SentEmailThreadTableViewController.h
//  FunnlMail
//
//  Created by Pranav Herur on 7/5/14.
//  Copyright (c) 2014 FunnlMail. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FunnelModel.h"
#import "MainVCDelegate.h"
#import "MCSwipeTableViewCell.h"
#import "MessageService.h"
#import "EmailCell.h"
#import "MsgViewController.h"

@interface SentEmailThreadTableViewController : UIViewController <UITableViewDataSource,UITableViewDelegate>
{
    NSString *gmailThreadId;
}
@property (strong, nonatomic) NSArray *dataSourceArray;
@property (strong, nonatomic) UITableView *emailThreadTable;
@property (weak) id<MainVCDelegate> mainVCdelegate;
- (id)initWithGmailThreadID:(NSString*)gmailThreadID;
@end

