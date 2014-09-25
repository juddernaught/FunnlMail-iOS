//
//  LoginViewController.h
//  FunnlMail
//
//  Created by Daniel Judd on 4/19/14.
//  Copyright (c) 2014 FunnlMail. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MenuViewController.h"
#import "MMDrawerController.h"
#import "EmailServerModel.h"
#import "GTMHTTPFetcher.h"
#import "GTMOAuth2ViewControllerTouch.h"
#import "ContactModel.h"
#import "SPFirstViewController.h"

@class MainVC;
@interface LoginViewController : UIViewController <NSURLConnectionDataDelegate,GTMFetcherAuthorizationProtocol,GTMHTTPFetcherServiceProtocol,UIPageViewControllerDataSource,UIPageViewControllerDelegate>
{
    UIView *introlView;
}
@property (nonatomic, retain) UITextField *username;
@property (nonatomic, retain) UITextField *password;
@property (nonatomic, retain) UIView *blockerView;


// The mutable data object that is used for storing incoming data in each connection.
@property (nonatomic, strong) NSMutableData *receivedData;
// A NSURLConnection object.
@property (nonatomic, strong) NSURLConnection *urlConnection;

@property (nonatomic, strong) EmailServerModel *emailServerModel;
@property (nonatomic, strong) MainVC *mainViewController;
// A flag indicating whether an access token refresh is on the way or not.
@property (nonatomic) BOOL isRefreshing;
@property (nonatomic, strong) NSNumber * firstTime;
@property (strong, nonatomic) UIPageViewController *pageController;
-(void)getPrimaryMessages:(NSString*)emailStr nextPageToken:(NSString*)nextPage numberOfMaxResult:(NSInteger)maxResult;
-(void)refreshAccessToken;
-(void)callOffline;
-(void)fetchContacts;
@end
