//
//  MainVC.h
//  FunnlMail
//
//  Created by Michael Raber on 3/29/14.
//  Copyright (c) 2014 FunnlMail. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EmailsTableViewController.h"
#import "MainVCDelegate.h"
//#import "FilterModel.h"
#import "FunnelModel.h"
#import "EmailThreadTableViewController.h"

@class MainView;
@interface MainVC : UIViewController<MainVCDelegate>{
//  MainView *mainView;
  EmailThreadTableViewController *threadViewController;
  FunnelModel *currentFilterModel;
    UILabel *filterLabel;
    UILabel *navigationBarTitleLabel;
    UIButton *menuButton;
    UIButton *filterButton;
    UIButton *composeEmailButton;
    
}
@property (nonatomic, strong) UISegmentedControl *segmentControl;
@property (nonatomic, retain) MainView *mainView;
@property (nonatomic, strong) EmailsTableViewController *emailsTableViewController;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;
@property (strong,nonatomic) FunnelModel *filterModel;
@property (strong,nonatomic) NSNumber *firstTime;
- (void)segmentControllerClicked:(UISegmentedControl*)sender;
@end
