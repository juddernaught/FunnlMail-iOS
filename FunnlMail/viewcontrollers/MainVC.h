//
//  MainVC.h
//  FunnlMail
//
//  Created by Michael Raber on 3/29/14.
//  Copyright (c) 2014 FunnlMail. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EmailsTableViewController.h"
#import "MainView.h"
#import "MainVCDelegate.h"
//#import "FilterModel.h"
#import "FunnelModel.h"


@interface MainVC : UIViewController<MainVCDelegate>{
//  MainView *mainView;
  EmailsTableViewController *emailsTableViewController;
  FunnelModel *currentFilterModel;
  UILabel *filterLabel;
    UILabel *navigationBarTitleLabel;
}
@property (nonatomic, retain) MainView *mainView;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;
@property (strong,nonatomic) FunnelModel *filterModel;
@end
