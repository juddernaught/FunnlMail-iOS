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

#define accessTokenEndpoint @"https://accounts.google.com/o/oauth2/token"

@interface LoginViewController (){
    NSNumber *didLoginIn;
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
            //[self makeAsyncRequest:request];
            [self performSelector:@selector(makeRequest:) withObject:request afterDelay:0.1];
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
    didLoginIn = 0;
    _receivedData = [[NSMutableData alloc] init];
    _isRefreshing = NO;
    
    //AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    blockerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, HEIGHT)];
    blockerView.backgroundColor = [UIColor redColor];
    [self checkCredentialsandShowLoginScreen];
}

- (void) viewWillAppear:(BOOL)animated {
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


-(void) createDemoPageViewController
{
    self.view.backgroundColor = [UIColor colorWithHexString:@"F6F6F6"];
    self.pageController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    self.pageController.dataSource = self;
    images = @[@"WHITEsliders1nobar.png", @"WHITEsliders2.png", @"WHITEsliders3.png", @"WHITEsliders4.png",@"WHITEsliders5.png"];
    PageContentVC *initialViewController = [self viewControllerAtIndex:0];
    NSArray *viewControllers = [NSArray arrayWithObject:initialViewController];
    self.pageController.view.frame = CGRectMake(0, 6, self.view.frame.size.width, self.view.frame.size.height); // Changed from (xx, 0 to 6, ...) by Chad
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
    [self.pageController.view addSubview:loginButton];
}

-(void) checkCredentialsandShowLoginScreen
{
    NSArray *allServers = [[EmailServersService instance] allEmailServers];
    if (!([allServers count] == 0 || [((EmailServerModel *)[allServers objectAtIndex:0]).refreshToken isEqualToString:@"nil"])) {
        
        [self performSelector:@selector(refreshAccessToken) withObject:nil afterDelay:0.1];
    }
    else {
//        NSString *scope = @"https://mail.google.com/"; // scope for Gmail
        NSString *scope = @"https://mail.google.com/ https://www.googleapis.com/auth/userinfo.profile https://www.google.com/m8/feeds"; // scope for Gmail

        GTMOAuth2ViewControllerTouch *viewController;
        viewController = [[GTMOAuth2ViewControllerTouch alloc] initWithScope:scope
                                                                    clientID:kMyClientID
                                                                clientSecret:kMyClientSecret
                                                            keychainItemName:kKeychainItemName
                                                                    delegate:self
                                                            finishedSelector:@selector(viewController:finishedWithAuth:error:)];
        [self addChildViewController:viewController];
        [self.view addSubview:viewController.view];
    }
}

-(void) setDrawerControllerOnWindow
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate.window setRootViewController:appDelegate.drawerController];
}

- (void) loginButtonSelected {
    [self setDrawerControllerOnWindow];
    
    [[Mixpanel sharedInstance] track:@"Viewed last slider"];
    
    didLoginIn = @1;
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    if(didLoginIn)[appDelegate showWelcomeOverlay];
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
        [[self navigationController] popViewControllerAnimated:YES];
        // Authentication failed
    } else {
        [[Mixpanel sharedInstance] track:@"Signed into email"]; // Signed into Gmail
        
        didLoginIn = @1;
        
        
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

        // Authentication succeeded
        [self createDemoPageViewController];
        [self performSelector:@selector(loadHomeScreen) withObject:nil afterDelay:1];
        
    }
}

