//
//  LoginViewController.m
//  FunnlMail
//
//  Created by Daniel Judd on 4/19/14.
//  Copyright (c) 2014 FunnlMail. All rights reserved.
//

#import "LoginViewController.h"
#import "MainVC.h"
#import "KeychainItemWrapper.h"
#import "GTMOAuth2ViewControllerTouch.h"
#import <mailcore/mailcore.h>
#import "EmailService.h"
#import "View+MASAdditions.h"
#import "MASConstraintMaker.h"
#import "UIColor+HexString.h"
#import "AppDelegate.h"
#import "EmailServersService.h"
#import <Mixpanel/Mixpanel.h>
#import "PageContentVC.h"
#import "CIOExampleAPIClient.h"
#import "CIOAuthViewController.h"
#import "CIOAPIClient.h"
#import "ContactService.h"
#import <Parse/parse.h>
#import "SQLiteDatabase.h"
#import "CIOAPIClient.h"
#import "UIImageView+WebCache.h"


#define accessTokenEndpoint @"https://accounts.google.com/o/oauth2/token"

@interface LoginViewController (){
   
}

@end

@implementation LoginViewController

//static NSString *const kKeychainItemName = @"OAuth2 Sample: Gmail";
//NSString *kMyClientID = @"655269106649-rkom4nvj3m9ofdpg6sk53pi65mpivv7d.apps.googleusercontent.com";     // pre-assigned by service
//NSString *kMyClientSecret = @"1ggvIxWh-rV_Eb9OX9so7aCt";
NSArray *images;
UIButton *loginButton;
//NSString *kMyClientID = @"994627364215-ctjmrhiul95ts0qrkc38sap3mo3go3ko.apps.googleusercontent.com";     // pre-assigned by service
//NSString *kMyClientSecret = @"FNZ-x95gkwWqQT7HdJgeqJVW";
@synthesize blockerView,mainViewController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark - refresh token
-(void)refreshAccessToken{
    AppDelegate *appDelegate = APPDELEGATE;
    if(appDelegate.isAlreadyRequestedRefreshToken == NO){
        NSArray *allServers = [[EmailServersService instance] allEmailServers];
        if (!([allServers count] == 0 || [((EmailServerModel *)[allServers objectAtIndex:0]).refreshToken isEqualToString:@"nil"])) {
            NSLog(@"==== refreshAccessToken === Started");
            appDelegate.isAlreadyRequestedRefreshToken  = YES;
            
            // right now there is only 1 email address allowed
            self.emailServerModel = [[[EmailServersService instance] allEmailServers] objectAtIndex:0];
            
            // Set the HTTP POST parameters required for refreshing the access token.
            NSString *refreshPostParams = [NSString stringWithFormat:@"refresh_token=%@&client_id=%@&client_secret=%@&grant_type=refresh_token",
                                           self.emailServerModel.refreshToken,
                                           kMyClientID,
                                           kMyClientSecret
                                           ];
            
            // Indicate that an access token refresh process is on the way.
            self.isRefreshing = YES;
            
            // Create the request object and set its properties.
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:accessTokenEndpoint]];
            [request setHTTPMethod:@"POST"];
            [request setHTTPBody:[refreshPostParams dataUsingEncoding:NSUTF8StringEncoding]];
            [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
            
            // Make the request.
            [self makeAsyncRequest:request];
            //[self makeRequest:request];
            //[self performSelector:@selector(makeRequest:) withObject:request afterDelay:0.1];
        }
    }
    else{
        NSLog(@"  === Refused another refreshAccessToken request ===  ");
        return;
    }
}

#pragma mark - Offline mode load home screen directly

-(void)callOffline{
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    if(appDelegate.internetAvailable == NO){
        [self performSelector:@selector(loadHomeScreen) withObject:nil afterDelay:1];
    }
}


#pragma mark - viewDidLoad
- (void) viewDidLoad {
    [super viewDidLoad];
    _receivedData = [[NSMutableData alloc] init];
    _isRefreshing = NO;
    
    //AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    blockerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, HEIGHT)];
    blockerView.backgroundColor = [UIColor redColor];
    [self checkCredentialsandShowLoginScreen];
    
    AppDelegate *appDelegate = APPDELEGATE;
    mainViewController = [[MainVC alloc] init];
    [mainViewController.view setBackgroundColor:[UIColor colorWithHexString:@"A7A7A7"]];
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:mainViewController];
    appDelegate.navControllerForCentralView = nav;
    appDelegate.menuController = [[MenuViewController alloc] init];
    appDelegate.drawerController = [[MMDrawerController alloc] initWithCenterViewController:nav leftDrawerViewController:appDelegate.menuController];
    [appDelegate.drawerController setRestorationIdentifier:@"MMDrawer"];
    [appDelegate.drawerController setMaximumLeftDrawerWidth:250.0];
    [appDelegate.drawerController setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeNone];
    [appDelegate.drawerController setCloseDrawerGestureModeMask:MMCloseDrawerGestureModeAll];

}

- (void) viewWillAppear:(BOOL)animated {
    numberOfRetries = 1;
    [[self navigationController] setNavigationBarHidden:YES animated:NO];
}


- (void) viewWillDisappear:(BOOL)animated {
    [[self navigationController] setNavigationBarHidden:YES animated:NO];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) createIntroViewController{
    SPFirstViewController *sController = [[SPFirstViewController alloc] init];
    [self.navigationController presentViewController:sController animated:YES completion:^{    }];
}

-(void) createDemoPageViewController
{
    self.view.backgroundColor = [UIColor colorWithHexString:@"F6F6F6"];
    self.pageController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    self.pageController.dataSource = self;
//    images = @[@"intro slider 1.jpg", @"intro slider 3.jpg", @"intro slider 4.jpg",@"intro slider 5.jpg"];
    images = @[@"intro slider 3.jpg", @"intro slider 4.jpg",@"intro slider 5.jpg"];
    PageContentVC *initialViewController = [self viewControllerAtIndex:0];
    NSArray *viewControllers = [NSArray arrayWithObject:initialViewController];
    self.pageController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height); // Changed from (xx, 0 to 6, ...) by Chad
    
    [self.pageController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    [self addChildViewController:self.pageController];
    [[self view] addSubview:[self.pageController view]];
    
    [self.pageController didMoveToParentViewController:self];
    UIImage *loginImage = [UIImage imageNamed:@"getStarted"];
    loginButton = [[UIButton alloc] init];
    [loginButton setImage:loginImage forState:UIControlStateNormal];
    loginButton.frame = CGRectMake(0, HEIGHT-43, 320, 40); // Changed from (xx, 50 to 43, ...) by Chad
    [loginButton addTarget:self action:@selector(loginButtonSelected)forControlEvents:UIControlEventTouchUpInside];
    loginButton.hidden = YES;
    [loginButton setBackgroundColor:[UIColor clearColor]];
    [self.pageController.view setBackgroundColor:[UIColor clearColor]];
    [self.view setBackgroundColor:[UIColor clearColor]];
    [self.pageController.view addSubview:loginButton];
    
}

