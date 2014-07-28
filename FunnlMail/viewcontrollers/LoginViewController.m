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

#define accessTokenEndpoint @"https://accounts.google.com/o/oauth2/token"

@interface LoginViewController ()

@end

@implementation LoginViewController

static NSString *const kKeychainItemName = @"OAuth2 Sample: Gmail";
NSString *kMyClientID = @"655269106649-rkom4nvj3m9ofdpg6sk53pi65mpivv7d.apps.googleusercontent.com";     // pre-assigned by service
NSString *kMyClientSecret = @"1ggvIxWh-rV_Eb9OX9so7aCt";
//NSString *kMyClientID = @"994627364215-ctjmrhiul95ts0qrkc38sap3mo3go3ko.apps.googleusercontent.com";     // pre-assigned by service
//NSString *kMyClientSecret = @"FNZ-x95gkwWqQT7HdJgeqJVW";
@synthesize blockerView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void) viewDidLoad {
    [super viewDidLoad];
    _receivedData = [[NSMutableData alloc] init];
    _isRefreshing = NO;
    
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    blockerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, HEIGHT)];
    blockerView.backgroundColor = [UIColor redColor];
    
    NSArray *allServers = [[EmailServersService instance] allEmailServers];
    if (!([allServers count] == 0 || [((EmailServerModel *)[allServers objectAtIndex:0]).refreshToken isEqualToString:@"nil"])) {
    
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
        [self makeRequest:request];
    }
    else {
        self.view.backgroundColor = [UIColor colorWithHexString:@"F6F6F6"];
        
        UIImageView *funnlMailIntroView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"splashScreen"]];
        funnlMailIntroView.frame = CGRectMake(-8, 40, WIDTH, HEIGHT-120);
        funnlMailIntroView.userInteractionEnabled = YES;
        [self.view addSubview:funnlMailIntroView];
        
//        [funnlMailIntroView mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.top.equalTo(self.view.mas_top).with.offset(20);
//            make.left.equalTo(self.view.mas_left).with.offset(0);
//            make.right.equalTo(self.view.mas_right).with.offset(0);
//            make.bottom.equalTo(self.view.mas_bottom).with.offset(-150);
//        }];
        
        UIImage *loginImage = [UIImage imageNamed:@"getStarted"];
        UIButton *loginButton = [[UIButton alloc] init];
        [loginButton setImage:loginImage forState:UIControlStateNormal];
        loginButton.frame = CGRectMake(0, HEIGHT-60, 320, 40);
        [loginButton addTarget:self action:@selector(loginButtonSelected)forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:loginButton];
        
//        [loginButton mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.top.equalTo(funnlMailIntroView.mas_bottom).with.offset(40);
//            make.left.equalTo(self.view.mas_left).with.offset(7);
//        }];
    }
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


- (void) loginButtonSelected {
    [self oauthLogin];
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
    
    NSString *scope = @"https://mail.google.com/"; // scope for Gmail
    
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
        [[Mixpanel sharedInstance] track:@"User Succesfully logged in"];
        NSString * email = [auth userEmail];
        NSString * accessToken = [auth accessToken];
        NSString * refreshToken = [auth refreshToken];
        
        
        self.emailServerModel = [[EmailServerModel alloc] init];
        self.emailServerModel.emailAddress = email;
        self.emailServerModel.accessToken = accessToken;
        self.emailServerModel.refreshToken = refreshToken;

        [[EmailServersService instance] insertEmailServer:self.emailServerModel];
        MCOIMAPSession * imapSession = [[MCOIMAPSession alloc] init];
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

        AppDelegate *tempAppDelegate = APPDELEGATE;
        [tempAppDelegate.progressHUD show:YES];
        [tempAppDelegate.window addSubview:tempAppDelegate.progressHUD];
        [tempAppDelegate.window bringSubviewToFront:tempAppDelegate.progressHUD];
        [tempAppDelegate.progressHUD setHidden:NO];

        // Authentication succeeded
        
        [self performSelector:@selector(loadHomeScreen) withObject:nil afterDelay:1];
    }
}



