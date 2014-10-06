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
#import <HockeySDK/HockeySDK.h>
#import "VIPViewController.h"
#import "MTStatusBarOverlay.h"


@implementation AppDelegate
@synthesize menuController,drawerController,appActivityIndicator,currentFunnelString,currentFunnelDS,progressHUD,funnelUpDated,loginViewController,mainVCControllerInstance,internetAvailable,contextIOAPIClient,isAlreadyRequestedRefreshToken,currentSelectedFunnlModel,isPullToRefresh,navControllerForCentralView, hasStartLoginAlreadyOccured;
@synthesize mainVCdelegate,letsGo,activityIndicator;
@synthesize previewDownloadQueue,isFreshInstall,loggedInEmailAddress;

#pragma mark - didFinishLaunchingx
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{   //[[UIApplication sharedApplication] setApplicationIconBadgeNumber:99]; //added by Chad
    
#if IS_RELEASE == 1
    MIXPANEL_TOKEN = @"9373e7f6b57abde608b47abf2f2f8326";
#else
    MIXPANEL_TOKEN = @"3335353d90043594517928ae8ec453f7";
#endif

    
    NSLog(@"---> %@",MIXPANEL_TOKEN);
    
    [self initializeQueue];
    application.applicationIconBadgeNumber = 0;

    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"latest_tt_secondary"]) {
        [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:@"latest_tt_secondary"];
    }
     
    self.internetAvailable = YES;
    isAlreadyRequestedRefreshToken = NO;
    [Crashlytics startWithAPIKey:@"44e1f44afdbcda726d1a42fdbbd770dff98bca43"];
    // MixPanel setup
    //[[CIOExampleAPIClient sharedClient] clearCredentials];

    [Mixpanel sharedInstanceWithToken:MIXPANEL_TOKEN];
    
    
#ifdef TRACK_MIXPANEL
    //[[Mixpanel sharedInstance] track:@"Launched App"]; //Launched app
    [[NSUserDefaults standardUserDefaults] synchronize];
    isFreshInstall = [[NSUserDefaults standardUserDefaults] boolForKey:@"IS_FRESH_INSTALL"];
    if(isFreshInstall == NO){
        [[Mixpanel sharedInstance] track:@"first time user opened app"];
    }
    
#endif
    // Parse setup
    //[Parse setApplicationId:@"oXAOrMLIRzLNZh50VZ3sk3LBEfUuNDXuLZVBvHdV" clientKey:@"Z5mFEsiX7xTXYlKYKXMbN2zlqqf97l39E0PzZoZg"];
    [Parse setApplicationId:@"qRBmYEJxZ6xOYq2Z6UZuz3nqcuy14DxTV63gWnb4" clientKey:@"ZPCELYRnO4YOnm2nXw8J9Y34poNsMvgGuWzPw1rV"];

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
    pageControl.backgroundColor = UIColorFromRGB(0xF7F7F7);
    
    Reachability * reach = [Reachability reachabilityForInternetConnection];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
    [reach startNotifier];
    [self reachabilityChanged:[NSNotification notificationWithName:kReachabilityChangedNotification object:reach]];
    
    contextIOAPIClient = [[CIOAPIClient alloc] initWithConsumerKey:kContextIOConsumerKey consumerSecret:kContextIOConsumerSecret];
    [contextIOAPIClient checkSSKeychainDataForNewInstall];
    if(contextIOAPIClient.isAuthorized){
        NSLog(@"---- ContextIO is Already authorized ----- accessToken: %@",contextIOAPIClient.description);
        // turning on webhooks by default
        if (![[NSUserDefaults standardUserDefaults] boolForKey:@"NOTIFS_ON_FIRST_TIME"]) {
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"NOTIFS_ON_FIRST_TIME"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
            [contextIOAPIClient createWebhookWithCallbackURLString:@"http://funnlmail.parseapp.com/send_notification" failureNotificationURLString:@"http://funnlmail.parseapp.com/failure" params:params success:^(NSDictionary *responseDict) {
                NSString *webhook_id = [responseDict objectForKey:@"webhook_id"];
                [[NSUserDefaults standardUserDefaults] setObject:webhook_id forKey:@"ALL_NOTIFS_ON_WEBHOOK_ID"];
                [[NSUserDefaults standardUserDefaults] synchronize];
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                NSLog(@"createWebhooksandSaveFunnl --- deleteWebhookWithID : %@",error.userInfo.description);
            }];
            
        }
//        [self.loginViewController performSelectorInBackground:@selector(fetchContacts) withObject:nil];
    }
    