- (void)showSecondScreen:(UIButton*)sender {
    NSArray *subViews = [introlView subviews];
    for (UIView *subView in subViews) {
        [subView removeFromSuperview];
    }
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, HEIGHT)];
    [imageView setImage:[UIImage imageNamed:@"introStartPage02.png"]];
    imageView.contentMode = UIViewContentModeTopLeft;
    [introlView addSubview:imageView];
    imageView = nil;
    
    UIButton *nextButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 360/2, WIDTH, 45)];
    UIImage *loginImage = [UIImage imageNamed:@"introSignIn.png"];
    [nextButton setImage:loginImage forState:UIControlStateNormal];
    loginImage = nil;
    nextButton.backgroundColor = [UIColor clearColor];
    [nextButton addTarget:self action:@selector(removeIntoPage:) forControlEvents:UIControlEventTouchUpInside];
    [introlView addSubview:nextButton];
    nextButton = nil;
    [self.view addSubview:introlView];
}

- (void)removeIntoPage:(UIButton *)sender {
    [introlView removeFromSuperview];
    introlView = nil;
}

-(void) checkCredentialsandShowLoginScreen
{
    
    NSLog(@"--checkCredentialsandShowLoginScreen--");
    NSArray *allServers = [[EmailServersService instance] allEmailServers];
    if (!([allServers count] == 0 || [((EmailServerModel *)[allServers objectAtIndex:0]).refreshToken isEqualToString:@"nil"])) {
        AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
        appDelegate.didLoginIn = 0;
        [self performSelector:@selector(refreshAccessToken) withObject:nil afterDelay:0.1];
    }
    else {
        AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
        appDelegate.didLoginIn = @1;
//        NSString *scope = @"https://mail.google.com/"; // scope for Gmail
        NSString *scope = @"https://mail.google.com/ https://www.googleapis.com/auth/userinfo.profile https://www.google.com/m8/feeds "; // scope for Gmail https://www.googleapis.com/auth/gmail.readonly

        if (viewController) {
            [viewController removeFromParentViewController];
            viewController = nil;
        }
        viewController = [[GTMOAuth2ViewControllerTouch alloc] initWithScope:scope
                                                                    clientID:kMyClientID
                                                                clientSecret:kMyClientSecret
                                                            keychainItemName:kKeychainItemName
                                                                    delegate:self
                                                            finishedSelector:@selector(viewController:finishedWithAuth:error:)];
        //to adjust size of webview for login
        viewController.view.frame = CGRectMake(0, 0, WIDTH, HEIGHT);
        
        //--end
        [self addChildViewController:viewController];
        [self.view addSubview:viewController.view];
        
        //for intro screen
        if (![[NSUserDefaults standardUserDefaults] boolForKey:@"displaying_intro_screen"]) {
            [[NSUserDefaults standardUserDefaults] setBool:TRUE forKey:@"displaying_intro_screen"];
            introlView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, HEIGHT)];
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, HEIGHT)];
            [imageView setImage:[UIImage imageNamed:@"introStartPage01.png"]];
            imageView.contentMode = UIViewContentModeTopLeft;
            [introlView addSubview:imageView];
            imageView = nil;
            UIButton *nextButton = [[UIButton alloc] initWithFrame:CGRectMake(0, HEIGHT-56, WIDTH, 35)];
            UIImage *continueImage = [UIImage imageNamed:@"introGetStarted.png"];
            [nextButton setImage:continueImage forState:UIControlStateNormal];
            continueImage = nil;
            nextButton.backgroundColor = [UIColor clearColor];
            [nextButton addTarget:self action:@selector(showSecondScreen:) forControlEvents:UIControlEventTouchUpInside];
            [introlView addSubview:nextButton];
            nextButton = nil;
            [self.view addSubview:introlView];
        }
    }
}

-(void) setDrawerControllerOnWindow
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate.window setRootViewController:appDelegate.drawerController];
}

- (void) loginButtonSelected {
    
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    [self setDrawerControllerOnWindow];
#ifdef TRACK_MIXPANEL
    //[[Mixpanel sharedInstance] track:@"Viewed last slider"];
#endif
    if(appDelegate.didLoginIn) {
        [appDelegate showWelcomeOverlay];
        if ([[[MessageService instance] retrieveAllMessages] count] > 0) {
            [appDelegate.letsGo setHidden:NO];
            [appDelegate.activityIndicator stopAnimating];
            [appDelegate.activityIndicator hidesWhenStopped];
        }
    }
    //[self oauthLogin];
}


- (void) oauthLogin {
    // THIS DOESN'T WORK YET...REFRESH KEY IS LIKELY NEEDED AFTER A CERTAIN PERIOD OF TIME
    //if ([[[EmailServersService instance] allEmailServers] count] == 0 && false) {
    if ([[[EmailServersService instance] allEmailServers] count] > 0) {
        for (EmailServerModel *m in [[EmailServersService instance] allEmailServers]) {
            [[EmailServersService instance] deleteEmailServer:m.emailAddress];
        }
    }
    
    
    // pre-assigned by service
    
   NSString *scope = @"https://mail.google.com/ https://www.googleapis.com/auth/userinfo.profile https://www.google.com/m8/feeds"; // scope for Gmail
    
    GTMOAuth2ViewControllerTouch *viewController;
    viewController = [[GTMOAuth2ViewControllerTouch alloc] initWithScope:scope
                                                                 clientID:kMyClientID
                                                             clientSecret:kMyClientSecret
                                                         keychainItemName:kKeychainItemName
                                                                 delegate:self
                                                         finishedSelector:@selector(viewController:finishedWithAuth:error:)];
    [[self navigationController] pushViewController:viewController animated:YES];
}


