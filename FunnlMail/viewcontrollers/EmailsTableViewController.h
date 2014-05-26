//
//  EmailsTableViewController.h
//  FunnlMail
//
//  Created by Daniel Judd on 5/26/14.
//  Copyright (c) 2014 FunnlMail. All rights reserved.
//

#import <UIKit/UIKit.h>

// FIXME: are these two imports neccessary?
#import "FilterModel.h"
#import "MainVCDelegate.h"

@interface EmailsTableViewController : UITableViewController <UITableViewDataSource, UITableViewDelegate> {
    UIView *filterNavigationView;
    UILabel *filterLabel;
}

@property (nonatomic, strong) NSArray *messages;
@property (nonatomic, strong) UITableView *tableView;
@property (strong,nonatomic) FilterModel *filterModel;
@property (weak) id<MainVCDelegate> mainVCdelegate;

@property (nonatomic) NSInteger totalNumberOfInboxMessages;
@property (nonatomic) BOOL isLoading;
@property (nonatomic, strong) UIActivityIndicatorView *loadMoreActivityView;

- (void) startLogin;



@end