#if TARGET_OS_IPHONE

    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
        //Right, that is the point
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:(UIRemoteNotificationTypeBadge
                                                                                             |UIRemoteNotificationTypeSound
                                                                                             |UIRemoteNotificationTypeAlert) categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    }
    else {
        //register to receive notifications
        [application registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge |
                                                         UIRemoteNotificationTypeAlert |
                                                         UIRemoteNotificationTypeSound)];
    }
#endif
    
    // setting up HockeyApp
    // nocommit: must change app identifier
#if IS_DAILY_BUILD == 1
    //This is used for DAILY builds --- 
    [[BITHockeyManager sharedHockeyManager] configureWithIdentifier:@"1c04170556ba64478f0ace210db67c5a"];
#else
    [[BITHockeyManager sharedHockeyManager] configureWithIdentifier:@"c210d26de33e613330b327e98d2bb97f"];
#endif
    
    //this forces HockeyManager not to report crashes and thus, crashlytics will start crashreporting again
    //[[BITHockeyManager sharedHockeyManager] setDisableCrashManager:YES];
    
    [[BITHockeyManager sharedHockeyManager] startManager];
    [[BITHockeyManager sharedHockeyManager].authenticator authenticateInstallation];

    
    // Override point for customization after application launch.
    return YES;
}

- (void)initializeQueue {
    previewDownloadQueue = [[NSOperationQueue alloc] init];
    previewDownloadQueue.maxConcurrentOperationCount = CONCURRENCY_TASK;
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
        //[[[UIAlertView alloc] initWithTitle:@"Funnel" message:@"Internet is not available." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
        self.internetAvailable = NO;
        self.isAlreadyRequestedRefreshToken = NO;
        [self.loginViewController callOffline];
        if(self.loginViewController && self.loginViewController.mainViewController && self.loginViewController.mainViewController.emailsTableViewController){
            [self.loginViewController.mainViewController.emailsTableViewController.tablecontroller.refreshControl endRefreshing];
        }
    }
    else
    {
            self.isAlreadyRequestedRefreshToken = NO;
            //EmailServerModel *serverModel = [[[EmailServersService instance] allEmailServers] objectAtIndex:0];
            //if(serverModel.accessToken == nil || serverModel.accessToken.length == 0){
            NSLog(@"------------- Internet ON - Call Refresh Access Token ---------------");
            if(self.loginViewController && self.loginViewController.mainViewController && self.loginViewController.mainViewController.emailsTableViewController){
                [self.loginViewController.mainViewController.emailsTableViewController.tablecontroller.refreshControl endRefreshing];
            }
            [self.loginViewController performSelector:@selector(refreshAccessToken) withObject:nil afterDelay:0.1];
            
        //}
        self.internetAvailable = YES;
    }
}

-(void)createLabel:(UILabel*)label{
    
    label.backgroundColor = [UIColor grayColor];
    label.textColor = [UIColor redColor];
    //[showWelcomeOverlay addSubview:label];
}

#pragma mark - Welcome Overlay

-(void)showWelcomeOverlay{
    
    showWelcomeOverlay = [[UIView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, HEIGHT)];
    showWelcomeOverlay.opaque = NO;
    
    UITextView *thing = [[UITextView alloc]initWithFrame:CGRectMake(25, 80, WIDTH - 60, 135 - 70)];
    if (HEIGHT == 480) {
        thing.frame = CGRectMake(25, 70, WIDTH - 60, 135 - 70);
    }
//    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    if([EmailService instance].currentName){
        thing.text =[NSString stringWithFormat: @"Welcome %@, to your\ncustomized Primary inbox!",[EmailService instance].currentName.capitalizedString];
    }
    else{
        thing.text =[[NSString stringWithFormat: @"Welcome %@, to your\ncustomized Primary inbox!",@""] capitalizedString];
    }
    
    
    thing.backgroundColor = [UIColor clearColor];
    [thing setTextColor:[UIColor whiteColor]];