- (void)viewController:(GTMOAuth2ViewControllerTouch *)viewController
      finishedWithAuth:(GTMOAuth2Authentication *)auth
                 error:(NSError *)error {
    if (error != nil) {
        NSArray *subViews = [self.view subviews];
        for (UIView *views in subViews) {
            [views removeFromSuperview];
        }
        [self checkCredentialsandShowLoginScreen];

//        [[self navigationController] popViewControllerAnimated:YES];
        // Authentication failed
    } else {
#ifdef TRACK_MIXPANEL
        //[[Mixpanel sharedInstance] track:@"Signed into email"]; // Signed into Gmail
#endif
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"is_tutorial"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [self performSelector:@selector(loadHomeScreenFromFirstLogin) withObject:nil afterDelay:0.1];

        [self createIntroViewController];

            [NSObject cancelPreviousPerformRequestsWithTarget:[EmailService instance]];
//        [[MessageService instance] clearAllTables];
        
            AppDelegate *appDelegate = APPDELEGATE;
            [appDelegate.contextIOAPIClient clearCredentials];
            [SQLiteDatabase sharedInstance];
            [[NSUserDefaults standardUserDefaults] setObject:[NSMutableArray new] forKey: ALL_FUNNL];
            [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"PRIMARY_PAGE_TOKEN"];
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"IS_NEW_INSTALL"];
            [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"MODSEQ"];
            [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"EMAIL_LOGGED_IN"];

            [[NSUserDefaults standardUserDefaults] synchronize];
            [[EmailService instance] clearData];
            [EmailService instance].userEmailID = @"";
            
            NSString * email = [auth userEmail];
            NSString * accessToken = [auth accessToken];
            NSString * refreshToken = [auth refreshToken];
            
            
            self.emailServerModel = [[EmailServerModel alloc] init];
            self.emailServerModel.emailAddress = email;
            self.emailServerModel.accessToken = accessToken;
            self.emailServerModel.refreshToken = refreshToken;
            

            [[EmailServersService instance] insertEmailServer:self.emailServerModel];
            MCOIMAPSession * imapSession = [[MCOIMAPSession alloc] init];
            imapSession.timeout = 60;
            [EmailService instance].imapSession = imapSession;
            [imapSession setAuthType:MCOAuthTypeXOAuth2];
            [imapSession setOAuth2Token:accessToken];
            [imapSession setUsername:email];
            
            MCOSMTPSession * smtpSession = [[MCOSMTPSession alloc] init];
            [smtpSession setAuthType:MCOAuthTypeXOAuth2];
            [smtpSession setOAuth2Token:accessToken];
            [smtpSession setUsername:email];
            smtpSession.hostname = @"smtp.gmail.com";
            smtpSession.port = 465;
            smtpSession.authType = MCOAuthTypeXOAuth2;
            smtpSession.connectionType = MCOConnectionTypeTLS;
            [EmailService instance].smtpSession = smtpSession;

//        AppDelegate *tempAppDelegate = APPDELEGATE;
//        [tempAppDelegate.progressHUD show:YES];
//        [tempAppDelegate.window addSubview:tempAppDelegate.progressHUD];
//        [tempAppDelegate.window bringSubviewToFront:tempAppDelegate.progressHUD];
//        [tempAppDelegate.progressHUD setHidden:NO];
        
        
        /*NSString *urlString = [NSString stringWithFormat:@"https://sustained-tree-595.appspot.com?email=%@&access_token=%@",self.emailServerModel.emailAddress,self.emailServerModel.accessToken];
        //NSString *urlString = [NSString stringWithFormat:@"http://127.0.0.1:8080?email=%@&access_token=%@",self.emailServerModel.emailAddress,self.emailServerModel.accessToken];
        
        //        NSString *paramsString = [NSString stringWithFormat:@"access_token=%@&email=%@",self.emailServerModel.accessToken,self.emailServerModel.emailAddress];
        //        NSData *paramData = [paramsString dataUsingEncoding:NSUTF8StringEncoding];
        NSURL *url = [NSURL URLWithString:urlString];
        NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];
        [req setHTTPMethod:@"GET"];
        //        [req setHTTPBody:paramData];
        [NSURLConnection sendAsynchronousRequest:req queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
            NSString *respString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSArray *vipEmails = [respString componentsSeparatedByString:@"\n\n"];
            NSLog(@"vipEmails %@",vipEmails);
         }];*/
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            

            NSString *post = [NSString stringWithFormat:@"refresh_token=%@", refreshToken];
            NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
            NSString *postLength = [NSString stringWithFormat:@"%lu",(unsigned long)[postData length]];
            NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
            [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://lit-citadel-5624.herokuapp.com/vip"]]];
            [request setHTTPMethod:@"POST"];
            [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
            [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
            [request setHTTPBody:postData];
            [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                
                if(connectionError){
                    NSLog(@"******** ------ VIP ERROR ******* : %@",connectionError.description);

                    return;
                }
                NSString *respString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                NSLog(@" ******* ------ VIP response: %@",respString);
                
                //storing contact string onto persistance storage.
                [[NSUserDefaults standardUserDefaults] setObject:respString forKey:@"contact_string"];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }];
        });
    

        // Authentication succeeded
        //[self createDemoPageViewController];


        
    }
}