-(void)getContextIOWithEmail:(NSString*)email withName:(NSString*)name{
//
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    if(![appDelegate.contextIOAPIClient isAuthorized]){
        NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
        [params setObject:email forKey:@"email"];
        [params setObject:name forKey:@"first_name"];
        [params setObject:name forKey:@"last_name"];
        
        [appDelegate.contextIOAPIClient postPath:@"lite/users" params:params success:^(NSDictionary *responseDict) {
            NSLog(@"getContextIOWithEmail ----- %@",responseDict.description);
            NSString *contextIO_access_token = [responseDict objectForKey:@"access_token"];
            NSString *contextIO_access_token_secret = [responseDict objectForKey:@"access_token_secret"];
            NSString *contextIO_account_id = [responseDict objectForKey:@"id"];
            PFInstallation *currentInstallation = [PFInstallation currentInstallation];
            if (![currentInstallation channels]) {
                //[currentInstallation setChannels:@[]];
            }
            [currentInstallation addUniqueObject:[NSString stringWithFormat:@"account_id_%@", contextIO_account_id] forKey:@"channels"];
            NSArray *channels = [currentInstallation channels];
            [currentInstallation setChannels:channels];
            [currentInstallation saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                NSInteger errCode = [error code];
                if (kPFErrorConnectionFailed == errCode ||  kPFErrorInternalServer == errCode)
                    [currentInstallation saveEventually];
            }];
            appDelegate.contextIOAPIClient = [[CIOAPIClient alloc] initWithConsumerKey:kContextIOConsumerKey consumerSecret:kContextIOConsumerSecret token:contextIO_access_token tokenSecret:contextIO_access_token_secret accountID:contextIO_account_id];
            [appDelegate.contextIOAPIClient saveCredentials];
            
            //fetching contacts
            //[self performSelector:@selector(getUserContact) withObject:nil afterDelay:0.1];
            //[self addToSourceWithAccountID:contextIO_account_id];
            [self performSelector:@selector(addToSourceWithAccountID:) withObject:contextIO_account_id afterDelay:0.01];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"error getting getContextIOWithEmail: %@", error);
        }];
    }
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
        //[self performSelector:@selector(fetchContacts) withObject:nil afterDelay:20];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"error getting addToSourceWithAccountID: %@", error);
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
        }
    }];
}


-(void)getUserInfo{
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    NSURL *url = [NSURL URLWithString:@"https://www.googleapis.com/oauth2/v1/userinfo?alt=json"];
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

            [EmailService instance].userEmailID = currentEmail;
            [EmailService instance].userImageURL = currentUserImageURL;
            [EmailService instance].currentName = currentName;
            if(![appDelegate.contextIOAPIClient isAuthorized]){
                //[self getContextIOWithEmail:currentEmail withFirstName:currentName withLastName:currentName];
                //[self getContextIOWithEmail:currentEmail withName:currentName];
                [self performSelector:@selector(getContextIOWithEmail:withName:) withObject:currentEmail withObject:currentName];
            }
            else{
                PFInstallation *currentInstallation = [PFInstallation currentInstallation];
                if (![currentInstallation channels]) {
                    //[currentInstallation setChannels:@[]];
                }
                [currentInstallation addUniqueObject:[NSString stringWithFormat:@"account_id_%@", appDelegate.contextIOAPIClient._accountID] forKey:@"channels"];
                NSArray *channels = [currentInstallation channels];
                [currentInstallation setChannels:channels];
                [currentInstallation saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    NSInteger errCode = [error code];
                    if (kPFErrorConnectionFailed == errCode ||  kPFErrorInternalServer == errCode)
                        [currentInstallation saveEventually];
                }];
            }
            NSLog(@"what is currntNam: %@",[EmailService instance].currentName);
            //[self performSelector:@selector(getUserContact) withObject:nil afterDelay:0.1];

            [[NSUserDefaults standardUserDefaults] synchronize];
            [EmailService instance].primaryMessages = [NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults] objectForKey: ALL_FUNNL]];
            NSString *nextPageToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"PRIMARY_PAGE_TOKEN"];
            if(nextPageToken == nil || nextPageToken.length <= 0){
                nextPageToken = @"";
            }
            
            
            [appDelegate.menuController.listArray replaceObjectAtIndex:0 withObject:currentName];
            [appDelegate.menuController.imageArray replaceObjectAtIndex:0 withObject:[EmailService instance].userImageURL];
            [appDelegate.menuController.listView reloadData];
            
            
            NSLog(@"email: %@", currentEmail);
            [self getPrimaryMessages:currentEmail nextPageToken:nextPageToken numberOfMaxResult:100];
            
        }
    }];
}