//    thing.font = [UIFont boldSystemFontOfSize:18];
    thing.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:17];
    thing.userInteractionEnabled = NO;
    
    UIImageView *imageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"welcome.png"]];
    imageView.frame = CGRectMake(0, 0, WIDTH, HEIGHT);
    
#ifdef TRACK_MIXPANEL
    //[[Mixpanel sharedInstance] track:@"Viewed intro overlay"];
#endif
    
  
    
    [showWelcomeOverlay addSubview:imageView];
    
    [showWelcomeOverlay addSubview: thing];
    [showWelcomeOverlay bringSubviewToFront:thing];
    showWelcomeOverlay.backgroundColor = CLEAR_COLOR;
//    showWelcomeOverlay.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.78];
    
    letsGo = [UIButton buttonWithType:UIButtonTypeCustom];
    letsGo.frame = CGRectMake(WIDTH-40, 20, 30, 30);
    [letsGo setTitle:@"X" forState:UIControlStateNormal];
    [letsGo setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [letsGo addTarget:self action:@selector(hideWelcomeOverlay:) forControlEvents:UIControlEventTouchUpInside];
    [[letsGo layer] setBorderWidth:2.0f];
    [[letsGo layer] setBorderColor:[UIColor whiteColor].CGColor];
    letsGo.layer.cornerRadius = 15;
//    [letsGo.layer setCornerRadius:3.0];
    [showWelcomeOverlay addSubview:letsGo];
    letsGo.hidden = YES;
    [showWelcomeOverlay bringSubviewToFront:letsGo];
    
    [self.window addSubview:showWelcomeOverlay];
    [self.window bringSubviewToFront:showWelcomeOverlay];
    
    activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [activityIndicator setFrame:CGRectMake(WIDTH-50, 95, 25, 25)];
    [showWelcomeOverlay addSubview:activityIndicator];
    [activityIndicator startAnimating];
}


-(void)trackMixpanelAnalytics{
#ifdef TRACK_MIXPANEL
    EmailService *emailService = [EmailService instance];
    AppDelegate *appDelegate = APPDELEGATE;
    NSArray *excludeArray = TRACKING_EXCLUDE_USERS_ARRAY;
    if(emailService.userEmailID && emailService.userEmailID.length && [excludeArray containsObject:appDelegate.loggedInEmailAddress] == NO )
    {
        Mixpanel *mixpanel = [Mixpanel sharedInstance];
        [mixpanel identify:appDelegate.loggedInEmailAddress];

        //NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] initWithObjects:[NSArray arrayWithObjects:emailService.userEmailID,emailService.currentName, nil]forKeys:[NSArray arrayWithObjects:@"Email",@"Name", nil]];
        //[[Mixpanel sharedInstance] track:@"Signed In" properties:dictionary];
        
        NSMutableArray *allMessagesArray = (NSMutableArray*)[[MessageService instance] messagesAllTopMessages];
        
        if(allMessagesArray.count){
            NSMutableArray *trackPrimaryArray = (NSMutableArray*)[[MessageService instance] retrieveAllMessages];
            float primaryPercentage =  ((float)trackPrimaryArray.count /(float)allMessagesArray.count ) * 100;
            //NSMutableDictionary *trackPrimaryDictionary = [[NSMutableDictionary alloc] initWithObjects:[NSArray arrayWithObjects:emailService.userEmailID,[NSNumber numberWithInt:(int)trackPrimaryArray.count], [NSNumber numberWithFloat:primaryPercentage], nil]forKeys:[NSArray arrayWithObjects:@"Email",@"PrimaryMailsCount",@"PrimaryPercentage", nil]];
            //[[Mixpanel sharedInstance] track:@"Total Number of Primary Mails" properties:trackPrimaryDictionary];
            [mixpanel.people set:@{@"Percentage Primary Mails":[NSNumber numberWithFloat:primaryPercentage]}];
            
            NSMutableArray *funnlArray  =  (NSMutableArray*)[[FunnelService instance] getFunnelsExceptAllFunnel];
            NSMutableArray *totalNumberFunnlsArray = [[NSMutableArray alloc] init];
            for (FunnelModel *f in funnlArray) {
                NSMutableArray *tArray = (NSMutableArray*)[[MessageService instance] messagesWithFunnelId:f.funnelId top:20000];
                [totalNumberFunnlsArray addObjectsFromArray:tArray];
                
            }
            float funnlPercentage =   (float)( (float)totalNumberFunnlsArray.count / (float)allMessagesArray.count ) * 100;
            //NSMutableDictionary *trackFunnlDictionary = [[NSMutableDictionary alloc] initWithObjects:[NSArray arrayWithObjects:emailService.userEmailID,[NSNumber numberWithInt:(int)funnlArray.count], [NSNumber numberWithInt:(int)totalNumberFunnlsArray.count], [NSNumber numberWithFloat:funnlPercentage],nil]forKeys:[NSArray arrayWithObjects:@"Email",@"Total Funnls", @"Total Mails in Funnl",@"FunnlPercentage", nil]];
            //[[Mixpanel sharedInstance] track:@"Total Number of Funnl Mails" properties:trackFunnlDictionary];
            [mixpanel.people set:@{@"Percentage Funnel Mails":[NSNumber numberWithFloat:funnlPercentage]}];
            
        }else{
            
        }
        
    }
#endif
}