-(void)getContextIOWithEmail:(NSString*)email withName:(NSString*)name{
//
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    if(![appDelegate.contextIOAPIClient isAuthorized]){
        
        NSMutableDictionary *checkParams = [[NSMutableDictionary alloc] init];
        [checkParams setObject:email forKey:@"email"];
    
        
        [appDelegate.contextIOAPIClient getPath:@"lite/users" params:checkParams success:^(NSDictionary *responseDict) {
            NSLog(@"getContextIOWithEmail 1 : Check if Account already exists----- %@",responseDict.description);

            NSString *accountID = @"";
            if([responseDict isKindOfClass:[NSArray class]] && responseDict.count){
                NSArray *newArray = (NSArray*)responseDict;
                NSDictionary *dictionary = [newArray objectAtIndex:0];
                accountID = [dictionary objectForKey:@"id"];
            }
            
            if(accountID.length){
                NSLog(@"---account found");
    
                PFInstallation *currentInstallation = [PFInstallation currentInstallation];
                [currentInstallation setObject:email forKey:@"email"];
                if (![currentInstallation channels]) {
                    [currentInstallation setChannels:@[]];
                }
                [currentInstallation addUniqueObject:[NSString stringWithFormat:@"account_id_%@", accountID] forKey:@"channels"];

                [currentInstallation saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    NSInteger errCode = [error code];
                    if (kPFErrorConnectionFailed == errCode ||  kPFErrorInternalServer == errCode)
                        [currentInstallation saveEventually];
                }];
                
                // initialize parse objects to store the subject and sender criteria for webhooks
                PFObject *webhooksParseObject = [PFObject objectWithClassName:PARSE_WEBHOOK_CLASS];
                webhooksParseObject[PARSE_WEBHOOK_SENDER] = @[];
                webhooksParseObject[PARSE_WEBHOOK_SUBJECT] = @[];
                webhooksParseObject[@"account_id"] = accountID;
                [webhooksParseObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    [[NSUserDefaults standardUserDefaults] setObject:webhooksParseObject.objectId forKey:PARSE_WEBHOOK_CLASS];
                }];
                
                NSMutableDictionary *newTokenParams = [[NSMutableDictionary alloc] init];
                [newTokenParams setObject:email forKey:@"email"];
                [newTokenParams setObject:@"cio-api-auth://" forKey:@"callback_url"];

                [appDelegate.contextIOAPIClient postPath:@"lite/connect_tokens" params:newTokenParams success:^(id responseObject) {
                    NSDictionary *newDictionary = (NSDictionary*)responseObject;
                    NSLog(@"Getting new connect tokens success  ----- %@",newDictionary.description);
                 
                    NSString *contextIO_access_token = @"";
                    NSString *contextIO_access_token_secret = @"";
                    if([newDictionary objectForKey:@"access_token"])
                        contextIO_access_token = [newDictionary objectForKey:@"access_token"];
                    if([newDictionary objectForKey:@"access_token_secret"])
                        contextIO_access_token_secret = [newDictionary objectForKey:@"access_token_secret"];
                    
                    appDelegate.contextIOAPIClient = [[CIOAPIClient alloc] initWithConsumerKey:kContextIOConsumerKey consumerSecret:kContextIOConsumerSecret token:contextIO_access_token tokenSecret:contextIO_access_token_secret accountID:accountID];
                    [appDelegate.contextIOAPIClient saveCredentials];
                    [self performSelector:@selector(addToSourceWithAccountID:) withObject:accountID afterDelay:0.01];

                    
                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                    NSLog(@"Getting new connect tokens failed  ----- %@",error.userInfo.description);
                }];
            }
            else{
                NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
                [params setObject:email forKey:@"email"];
                [params setObject:name forKey:@"first_name"];
                [params setObject:name forKey:@"last_name"];
                
                [appDelegate.contextIOAPIClient postPath:@"lite/users" params:params success:^(NSDictionary *responseDict) {
                    NSLog(@"getContextIOWithEmail  2 - Create New UserInfo ----- %@",responseDict.description);
                    NSString *contextIO_access_token = [responseDict objectForKey:@"access_token"];
                    NSString *contextIO_access_token_secret = [responseDict objectForKey:@"access_token_secret"];
                    NSString *contextIO_account_id = [responseDict objectForKey:@"id"];
                    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
                    [currentInstallation setObject:email forKey:@"email"];
                    if (![currentInstallation channels]) {
                        [currentInstallation setChannels:@[]];
                    }
                    [currentInstallation addUniqueObject:[NSString stringWithFormat:@"account_id_%@", contextIO_account_id] forKey:@"channels"];
                    [currentInstallation saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                        NSInteger errCode = [error code];
                        if (kPFErrorConnectionFailed == errCode ||  kPFErrorInternalServer == errCode)
                            [currentInstallation saveEventually];
                    }];
                    // initialize parse objects to store the subject and sender criteria for webhooks
                    PFObject *webhooksParseObject = [PFObject objectWithClassName:PARSE_WEBHOOK_CLASS];
                    webhooksParseObject[PARSE_WEBHOOK_SENDER] = @[];
                    webhooksParseObject[PARSE_WEBHOOK_SUBJECT] = @[];
                    webhooksParseObject[@"account_id"] = accountID;
                    [webhooksParseObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                        [[NSUserDefaults standardUserDefaults] setObject:webhooksParseObject.objectId forKey:PARSE_WEBHOOK_CLASS];
                    }];
                    appDelegate.contextIOAPIClient = [[CIOAPIClient alloc] initWithConsumerKey:kContextIOConsumerKey consumerSecret:kContextIOConsumerSecret token:contextIO_access_token tokenSecret:contextIO_access_token_secret accountID:contextIO_account_id];
                    [appDelegate.contextIOAPIClient saveCredentials];
                    
                    [self performSelector:@selector(addToSourceWithAccountID:) withObject:contextIO_account_id afterDelay:0.01];
                    
                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                    
                    NSLog(@"error getting getContextIOWithEmail: %@", error);
                }];
            }
            
            
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"error getting getContextIOWithEmail: %@", error);
        }];
        
        
    }
}

-(void)getAllWebhooksAndDeleteIt{
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    [appDelegate.contextIOAPIClient getWebhooksWithParams:nil success:^(NSArray *responseArray) {
        __block int reqCnt = (int)[responseArray count];
        if ([responseArray count] != 0) {
            for (NSDictionary *dictionary in responseArray) {
                NSString *webhookID = [dictionary objectForKey:@"webhook_id"];
                if(webhookID && webhookID.length){
                    [appDelegate.contextIOAPIClient deleteWebhookWithID:webhookID success:^(NSDictionary *responseDict) {
                        reqCnt--;
                        if(reqCnt == 0){
                            [self performSelector:@selector(createFirstTimeNotifs) withObject:nil afterDelay:0.01];
                        }
                    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                        reqCnt--;
                        if(reqCnt == 0){
                            [self performSelector:@selector(createFirstTimeNotifs) withObject:nil afterDelay:0.01];
                        }
                    }];
                }
            }
        }
        else {
            [self performSelector:@selector(createFirstTimeNotifs) withObject:nil afterDelay:0.01];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self performSelector:@selector(createFirstTimeNotifs) withObject:nil afterDelay:0.01];
    }];
}

-(void)createFirstTimeNotifs{
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    // turn on all notifs for first time user
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"NOTIFS_ON_FIRST_TIME"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [appDelegate.contextIOAPIClient createWebhookWithCallbackURLString:@"http://funnlmail.parseapp.com/send_notification2" failureNotificationURLString:@"http://funnlmail.parseapp.com/failure" params:params success:^(NSDictionary *responseDict) {
        NSString *webhook_id = [responseDict objectForKey:@"webhook_id"];
        [[NSUserDefaults standardUserDefaults] setObject:webhook_id forKey:@"ALL_NOTIFS_ON_WEBHOOK_ID"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        NSLog(@"********* createFirstTimeNotifs: SUCCUSS : %@",webhook_id);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"createFirstTimeNotifs: FAILURE : %@",error.userInfo.description);
    }];
}

