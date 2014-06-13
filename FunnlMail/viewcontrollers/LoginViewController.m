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

#define accessTokenEndpoint @"https://accounts.google.com/o/oauth2/token"

@interface LoginViewController ()

@end

@implementation LoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

/*- (void)viewDidLoad
{

    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];

    _username = [[UITextField alloc] init];
    _username.autocorrectionType = UITextAutocorrectionTypeNo;
    _username.placeholder = @"Email Address";
    _password = [[UITextField alloc] init];
    _password.secureTextEntry = YES;
    _password.placeholder = @"Password";
    _username.borderStyle = UITextBorderStyleRoundedRect;
    _password.borderStyle = UITextBorderStyleRoundedRect;
    _username.layer.cornerRadius = 20;//half of the width
    _username.layer.borderColor=[UIColor greenColor].CGColor;
    _username.layer.borderWidth=2.0f;
    _password.layer.cornerRadius = 20;//half of the width
    _password.layer.borderColor=[UIColor greenColor].CGColor;
    _password.layer.borderWidth=2.0f;

    _username.frame = CGRectMake(30, 100, 260, 50);
    _password.frame = CGRectMake(30, 200, 260, 50);
    [self.view addSubview:_username];
    [self.view addSubview:_password];

    UIButton *enterButton = [UIButton buttonWithType:UIButtonTypeCustom];
    enterButton.frame = CGRectMake(100, 100, 100,50);
    [enterButton setTitle:@"Done" forState:UIControlStateNormal];
    [enterButton setBackgroundColor:[UIColor colorWithRed:0.0/255.0f green:128.0/255.0f blue:0.0/255.0f alpha:0.7]];
    enterButton.frame = CGRectMake(100.0, 300, 120.0, 50.0);//width and height should be same value
    enterButton.clipsToBounds = YES;
    [enterButton addTarget:self action:@selector(doneButtonSelected) forControlEvents:UIControlEventTouchUpInside];

    enterButton.layer.cornerRadius = 20;//half of the width
    enterButton.layer.borderColor=[UIColor greenColor].CGColor;
    enterButton.layer.borderWidth=2.0f;
    
    [self.view addSubview:enterButton];

}*/


- (void) viewDidLoad {
    [super viewDidLoad];
    _receivedData = [[NSMutableData alloc] init];
    _isRefreshing = NO;
    
    self.view.backgroundColor = [UIColor colorWithHexString:@"F6F6F6"];

    UIImageView *funnlMailIntroView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"intro.png"]];
    
    [self.view addSubview:funnlMailIntroView];
    
    [funnlMailIntroView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_top).with.offset(20);
        make.left.equalTo(self.view.mas_left).with.offset(0);
        make.right.equalTo(self.view.mas_right).with.offset(0);
        make.bottom.equalTo(self.view.mas_bottom).with.offset(-150);
    }];
    UIImage *loginImage = [UIImage imageNamed:@"login.png"];
    UIButton *loginButton = [[UIButton alloc] init];
    [loginButton setImage:loginImage forState:UIControlStateNormal];
    
    [loginButton addTarget:self
               action:@selector(loginButtonSelected)forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:loginButton];
    
    [loginButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(funnlMailIntroView.mas_bottom).with.offset(40);
        make.left.equalTo(self.view.mas_left).with.offset(7);
    }];
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
    /*KeychainItemWrapper *keychainItem = [[KeychainItemWrapper alloc] initWithIdentifier:@"UserLoginInfo" accessGroup:nil];
    [keychainItem setObject:_username.text forKey:(__bridge id)(kSecAttrAccount)];
    [keychainItem setObject:_password.text forKey:(__bridge id)(kSecAttrService)];

    MainVC *mainvc = [[MainVC alloc] init];
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:mainvc];
    [self.navigationController presentViewController:nav animated:YES completion:nil];*/
    [self oauthLogin];
}


- (void) oauthLogin {
    // THIS DOESN'T WORK YET...REFRESH KEY IS LIKELY NEEDED AFTER A CERTAIN PERIOD OF TIME
    //if ([[[EmailServersService instance] allEmailServers] count] == 0 && false) {
    NSString *kMyClientID = @"655269106649-rkom4nvj3m9ofdpg6sk53pi65mpivv7d.apps.googleusercontent.com";     // pre-assigned by service
    NSString *kMyClientSecret = @"1ggvIxWh-rV_Eb9OX9so7aCt";
    NSArray *allServers = [[EmailServersService instance] allEmailServers];
    if ([allServers count] == 0 || [((EmailServerModel *)[allServers objectAtIndex:0]).refreshToken isEqualToString:@"nil"]) {
        if ([[[EmailServersService instance] allEmailServers] count] > 0) {
            for (EmailServerModel *m in [[EmailServersService instance] allEmailServers]) {
                [[EmailServersService instance] deleteEmailServer:m.emailAddress];
            }
        }
        
        static NSString *const kKeychainItemName = @"OAuth2 Sample: Gmail";
        
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
    else {
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
    
    //[[self navigationController] presentViewController:viewController animated:YES completion:nil];
}


- (void)viewController:(GTMOAuth2ViewControllerTouch *)viewController
      finishedWithAuth:(GTMOAuth2Authentication *)auth
                 error:(NSError *)error {
    if (error != nil) {
        [[self navigationController] popViewControllerAnimated:YES];
        // Authentication failed
    } else {
        NSString * email = [auth userEmail];
        NSString * accessToken = [auth accessToken];
        NSString * refreshToken = [auth refreshToken];
        self.emailServerModel = [[EmailServerModel alloc] init];
        self.emailServerModel.emailAddress = email;
        self.emailServerModel.accessToken = accessToken;
        self.emailServerModel.refreshToken = refreshToken;
        
        // MUSTFIX: remove at some point:
        //[[EmailServersService instance] deleteEmailServer:emailServer.emailAddress];

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
        [self loadHomeScreen];
        
        // Authentication succeeded
    }
}

-(void)loadHomeScreen {
    MainVC *mainvc = [[MainVC alloc] init];
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:mainvc];
    
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    appDelegate.menuController = [[MenuViewController alloc] init];
    appDelegate.drawerController = [[MMDrawerController alloc] initWithCenterViewController:nav leftDrawerViewController:appDelegate.menuController];
    [appDelegate.drawerController setRestorationIdentifier:@"MMDrawer"];
    [appDelegate.drawerController setMaximumLeftDrawerWidth:200.0];
    [appDelegate.drawerController setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeAll];
    [appDelegate.drawerController setCloseDrawerGestureModeMask:MMCloseDrawerGestureModeAll];
    
    [self.navigationController presentViewController:appDelegate.drawerController animated:YES completion:nil];
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
    
    [self loadHomeScreen];

}
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    
}
-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
}
@end
