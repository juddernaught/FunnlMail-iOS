//
//  AppDelegate.m
//  FunnlMail
//
//  Created by Daniel Judd on 3/26/14.
//  Copyright (c) 2014 FunnlMail. All rights reserved.
//

#import "AppDelegate.h"
#import "SQLiteDatabase.h"
#import "ServiceTests.h"
#import <Mixpanel/Mixpanel.h>
#import <Parse/Parse.h>
#import "CIOExampleAPIClient.h"
#import "MainVC.h"
#import "LoginViewController.h"
#import "EmailService.h"
#import "EmailServersService.h"
#import <Crashlytics/Crashlytics.h>
#import "GTMOAuth2ViewControllerTouch.h"

#define MIXPANEL_TOKEN @"08b1e55d72f1b22a8e5696c2b56a6777"

@implementation AppDelegate
@synthesize menuController,drawerController,appActivityIndicator,currentFunnelString,currentFunnelDS,progressHUD,funnelUpDated,loginViewController,mainVCControllerInstance,internetAvailable,contextIOAPIClient;


#pragma mark - didFinishLaunching
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.internetAvailable = YES;
    
    [Crashlytics startWithAPIKey:@"44e1f44afdbcda726d1a42fdbbd770dff98bca43"];
    // MixPanel setup
    //[[CIOExampleAPIClient sharedClient] clearCredentials];
    [Mixpanel sharedInstanceWithToken:@"08b1e55d72f1b22a8e5696c2b56a6777"];
    [[Mixpanel sharedInstance] track:@"App opened"];
    // Parse setup
    [Parse setApplicationId:@"oXAOrMLIRzLNZh50VZ3sk3LBEfUuNDXuLZVBvHdV"
                  clientKey:@"Z5mFEsiX7xTXYlKYKXMbN2zlqqf97l39E0PzZoZg"];
    [application registerForRemoteNotificationTypes:UIRemoteNotificationTypeBadge|
     UIRemoteNotificationTypeAlert|
     UIRemoteNotificationTypeSound];
    funnelUpDated = FALSE;
    progressHUD = [[MBProgressHUD alloc] init];
    //initializing currentFunnelString to "All"
    currentFunnelString = ALL_FUNNL;
    currentFunnelDS = nil;
    appActivityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(320 - 20 - 10, 10, 20, 20)];
    //FunnlViewController *fvc = [[FunnlViewController alloc] init];
    //self.window.rootViewController = fvc;
  
    //
    // initialize the database by referencing the shared instance
    //
    [SQLiteDatabase sharedInstance];
  
    //
    // run database tests
    //
    //[ServiceTests runTests];
  
    loginViewController = [[LoginViewController alloc]init];
    loginViewController.view.backgroundColor = [UIColor clearColor];
    self.window.backgroundColor = [UIColor whiteColor];
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:loginViewController];
    self.window.rootViewController = nav;
    self.startDate = [NSDate date];

    UIPageControl *pageControl = [UIPageControl appearance];
    pageControl.pageIndicatorTintColor = [UIColor lightGrayColor];
    pageControl.currentPageIndicatorTintColor = [UIColor blackColor];
    pageControl.backgroundColor = [UIColor whiteColor];
    
    Reachability * reach = [Reachability reachabilityForInternetConnection];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
    [reach startNotifier];
    [self reachabilityChanged:[NSNotification notificationWithName:kReachabilityChangedNotification object:reach]];
    
    contextIOAPIClient = [[CIOAPIClient alloc] initWithConsumerKey:kContextIOConsumerKey consumerSecret:kContextIOConsumerSecret];
    [contextIOAPIClient checkSSKeychainDataForNewInstall];
    if(contextIOAPIClient.isAuthorized){
        NSLog(@"---- ContextIO is Already authorized ----- accessToken: %@",contextIOAPIClient.description);
//        [self.loginViewController performSelector:@selector(fetchContacts) withObject:nil afterDelay:0.1];
//        [self.loginViewController performSelectorInBackground:@selector(fetchContacts) withObject:nil];
    }
    
    // Override point for customization after application launch.
    return YES;
}