-(void)addToSourceWithAccountID:(NSString*)accID{
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:self.emailServerModel.emailAddress forKey:@"email"];
    [params setObject:self.emailServerModel.emailAddress forKey:@"username"];
    [params setObject:@"993" forKey:@"port"];
    [params setObject:@"IMAP" forKey:@"type"];
    [params setObject:@"1" forKey:@"use_ssl"];
    [params setObject:@"imap.googlemail.com" forKey:@"server"];
    [params setObject:self.emailServerModel.refreshToken forKey:@"provider_refresh_token"];
    [params setObject:kMyClientID forKey:@"provider_consumer_key"];
    //[params setObject:kMyClientSecret forKey:@"provider_token_secret"];
    NSString *path = [NSString stringWithFormat:@"https://api.context.io/lite/users/%@/email_accounts",accID];
    [appDelegate.contextIOAPIClient postPath:path params:params success:^(NSDictionary *responseDict) {
        NSLog(@"-----> %@",responseDict.description);
        [self performSelector:@selector(getAllWebhooksAndDeleteIt) withObject:nil afterDelay:0.01];

    
        //[self performSelector:@selector(fetchContacts) withObject:nil afterDelay:20];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        // this gets called when user downloads app fresh for first time but already has existing Context.IO account

        NSLog(@"-----> error getting addToSourceWithAccountID: %@", error);
        [self performSelector:@selector(getAllWebhooksAndDeleteIt) withObject:nil afterDelay:0.01];

    }];
}

-(void)fetchContacts{
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    //    [appDelegate.contextIOAPIClient getContactsWithParams:nil success:^(NSDictionary *responseDict) {
        [appDelegate.contextIOAPIClient getContactsWithParams:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"0",@"10000",nil] forKeys:[NSArray arrayWithObjects:@"offset",@"limit",nil]] success:^(NSDictionary *responseDict) {
            NSArray *dataArray = [responseDict objectForKey:@"matches"];
            NSMutableArray *contactModelArray = [NSMutableArray new];
            if(dataArray){
                for (NSDictionary *dictionary in dataArray) {
                    ContactModel *cModel = [[ContactModel alloc] init];
                    cModel.name = [dictionary objectForKey:@"name"];
                    cModel.email = [dictionary objectForKey:@"email"];
                    cModel.thumbnail = [dictionary objectForKey:@"thumbnail"];
                    cModel.count = [[dictionary objectForKey:@"count"] integerValue];
                    cModel.received_count = [[dictionary objectForKey:@"received_count"] integerValue];
                    cModel.sent_from_account_count = [[dictionary objectForKey:@"sent_from_account_count"] integerValue];
                    cModel.sent_count = [[dictionary objectForKey:@"sent_count"] integerValue];
                    
                    if(cModel.name == nil)
                        cModel.name = @"";
                    if(cModel.email == nil)
                        cModel.email = @"";
                    if(cModel.thumbnail == nil)
                        cModel.thumbnail = @"";
                    
                    [contactModelArray addObject:cModel];
                }
                [[ContactService instance] insertBulkContacts:contactModelArray];
            }
            NSLog(@"fetchContacts ----- %@",responseDict.description);
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"error  fetchContacts: %@", error);
        }];
    });
}

#pragma mark -
#pragma mark Retrieving Contact (NEW)
#pragma mark getUserContact
-(void)getUserContact{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://www.google.com/m8/feeds/contacts/%@/full?alt=json&max-results=%d",[EmailService instance].userEmailID,INT32_MAX]];

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPMethod:@"GET"];
    
    GTMOAuth2Authentication *currentAuth = [GTMOAuth2ViewControllerTouch authForGoogleFromKeychainForName:kKeychainItemName clientID:kMyClientID clientSecret:kMyClientSecret];
    GTMHTTPFetcher* myFetcher = [GTMHTTPFetcher fetcherWithRequest:request];
    [myFetcher setAuthorizer:currentAuth];
    [myFetcher beginFetchWithCompletionHandler:^(NSData *retrievedData, NSError *error) {
        if (error != nil) {
            // status code or network error
            NSLog(@"--user info error %@: ", [error description]);
//            NSString* newStr = [[NSString alloc] initWithData:retrievedData encoding:NSUTF8StringEncoding];
//            NSLog(@"user Info: %@",newStr);
        } else {
            // succeeded
            NSMutableArray *contactArray = [[NSMutableArray alloc] init];
//            NSString* newStr = [[NSString alloc] initWithData:retrievedData encoding:NSUTF8StringEncoding];
//            NSLog(@"user Info: %@",newStr);
            NSDictionary* json = [NSJSONSerialization JSONObjectWithData:retrievedData options:kNilOptions error:&error];
            dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                NSDictionary *feedDict = [json objectForKey:@"feed"];
                NSDictionary *contacts = [feedDict objectForKey:@"entry"];
                for (NSDictionary *contactDict in contacts) {
                    ContactModel *tempContact = [[ContactModel alloc] init];
                    tempContact.name = [[contactDict objectForKey:@"title"] objectForKey:@"$t"];
                    NSArray *emailArray = [contactDict objectForKey:@"gd$email"];
                    
                    if (emailArray.count > 0) {
                        if ([[emailArray objectAtIndex:0] objectForKey:@"address"]) {
                            tempContact.email = [[emailArray objectAtIndex:0] objectForKey:@"address"];
                        }
                    }
                    else {
                        //when we don't have email id we put string @"nil"
                        tempContact.email = @"nil";
                    }
                    emailArray = nil;
                    
                    NSArray *linkArray = [contactDict objectForKey:@"link"];
                    if (linkArray.count > 0) {
                        for (NSDictionary *tempLinkDict in linkArray) {
                            if ([[tempLinkDict objectForKey:@"type"] isEqualToString:@"image/*"]) {
                                tempContact.thumbnail = [tempLinkDict objectForKey:@"href"];
                                break;
                            }
                        }
                    }
                    linkArray = nil;
                    
                    //set default value for rest of contact parameters
                    tempContact.count = 0;
                    tempContact.sent_count = 0;
                    tempContact.sent_from_account_count = 0;
                    tempContact.received_count = 0;
                    tempContact.resource_url = @"nil";
                    if (![tempContact.email isEqualToString:@"nil"]) {
                        [contactArray addObject:tempContact];
                    }
                    else {
                        NSLog(@"----rec---");
                    }
                }
                
                [[ContactService instance] insertBulkContacts:contactArray];
            });
        }

    }];
}