-(void)getUserInfo{
    //    NSURL *url = [NSURL URLWithString:@"https://www.googleapis.com/gmail/v1/users/krunal.chaudhari@iauro.com/labels"];
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

            [[NSUserDefaults standardUserDefaults] synchronize];
            [EmailService instance].primaryMessages = [NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"PRIMARY"]];
            NSString *nextPageToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"PRIMARY_PAGE_TOKEN"];
            if(nextPageToken == nil || nextPageToken.length <= 0){
                nextPageToken = @"";
            }
            
            AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
            [appDelegate.menuController.listArray replaceObjectAtIndex:0 withObject:currentName];
            [appDelegate.menuController.imageArray replaceObjectAtIndex:0 withObject:[EmailService instance].userImageURL];
            [appDelegate.menuController.listView reloadData];
            
            NSLog(@"email: %@", currentEmail);
            [self getPrimaryMessages:currentEmail nextPageToken:nextPageToken];
            
        }
    }];
}

-(void)getPrimaryMessages:(NSString*)emailStr nextPageToken:(NSString*)nextPage{
    //https://www.googleapis.com/gmail/v1/users/krunal.chaudhari%40iauro.com/messages
    NSString *newAPIStr = @"";

    if(nextPage.length){
        newAPIStr = [NSString stringWithFormat:@"https://www.googleapis.com/gmail/v1/users/%@/messages?pageToken=%@&labelIds=CATEGORY_PERSONAL",emailStr,nextPage];
    }
    else{
        newAPIStr = [NSString stringWithFormat:@"https://www.googleapis.com/gmail/v1/users/%@/messages?fields=messages(id,labelIds,threadId),nextPageToken&labelIds=CATEGORY_PERSONAL",emailStr];
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
            NSLog(@"--Message info error %@: ", [error description]);
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
            [[NSUserDefaults standardUserDefaults] setObject:pArray forKey:@"PRIMARY"];
            [[NSUserDefaults standardUserDefaults] setObject:nextPageToken forKey:@"PRIMARY_PAGE_TOKEN"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            if([EmailService instance].primaryMessages.count < 1000)
                [self getPrimaryMessages:emailStr nextPageToken:nextPageToken];
            else
                NSLog(@"----- Primary messages count > %d",pArray.count);
        }
    }];
}

-(void)loadHomeScreen {
    [self getUserInfo];
    
    MainVC *mainvc = [[MainVC alloc] init];
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:mainvc];
    
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    appDelegate.menuController = [[MenuViewController alloc] init];
    appDelegate.drawerController = [[MMDrawerController alloc] initWithCenterViewController:nav leftDrawerViewController:appDelegate.menuController];
    [appDelegate.drawerController setRestorationIdentifier:@"MMDrawer"];
    [appDelegate.drawerController setMaximumLeftDrawerWidth:250.0];
    [appDelegate.drawerController setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeAll];
    [appDelegate.drawerController setCloseDrawerGestureModeMask:MMCloseDrawerGestureModeAll];
    
    [self.navigationController presentViewController:appDelegate.drawerController animated:NO completion:nil];
    AppDelegate *tempAppDelegate = APPDELEGATE;
    [tempAppDelegate.progressHUD show:NO];
    [tempAppDelegate.progressHUD setHidden:YES];


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
    _urlConnection = [NSURLConnection connectionWithRequest:request delegate:self];
}

#pragma NSURLConnection delegate methdods

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [_receivedData appendData:data];
}
-(void)connectionDidFinishLoading:(NSURLConnection *)connection {
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
        self.emailServerModel.accessToken = [accessTokenInfoDictionary objectForKey:@"access_token"];
        
        // update database with new access token
        [[EmailServersService instance] updateEmailServer:self.emailServerModel];
        
        if (self.isRefreshing) {
            self.isRefreshing = NO;
        }

        // Notify the caller class that the authorization was successful.
        NSLog(@"%@", @"successfully fetched access token from refresh token");
        isAPIResponse = NO;
    }
    
    MCOIMAPSession * imapSession = [[MCOIMAPSession alloc] init];
    [EmailService instance].imapSession = imapSession;
    
    [imapSession setAuthType:MCOAuthTypeXOAuth2];
    [imapSession setOAuth2Token:self.emailServerModel.accessToken];
    [imapSession setUsername:self.emailServerModel.emailAddress];
    
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
    //[self performSelector:@selector(loadHomeScreen) withObject:nil afterDelay:1];

}
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    
}
-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
}
@end