-(IBAction)hideWelcomeOverlay:(id)sender{
    [activityIndicator stopAnimating];
    [showWelcomeOverlay removeFromSuperview];
#ifdef TRACK_MIXPANEL
    [self trackMixpanelAnalytics];
#endif
    //newly added line for VIP funnl
    if (IS_VIP_ENABLED) {
        
        [self performSelector:@selector(loadVIPFunnelViewController) withObject:nil afterDelay:kVIP_FUNNEL_POP_UP_DISPLY_INTERVAL];
    }
}

//loading VIP funnl
- (void)loadVIPFunnelViewController {
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"VIP_FUNNL_APPERANCE"] == NO)
    {
        if (navControllerForCentralView) {
            VIPViewController *viewController = [[VIPViewController alloc] init];
            UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:viewController];
            [navController.view setBackgroundColor:[UIColor clearColor]];
            [navControllerForCentralView presentViewController:navController animated:YES completion:nil];
        }
        else {
            if (IS_VIP_ENABLED) {
                [self performSelector:@selector(loadVIPFunnelViewController) withObject:nil afterDelay:kVIP_FUNNEL_POP_UP_DISPLY_INTERVAL];
            }
        }
    }
    else {
        
    }
}

#pragma mark - applicationWillResignActive

- (void)applicationWillResignActive:(UIApplication *)application
{
//    if(loggedInEmailAddress.length > 0){
        [[Mixpanel sharedInstance] track:@"app closed"];
//    }

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
//    NSLog(@"%@",[[EmailService instance] userEmailID]);
    [[NSUserDefaults standardUserDefaults] synchronize];
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"EMAIL_LOGGED_IN"]){
        loggedInEmailAddress = [[NSString alloc] initWithString:[[NSUserDefaults standardUserDefaults] objectForKey:@"EMAIL_LOGGED_IN"]];
    }
    else{
        loggedInEmailAddress = @"";
    }

    
#ifdef TRACK_MIXPANEL
//    if(loggedInEmailAddress.length > 0){
        [[Mixpanel sharedInstance] track:@"app opened"];
        
        Mixpanel *mixpanel = [Mixpanel sharedInstance];
        [mixpanel timeEvent:@"app closed"];
