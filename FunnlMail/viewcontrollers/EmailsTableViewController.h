//
//  EmailsTableViewController.h
//  FunnlMail
//
//  Created by Daniel Judd on 5/26/14.
//  Copyright (c) 2014 FunnlMail. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MCSwipeTableViewCell.h"
#import "RDSwipeableTableViewCell.h"
#import "MessageService.h"
#import "EmailThreadTableViewController.h"
// FIXME: are these two imports neccessary?
#import "FunnelModel.h"
#import "MainVCDelegate.h"
#import "AppDelegate.h"

@interface EmailsTableViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UISearchDisplayDelegate,MCSwipeTableViewCellDelegate,RDSwipeableTableViewCellDelegate> {
    RDSwipeableTableViewCell *tempCellForDisplay;
    UIView *filterNavigationView;
    UILabel *filterLabel;
    UISearchBar *mailSearchBar;
    UISearchDisplayController *searchDisplayController;
    NSArray *funnlArray;
    AppDelegate *tempAppDelegate;
    NSIndexPath *currentIndexPath;
    NSTimer *loadNextMsgTimer;
@public
    NSMutableArray *searchMessages;
}
@property BOOL isSearching;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, strong) UITableViewController *tablecontroller;
@property (nonatomic, strong) NSArray *messages;
@property (nonatomic, strong) UITableView *tableView;
@property (strong,nonatomic) FunnelModel *filterModel;
@property (weak) id<MainVCDelegate> mainVCdelegate;
@property (strong,nonatomic) NSString *emailFolder;
@property (nonatomic) int ClearTable;
@property (nonatomic) NSInteger totalNumberOfInboxMessages;
@property (nonatomic) BOOL isLoading;
@property (nonatomic, strong) UIActivityIndicatorView *loadMoreActivityView;
-(void) setFilterModel:(FunnelModel *)filterModel;
- (void)resetSearchBar;
@end