-(void)getUserInfo{
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    NSURL *url = [NSURL URLWithString:@"https://www.googleapis.com/oauth2/v2/userinfo?alt=json"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPMethod:@"GET"];
    
    GTMOAuth2Authentication *currentAuth = [GTMOAuth2ViewControllerTouch authForGoogleFromKeychainForName:kKeychainItemName clientID:kMyClientID clientSecret:kMyClientSecret];
    GTMHTTPFetcher* myFetcher = [GTMHTTPFetcher fetcherWithRequest:request];
    [myFetcher setAuthorizer:currentAuth];
    [myFetcher beginFetchWithCompletionHandler:^(NSData *retrievedData, NSError *error) {
        if (error != nil) {
          // status code or network error
            NSLog(@"--user info error %@: ", [error description]);
        } else {
          // succeeded
//            NSString* newStr = [[NSString alloc] initWithData:retrievedData encoding:NSUTF8StringEncoding];
//            NSLog(@"user Info: %@",newStr);
            NSDictionary* json = [NSJSONSerialization JSONObjectWithData:retrievedData options:kNilOptions error:&error];
            
            NSString* currentEmail = [json objectForKey:@"email"];
            NSString* currentName = [json objectForKey:@"name"];
            NSString* currentUserImageURL = [json objectForKey:@"picture"];
            
            [[NSUserDefaults standardUserDefaults] setObject:currentEmail forKey:@"EMAIL_LOGGED_IN"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            appDelegate.loggedInEmailAddress = [[NSString alloc] initWithString:currentEmail];

#ifdef TRACK_MIXPANEL
            AppDelegate *appDelegate = APPDELEGATE;
            NSArray *excludeArray = TRACKING_EXCLUDE_USERS_ARRAY;
            Mixpanel *mixpanel = [Mixpanel sharedInstance];

            if([excludeArray containsObject:appDelegate.loggedInEmailAddress] == NO){
                [mixpanel identify: appDelegate.loggedInEmailAddress];
                if(appDelegate.isFreshInstall == NO){
                    [[Mixpanel sharedInstance] track:@"first time user logged in"];
                    [mixpanel.people set:@{@"User has visited funnel store": @0}];
                    [mixpanel.people set:@{@"User has created funnel from VIP": @0}];
                    [mixpanel.people set:@{@"User swiped to create funnel": @0}];
                    [mixpanel.people set:@{@"funnel count": @0}];
                }
                [mixpanel.people set:@{@"Email" : currentEmail}];
                [mixpanel.people set:@{@"User name" : currentName}];
                [mixpanel.people set:@{@"$email" : currentEmail}];
            }
#endif
            
            [EmailService instance].userEmailID = currentEmail;
            [EmailService instance].userImageURL = currentUserImageURL;
            [EmailService instance].currentName = currentName;

            if(![appDelegate.contextIOAPIClient isAuthorized]){

                //[self getContextIOWithEmail:currentEmail withFirstName:currentName withLastName:currentName];
                //[self getContextIOWithEmail:currentEmail withName:currentName];
                dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    [self performSelector:@selector(getContextIOWithEmail:withName:) withObject:currentEmail withObject:currentName];
                });
            }
            else{
                /*PFInstallation *currentInstallation = [PFInstallation currentInstallation];
                if (![currentInstallation channels]) {
                    [currentInstallation setChannels:@[]];
                }
                [currentInstallation addUniqueObject:[NSString stringWithFormat:@"account_id_%@", appDelegate.contextIOAPIClient._accountID] forKey:@"channels"];
                NSString *s = [NSString stringWithFormat:@"account_id_%@", appDelegate.contextIOAPIClient._accountID];
                

                NSArray *array = currentInstallation.channels;
                [currentInstallation setObject:currentEmail forKey:@"email"];
                [currentInstallation saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    NSInteger errCode = [error code];
                    if (kPFErrorConnectionFailed == errCode ||  kPFErrorInternalServer == errCode)
                        [currentInstallation saveEventually];
                }];*/
            }
            NSLog(@"what is currntNam: %@",[EmailService instance].currentName);
            
            //dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                NSArray *array = [[ContactService instance] getAllContacts];
                if(array.count == 0){
                        [self performSelector:@selector(getUserContact) withObject:nil afterDelay:0.1];

                }
            //});
            //[self performSelectorInBackground:@selector(getUserContact) withObject:nil];

            [[NSUserDefaults standardUserDefaults] synchronize];
            [EmailService instance].primaryMessages = [NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults] objectForKey: ALL_FUNNL]];
            NSString *nextPageToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"PRIMARY_PAGE_TOKEN"];
            if(nextPageToken == nil || nextPageToken.length <= 0){
                nextPageToken = @"";
            }
            
            
            NSString *imageUrl = [EmailService instance].userImageURL;
            dispatch_async(dispatch_get_main_queue(), ^{
            if([imageUrl hasPrefix:@"http"]){
                [appDelegate.menuController.userImageView setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:[UIImage imageNamed:@"userimage-placeholder.png"] options:SDWebImageProgressiveDownload completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType){
                }];
            }
            else
                appDelegate.menuController.userImageView.image = [UIImage imageNamed:@"userimage-placeholder.png"];
            
            appDelegate.menuController.userNameLabel.text = currentName;
            appDelegate.menuController.emailLabel.text = currentEmail;
//            [appDelegate.menuController.listArray replaceObjectAtIndex:0 withObject:currentName];
//            [appDelegate.menuController.imageArray replaceObjectAtIndex:0 withObject:[EmailService instance].userImageURL];
            [appDelegate.menuController.listView reloadData];
            });
            
            NSLog(@"email: %@", currentEmail);
            [self getPrimaryMessages:currentEmail nextPageToken:nextPageToken numberOfMaxResult:100];
        }
    }];
}