//  }
#endif
    
    
    
    application.applicationIconBadgeNumber = 0;
    if ([[EmailService instance] userEmailID] && ![[[EmailService instance] userEmailID] isEqualToString:@""] && [[NSUserDefaults standardUserDefaults] boolForKey:@"is_tutorial"] == NO) {
        MTStatusBarOverlay *overlay = [MTStatusBarOverlay sharedInstance];
        [overlay hide];
        [overlay postImmediateMessage:@"Downloading..." animated:YES];
        [overlay setDefaultStatusBarImage:[UIImage imageNamed:@""]];
        overlay.animation = MTStatusBarOverlayAnimationShrink;  // MTStatusBarOverlayAnimationShrink
        overlay.detailViewMode = MTDetailViewModeHistory;         // enable automatic history-tracking and show in detail-view
        overlay.tag = 1;
        overlay.progress = 0.0;
        UIImageView *statusBarBackgroundImageView_ = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, 20)];
		statusBarBackgroundImageView_.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		[overlay addSubviewToBackgroundView:statusBarBackgroundImageView_];

        [self performSelector:@selector(dismissStatusBar) withObject:nil afterDelay:10];
    }
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    self.startDate = [NSDate date];
    isAlreadyRequestedRefreshToken = NO;

    NSLog(@"-----applicationDidBecomeActive-----");
    if(self.loginViewController && [[NSUserDefaults standardUserDefaults] boolForKey:@"is_tutorial"] == NO){
        NSLog(@"-----Call Refresh Token -----");
        self.isAlreadyRequestedRefreshToken = NO;
        if(!self.didLoginIn)
            self.didLoginIn = 0;
        [[EmailService instance] setIsfetchingOperationActive:NO];

        EmailService *emailService = [EmailService instance];
        if(emailService.userEmailID && emailService.userEmailID.length)
        {
            [self trackMixpanelAnalytics];
        }
            
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            [self.loginViewController refreshAccessToken];
        });
    }
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [self endInterval];

    [[Mixpanel sharedInstance] track:@"app closed"];
}

- (void)dismissStatusBar {
    MTStatusBarOverlay *overlay = [MTStatusBarOverlay sharedInstance];
    [overlay hide];
}

//saves the amount of time spent in app
-(void)endInterval{
    NSTimeInterval time = [self.startDate timeIntervalSinceNow];
    //timeIntervalSinceNow returns negative value so this is required to convert to positive
    NSInteger ti = 0 - (NSInteger)time;
    //I know some of these look stupid and could be done faster, but when i tried ((ti % 60)/60) it would return 00.000
    //which is mostly unuseable
    float secondsInDecimal = (ti % 60);
    float minutes = (ti / 60);
    float time2 = (float)(secondsInDecimal/60) + minutes;
    NSLog(@"Time: %@",[NSString stringWithFormat:@"%02f + %02f = %02f", minutes, (secondsInDecimal/60), time2]);
#ifdef TRACK_MIXPANEL
    //[[Mixpanel sharedInstance] track:@"Time Open" properties:@{@"Time": [NSString stringWithFormat:@"%02f", time2]}];
#endif
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    // Store the deviceToken in the current installation and save it to Parse.
    //NSString* deviceTokenStr = [NSString stringWithUTF8String:[deviceToken bytes]];
    NSLog(@"didRegisterForRemoteNotificationsWithDeviceToken: %@",deviceToken);
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    NSString *loggedInEmail = [EmailService instance].userEmailID;
    [currentInstallation setChannels:@[]];
    [currentInstallation setObject:@"" forKey:@"email"];
    //[currentInstallation addUniqueObject:@"testers2" forKey:@"channels"];
    
    if ([loggedInEmail length]) {
        if (![currentInstallation channels] || [currentInstallation channels].count == 0) {
            [currentInstallation setChannels:@[loggedInEmail]];
        }
        [currentInstallation addUniqueObject:@"aUser" forKey:loggedInEmail];
    }
    NSLog(@"didRegisterForRemoteNotificationsWithDeviceToken: %@",currentInstallation.deviceToken);
    [currentInstallation setDeviceTokenFromData:deviceToken];
    [currentInstallation saveInBackground];
}

- (void)application:(UIApplication *)application
didReceiveRemoteNotification:(NSDictionary *)userInfo {
    NSLog(@"didReceiveRemoteNotification: %@",userInfo);
    [PFPush handlePush:userInfo];
}

- (NSString *)getInitials:(NSString *)string {
    NSString *returnString = nil;
    if (string.length) {
        returnString = [string substringWithRange:NSMakeRange(0, 1)];
    }
    return returnString;
}

#pragma mark UIView Animation

@end