-(void)getPrimaryMessages:(NSString*)emailStr nextPageToken:(NSString*)nextPage numberOfMaxResult:(NSInteger)maxResult{
    NSString *newAPIStr = @"";

    if(nextPage.length){
        newAPIStr = [NSString stringWithFormat:@"https://www.googleapis.com/gmail/v1/users/%@/messages?pageToken=%@&labelIds=CATEGORY_PERSONAL&maxResults=%d",emailStr,nextPage,maxResult];
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
            //NSLog(@"--Message info error %@: ", [error description]);
        } else {
            // succeeded
//            NSString* newStr = [[NSString alloc] initWithData:retrievedData encoding:NSUTF8StringEncoding];
//            NSLog(@"Message Info: %@",newStr);
            NSDictionary* json = [NSJSONSerialization JSONObjectWithData:retrievedData options:kNilOptions error:&error];
            NSArray* messageArray =[json objectForKey:@"messages"];
            NSString *nextPageToken = [json objectForKey:@"nextPageToken"];
            for (NSDictionary *dictionary in messageArray) {
                [[EmailService instance].primaryMessages addObject:[dictionary objectForKey:@"id"]];
            }
            
            NSMutableArray *pArray = [[EmailService instance] primaryMessages];
            [[NSUserDefaults standardUserDefaults] setObject:pArray forKey: ALL_FUNNL];
            [[NSUserDefaults standardUserDefaults] setObject:nextPageToken forKey:@"PRIMARY_PAGE_TOKEN"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            if([EmailService instance].primaryMessages.count < 5000)
                [self getPrimaryMessages:emailStr nextPageToken:nextPageToken numberOfMaxResult:100];
            else
                NSLog(@"----- Primary messages count > %d",pArray.count);
        }
    }];

}

-(void)loadHomeScreen {
    // Krunal : Commented below line 18 aug
     [self performSelector:@selector(getUserInfo) withObject:nil afterDelay:0.2];

    mainViewController = [[MainVC alloc] init];
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:mainViewController];
    
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    if(appDelegate.internetAvailable){
        //[[EmailService instance] startLogin:self.mainViewController.emailsTableViewController];
        [[EmailService instance] performSelectorInBackground:@selector(startLogin:) withObject:self.mainViewController.emailsTableViewController];
    }
    
    appDelegate.menuController = [[MenuViewController alloc] init];
    appDelegate.drawerController = [[MMDrawerController alloc] initWithCenterViewController:nav leftDrawerViewController:appDelegate.menuController];
    [appDelegate.drawerController setRestorationIdentifier:@"MMDrawer"];
    [appDelegate.drawerController setMaximumLeftDrawerWidth:250.0];
    [appDelegate.drawerController setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeAll];
    [appDelegate.drawerController setCloseDrawerGestureModeMask:MMCloseDrawerGestureModeAll];
    
    //expilictly calling the view to start the background loading emails
    [appDelegate.drawerController view];
    [mainViewController view];
    [appDelegate.menuController view];
    
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
            NSLog(@"Invalid access Token");
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
    //[[EmailService instance] startLogin:self.mainViewController.emailsTableViewController];
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


#pragma mark - unused function - Async Request

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
                    NSLog(@"%@", error);
                }
                NSDictionary *accessTokenInfoDictionary = [NSJSONSerialization JSONObjectWithData:_receivedData options:NSJSONReadingMutableContainers error:&error];
                NSString *accessToken = [accessTokenInfoDictionary objectForKey:@"access_token"];
                if(accessToken == nil) {
                    NSLog(@"Invalid access Token");
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