-(void)getPrimaryMessages:(NSString*)emailStr nextPageToken:(NSString*)nextPage numberOfMaxResult:(NSInteger)maxResult{
    NSString *newAPIStr = @"";

    if(nextPage.length){
        newAPIStr = [NSString stringWithFormat:@"https://www.googleapis.com/gmail/v1/users/%@/messages?fields=messages(id,labelIds,threadId),nextPageToken&pageToken=%@&labelIds=CATEGORY_PERSONAL&maxResults=%d",emailStr,nextPage,maxResult];
    }
    else{
        newAPIStr = [NSString stringWithFormat:@"https://www.googleapis.com/gmail/v1/users/%@/messages?fields=messages(id,labelIds,threadId),nextPageToken&labelIds=CATEGORY_PERSONAL&maxResults=%d",emailStr,maxResult];
    }
    
    NSURL *url = [NSURL URLWithString:newAPIStr];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPMethod:@"GET"];
    
    GTMOAuth2Authentication *currentAuth = [GTMOAuth2ViewControllerTouch authForGoogleFromKeychainForName:kKeychainItemName clientID:kMyClientID clientSecret:kMyClientSecret];
    GTMHTTPFetcher* myFetcher = [GTMHTTPFetcher fetcherWithRequest:request];
    [myFetcher setAuthorizer:currentAuth];
    [myFetcher beginFetchWithCompletionHandler:^(NSData *retrievedData, NSError *error) {
        if (error != nil) {
            // status code or network error
            NSLog(@"******* --Message info error %@: ", [error description]);
            if(numberOfRetries < 3){
                NSString *nextPageToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"PRIMARY_PAGE_TOKEN"];
                if(nextPageToken == nil || nextPageToken.length <= 0){
                    nextPageToken = @"";
                }
                [[Mixpanel sharedInstance] track:@"Primary Fails" properties:@{@"retries":[NSNumber numberWithInt:numberOfRetries]}];
                [self getPrimaryMessages:emailStr nextPageToken:nextPageToken numberOfMaxResult:100];
                numberOfRetries++;
            }
            else{
                [self startFirstTimeLogin];
            }
            
        } else {
            // succeeded
            NSString* newStr = [[NSString alloc] initWithData:retrievedData encoding:NSUTF8StringEncoding];
            NSDictionary* json = [NSJSONSerialization JSONObjectWithData:retrievedData options:kNilOptions error:&error];
            NSArray* messageArray =[json objectForKey:@"messages"];
            NSString *nextPageToken = [json objectForKey:@"nextPageToken"];
            for (NSDictionary *dictionary in messageArray) {
                NSString *messageID = [dictionary objectForKey:@"id"];
                if(![[EmailService instance].primaryMessages containsObject:messageID])
                    [[EmailService instance].primaryMessages addObject:messageID];
            }
            //NSLog(@"Message Info Count:%d      nextPageToken: %@    Total Count:%d",messageArray.count,nextPageToken,[[EmailService instance].primaryMessages count]);

            NSMutableArray *pArray = [[EmailService instance] primaryMessages];
            [[NSUserDefaults standardUserDefaults] setObject:pArray forKey: ALL_FUNNL];
            [[NSUserDefaults standardUserDefaults] setObject:nextPageToken forKey:@"PRIMARY_PAGE_TOKEN"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            if([[EmailService instance] userEmailID].length > 0){
                if([EmailService instance].primaryMessages.count < NUMBER_OF_MESSAGES_TO_LOAD_AT_START )
                    if(nextPageToken == nil){
                       [self startFirstTimeLogin];
                    }
                    else{
                        [self getPrimaryMessages:emailStr nextPageToken:nextPageToken numberOfMaxResult:100];
                    }
                else{
                    [self startFirstTimeLogin];
                    NSLog(@"----- Primary messages count > %d",pArray.count);
                }
                    
            }
            else{
                [self startFirstTimeLogin];
                
                NSLog(@"----- Clean Primary > %d",pArray.count);
                [EmailService instance].primaryMessages = [[NSMutableArray alloc] init];
                [[EmailService instance].primaryMessages removeAllObjects];
                [[NSUserDefaults standardUserDefaults] setObject:[[EmailService instance] primaryMessages] forKey: ALL_FUNNL];
                [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"PRIMARY_PAGE_TOKEN"];
            }
        }
    }];

}


-(void) startFirstTimeLogin{
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    // Krunal : Commented below line 26 aug
    if(appDelegate.internetAvailable){
        //        [[EmailService instance] performSelectorInBackground:@selector(startLogin:) withObject:self.mainViewController.emailsTableViewController];
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [[EmailService instance] startLogin:self.mainViewController.emailsTableViewController];
        });
        //[[EmailService instance] startLogin:self.mainViewController.emailsTableViewController];
    }
}

-(void)loadHomeScreenFromFirstLogin {
    NSLog(@"*****************  In loadhomescreen ***************** ");
    [self performSelector:@selector(getUserInfo) withObject:nil afterDelay:0.2];
    
    
    // Below is the startLogin method which is working 4 out of 5 times till date 2nd Oct, commented this logic 3rd oct
    // To revert to previous logic uncomment previous logic and commment all the other method calls for startFirstTimeLogin in this files
    //[self startFirstTimeLogin];
    
}

-(void)loadHomeScreen {
    NSLog(@"*****************  In loadhomescreen ***************** ");
    [self performSelector:@selector(getUserInfo) withObject:nil afterDelay:0.2];

    /*dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
         [self performSelector:@selector(getUserInfo) withObject:nil afterDelay:0.2];
    });*/

    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    // Krunal : Commented below line 26 aug
    if(appDelegate.internetAvailable){
//        [[EmailService instance] performSelectorInBackground:@selector(startLogin:) withObject:self.mainViewController.emailsTableViewController];
        /*dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [[EmailService instance] startLogin:self.mainViewController.emailsTableViewController];
        });*/
        [[EmailService instance] startLogin:self.mainViewController.emailsTableViewController];
    }
    
    
    //expilictly calling the view to start the background loading emails
    //[appDelegate.drawerController view];
    //[mainViewController view];
    //[appDelegate.menuController view];
    
//    NSURL *url = [NSURL URLWithString:@"https://singular-hub-642.appspot.com"];
//    [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:url] queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
//        NSString *respString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//        NSArray *vipEmails = [respString componentsSeparatedByString:@"\n\n"];
//        NSLog(@"vipEmails %@",vipEmails);
//    }];
    
//    [self.navigationController presentViewController:appDelegate.drawerController animated:NO completion:nil];
//    AppDelegate *tempAppDelegate = APPDELEGATE;
//    [tempAppDelegate.progressHUD show:NO];
//    [tempAppDelegate.progressHUD setHidden:YES];

}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(void)makeRequest:(NSMutableURLRequest *)request{
    // Set the length of the _receivedData mutableData object to zero.
    [_receivedData setLength:0];
    
    // Make the request.
    _urlConnection = [NSURLConnection connectionWithRequest:request delegate:self  ];
}

