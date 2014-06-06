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
#import "MCSwipeTableViewCell.h"

@interface EmailsTableViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UISearchDisplayDelegate,MCSwipeTableViewCellDelegate> {
    UIView *filterNavigationView;
    UILabel *filterLabel;
    UISearchBar *mailSearchBar;
    UISearchDisplayController *searchDisplayController;
    NSMutableArray *searchMessages;
    BOOL isSearching;
}

@property (nonatomic, strong) NSArray *messages;
@property (nonatomic, strong) UITableView *tableView;
@property (strong,nonatomic) FilterModel *filterModel;
@property (weak) id<MainVCDelegate> mainVCdelegate;
@property (strong,nonatomic) NSString *emailFolder;

@property (nonatomic) NSInteger totalNumberOfInboxMessages;
@property (nonatomic) BOOL isLoading;
@property (nonatomic, strong) UIActivityIndicatorView *loadMoreActivityView;
-(void) setFilterModel:(FilterModel *)filterModel;

@end