#pragma mark - Rechability
-(void)reachabilityChanged:(NSNotification*)note
{
    Reachability * reach = [note object];
    NSLog(@"%@ %d %@", reach.currentReachabilityFlags,reach.currentReachabilityStatus,reach.currentReachabilityString);
    
    //if(reach.currentReachabilityStatus == NotReachable)
    if([reach.currentReachabilityString isEqualToString:@"No Connection"])
    {
        NSLog(@"------------- Internet is OFF ---------------");
        //[[[UIAlertView alloc] initWithTitle:@"Funnl" message:@"Internet is not available." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
        self.internetAvailable = NO;
        [self.loginViewController callOffline];
        if(self.loginViewController && self.loginViewController.mainViewController && self.loginViewController.mainViewController.emailsTableViewController){
            [self.loginViewController.mainViewController.emailsTableViewController.tablecontroller.refreshControl endRefreshing];
        }
    }
    else
    {
        NSLog(@"------------- Internet is ON ---------------");
        //EmailServerModel *serverModel = [[[EmailServersService instance] allEmailServers] objectAtIndex:0];
        //if(serverModel.accessToken == nil || serverModel.accessToken.length == 0){
            NSLog(@"------------- refresh Access Token ---------------");
            if(self.loginViewController && self.loginViewController.mainViewController && self.loginViewController.mainViewController.emailsTableViewController){
                [self.loginViewController.mainViewController.emailsTableViewController.tablecontroller.refreshControl endRefreshing];
            }
            [self.loginViewController refreshAccessToken];
            
        //}
        self.internetAvailable = YES;
    }
}

#pragma mark - Welcome Overlay

-(void)showWelcomeOverlay{
    showWelcomeOverlay = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, HEIGHT)];
    showWelcomeOverlay.opaque = NO;
    showWelcomeOverlay.backgroundColor = CLEAR_COLOR;
    showWelcomeOverlay.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.5];
    NSString *htmlPath = [[NSBundle mainBundle] pathForResource:@"index" ofType:@"html"];

    [showWelcomeOverlay  loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:htmlPath]]];
    [self.window addSubview:showWelcomeOverlay];
    [self.window bringSubviewToFront:showWelcomeOverlay];
}
                          
-(void)hideWelcomeOverlay{
    [showWelcomeOverlay removeFromSuperview];
}

#pragma mark - applicationWillResignActive

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    [self endInterval];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    self.startDate = [NSDate date];
    
    if([EmailService instance].emailsTableViewController){
        NSLog(@"-----applicationDidBecomeActive-----");
        [self.loginViewController refreshAccessToken];
    }
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [self endInterval];

}

//saves the amount of time spent in app
-(void)endInterval{
    NSTimeInterval time = [self.startDate timeIntervalSinceNow];
    //timeIntervalSinceNow returns negative value so this is required to convert to positive
    NSInteger ti = 0 - (NSInteger)time;
    //I know some of these look stupid and could be dont faster, but when i tried ((ti % 60)/60) it would return 00.000
    //which is mostly unuseable
    float secondsInDecimal = (ti % 60);
    float minutes = (ti / 60);
    float time2 = (float)(secondsInDecimal/60) + minutes;
    NSLog(@"Time: %@",[NSString stringWithFormat:@"%02f + %02f = %02f", minutes, (secondsInDecimal/60), time2]);
    [[Mixpanel sharedInstance] track:@"Time Open" properties:@{@"Time": [NSString stringWithFormat:@"%02f", time2]}];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    // Store the deviceToken in the current installation and save it to Parse.
    NSLog(@"didRegisterForRemoteNotificationsWithDeviceToken: %@",deviceToken);
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    NSString *loggedInEmail = [EmailService instance].userEmailID;
    if ([loggedInEmail length]) {
        if (![currentInstallation channels]) {
            [currentInstallation setChannels:@[loggedInEmail]];
        }
        [currentInstallation addUniqueObject:@"aUser" forKey:loggedInEmail];
    }
    [currentInstallation setDeviceTokenFromData:deviceToken];
    [currentInstallation saveInBackground];
}

- (void)application:(UIApplication *)application
didReceiveRemoteNotification:(NSDictionary *)userInfo {
    NSLog(@"didReceiveRemoteNotification: %@",userInfo);
    [PFPush handlePush:userInfo];
}

@end