#pragma NSURLConnection delegate methdods

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [_receivedData appendData:data];
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection {
    AppDelegate *appDelegate = APPDELEGATE;
    // This object will be used to store the converted received JSON data to string.
    NSString *responseJSON;
    
    // This flag indicates whether the response was received after an API call and out of the
    // following cases.
    BOOL isAPIResponse = YES;
    
    // Convert the received data in NSString format.
    responseJSON = [[NSString alloc] initWithData:(NSData *)_receivedData encoding:NSUTF8StringEncoding];
    
    // Check for access token.
    if ([responseJSON rangeOfString:@"access_token"].location != NSNotFound) {
        // This is the case where the access token has been fetched.
        NSError *error;
        if (error) {
            NSLog(@"%@", error);
        }
        NSDictionary *accessTokenInfoDictionary = [NSJSONSerialization JSONObjectWithData:_receivedData options:NSJSONReadingMutableContainers error:&error];
        NSString *accessToken = [accessTokenInfoDictionary objectForKey:@"access_token"];
        if(accessToken == nil) {
            NSLog(@"====> Invalid access Token");
        }
        else{
            appDelegate.isAlreadyRequestedRefreshToken  = NO;
            self.emailServerModel.accessToken = [NSString stringWithFormat:@"%@",accessToken];
            [[EmailServersService instance] updateEmailServer:self.emailServerModel];
            //[self performSelector:@selector(getUserInfo) withObject:nil afterDelay:0.2];

        }
        
        
        if (self.isRefreshing) {
            self.isRefreshing = NO;
        }

        // Notify the caller class that the authorization was successful.
        NSLog(@"%@", @"successfully fetched access token from refresh token");
        isAPIResponse = NO;
    }
    
    MCOIMAPSession * imapSession = [[MCOIMAPSession alloc] init];
    [[EmailService instance].imapSession cancelAllOperations];
    [[EmailService instance].imapSession disconnectOperation];
    [EmailService instance].imapSession = imapSession;
    [EmailService instance].imapSession.hostname = @"imap.google.com";
    [EmailService instance].imapSession.port = 993;
    
    [imapSession setAuthType:MCOAuthTypeXOAuth2];
    [imapSession setOAuth2Token:self.emailServerModel.accessToken];
    [imapSession setUsername:self.emailServerModel.emailAddress];
    imapSession.connectionType = MCOConnectionTypeTLS;

    MCOSMTPSession * smtpSession = [[MCOSMTPSession alloc] init];
    [smtpSession setAuthType:MCOAuthTypeXOAuth2];
    [smtpSession setOAuth2Token:self.emailServerModel.accessToken];
    [smtpSession setUsername:self.emailServerModel.emailAddress];
    smtpSession.hostname = @"smtp.gmail.com";
    smtpSession.port = 465;
    smtpSession.authType = MCOAuthTypeXOAuth2;
    smtpSession.connectionType = MCOConnectionTypeTLS;
    [EmailService instance].smtpSession = smtpSession;
    [self loadHomeScreen];
    [self setDrawerControllerOnWindow];

}
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    
}

-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    [_receivedData setLength:0];
}

- (PageContentVC *)viewControllerAtIndex:(NSUInteger)index {
    PageContentVC *childViewController = [[PageContentVC alloc] initWithImage:[images objectAtIndex:index]];
    childViewController.index = index;
    return childViewController;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {

    NSUInteger index = [(PageContentVC *)viewController index];
    if (index == 0) {
        return nil;
    }
    loginButton.hidden = YES;
    
    // Decrease the index by 1 to return
    index--;
    return [self viewControllerAtIndex:index];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    NSUInteger index = [(PageContentVC *)viewController index];
    index++;
    if (index == images.count) {
        loginButton.hidden = NO;
        return nil;
    }
    else loginButton.hidden = YES;
    return [self viewControllerAtIndex:index];
    
}

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController {
    // The number of items reflected in the page indicator.
    return images.count;
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController {
    // The selected item reflected in the page indicator.
    return 0;
}


#pragma mark - Async Request

-(void)makeAsyncRequest:(NSMutableURLRequest*)request{
    [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        //If data were received
        if (data) {
            //Convert to string
            AppDelegate *appDelegate = APPDELEGATE;
            // This object will be used to store the converted received JSON data to string.
            NSString *responseJSON;
            
            // This flag indicates whether the response was received after an API call and out of the
            // following cases.
            BOOL isAPIResponse = YES;
            
            // Convert the received data in NSString format.
            responseJSON = [[NSString alloc] initWithData:(NSData *)data encoding:NSUTF8StringEncoding];
            
            // Check for access token.
            if ([responseJSON rangeOfString:@"access_token"].location != NSNotFound) {
                // This is the case where the access token has been fetched.
                NSError *error;
                if (error) {
                    NSLog(@"Login error -- %@", error);
                }
                NSDictionary *accessTokenInfoDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
                NSString *accessToken = [accessTokenInfoDictionary objectForKey:@"access_token"];
                if(accessToken == nil) {
                    NSLog(@"Async-----Invalid access Token");
                }
                else{
                    appDelegate.isAlreadyRequestedRefreshToken  = NO;
                    self.emailServerModel.accessToken = [NSString stringWithFormat:@"%@",accessToken];
                    [[EmailServersService instance] updateEmailServer:self.emailServerModel];
                    //[self performSelector:@selector(getUserInfo) withObject:nil afterDelay:0.2];
                }
                
                
                if (self.isRefreshing) {
                    self.isRefreshing = NO;
                }
                
                // Notify the caller class that the authorization was successful.
                NSLog(@"%@", @"successfully fetched access token from refresh token");
                isAPIResponse = NO;
            }
            
            MCOIMAPSession * imapSession = [[MCOIMAPSession alloc] init];
            [[EmailService instance].imapSession cancelAllOperations];
            [[EmailService instance].imapSession disconnectOperation];
            [EmailService instance].imapSession = imapSession;
            [EmailService instance].imapSession.hostname = @"imap.google.com";
            [EmailService instance].imapSession.port = 993;
            
            [imapSession setAuthType:MCOAuthTypeXOAuth2];
            [imapSession setOAuth2Token:self.emailServerModel.accessToken];
            [imapSession setUsername:self.emailServerModel.emailAddress];
            imapSession.connectionType = MCOConnectionTypeTLS;
            
            MCOSMTPSession * smtpSession = [[MCOSMTPSession alloc] init];
            [smtpSession setAuthType:MCOAuthTypeXOAuth2];
            [smtpSession setOAuth2Token:self.emailServerModel.accessToken];
            [smtpSession setUsername:self.emailServerModel.emailAddress];
            smtpSession.hostname = @"smtp.gmail.com";
            smtpSession.port = 465;
            smtpSession.authType = MCOAuthTypeXOAuth2;
            smtpSession.connectionType = MCOConnectionTypeTLS;
            [EmailService instance].smtpSession = smtpSession;

            // SHOULD WE GET HERE???
            NSLog(@"startLogin from makeAsyncRequest");
            [[EmailService instance] startLogin:self.mainViewController.emailsTableViewController];

            
            
        }
        //No data received
        else {
            
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self loadHomeScreen];
            [self setDrawerControllerOnWindow];
        });
    }];
    
    
}


@end
