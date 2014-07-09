//
//  AppDelegate.h
//  FunnlMail
//
//  Created by Daniel Judd on 3/26/14.
//  Copyright (c) 2014 FunnlMail. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MenuViewController.h"
#import "MMDrawerController.h"
#import "FunnelModel.h"
#import "MBProgressHUD.h"

@class MenuViewController;
@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) MenuViewController *menuController;
@property (strong, nonatomic) MMDrawerController * drawerController;
@property (strong, nonatomic) MBProgressHUD *progressHUD;
@property (strong, nonatomic) UIActivityIndicatorView *appActivityIndicator;
@property (strong, nonatomic) NSString *currentFunnelString;
@property (strong, nonatomic) FunnelModel *currentFunnelDS;
@property BOOL funnelUpDated;
@end
