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
#import "Reachability.h"
#import "CIOAPIClient.h"
#import "MainVCDelegate.h"
#import "UIView+Toast.h"
@class MenuViewController;
@class LoginViewController;
@interface AppDelegate : UIResponder <UIApplicationDelegate>
{
    UIView *showWelcomeOverlay;
    BOOL hasStartLoginAlreadyOccured;
    NSString *MIXPANEL_TOKEN;


}
@property (nonatomic,strong)  NSNumber *didLoginIn;
@property (nonatomic, assign) BOOL hasStartLoginAlreadyOccured;
@property (strong, nonatomic)id mainVCControllerInstance;
@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) MenuViewController *menuController;
@property (strong, nonatomic) FunnelModel *currentSelectedFunnlModel;
@property (strong, nonatomic) MMDrawerController * drawerController;
@property (strong, nonatomic) MBProgressHUD *progressHUD;
@property (strong, nonatomic) UIActivityIndicatorView *appActivityIndicator;
@property (strong, nonatomic) NSString *currentFunnelString;
@property (strong, nonatomic) FunnelModel *currentFunnelDS;
@property (strong, nonatomic) NSDate *startDate;
@property (strong, nonatomic) LoginViewController *loginViewController;
@property (strong, nonatomic) CIOAPIClient *contextIOAPIClient;
@property (assign, nonatomic) BOOL isAlreadyRequestedRefreshToken;
@property (assign, nonatomic) BOOL isPullToRefresh;
@property (strong, nonatomic) UIView *headerViewForMailDetailView;
@property (weak) id<MainVCDelegate> mainVCdelegate;
@property (strong,nonatomic) UIButton* letsGo;
@property (strong,nonatomic) UIActivityIndicatorView *activityIndicator;
@property (strong,nonatomic) UINavigationController *navControllerForCentralView;
@property (strong,nonatomic) NSOperationQueue *previewDownloadQueue;
@property (strong,nonatomic) NSOperationQueue *previewDownloadQueueForSecondary;
@property (assign, nonatomic) BOOL isFreshInstall;
@property (retain, nonatomic) NSString *loggedInEmailAddress;

@property BOOL funnelUpDated,internetAvailable;
-(void)showWelcomeOverlay;
-(void)trackMixpanelAnalytics;
-(void)hideWelcomeOverlay:(id)sender;
//public function for loading VIP funnl View (newly added)
- (void)loadVIPFunnelViewController;
- (NSString *)getInitials:(NSString *)string;
- (void)downloadMessageFromNotification:(NSString *)mesageID;
@end
