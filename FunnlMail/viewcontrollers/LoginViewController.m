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

- (void)viewDidLoad
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

    /*UIButton *enterButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [[enterButton layer] setBorderWidth:2.0f];
    [[enterButton layer] setBorderColor:[UIColor ].CGColor];
    [enterButton setTitle:@"Done" forState:UIControlStateNormal];
    enterButton.frame = CGRectMake(100, 400, 100, 50);
     */
    
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

    //[self.view addConstraint:[NSLayoutConstraint constraintWithItem:username attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0]];
    //[self.view addConstraint:[NSLayoutConstraint constraintWithItem:username attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:100]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) doneButtonSelected {
    /*KeychainItemWrapper *keychainItem = [[KeychainItemWrapper alloc] initWithIdentifier:@"UserLoginInfo" accessGroup:nil];
    [keychainItem setObject:_username.text forKey:(__bridge id)(kSecAttrAccount)];
    [keychainItem setObject:_password.text forKey:(__bridge id)(kSecAttrService)];

    MainVC *mainvc = [[MainVC alloc] init];
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:mainvc];
    [self.navigationController presentViewController:nav animated:YES completion:nil];*/
    [self oauthLogin];
}

- (void) oauthLogin {
    static NSString *const kKeychainItemName = @"OAuth2 Sample: Gmail";
    
    NSString *kMyClientID = @"655269106649-rkom4nvj3m9ofdpg6sk53pi65mpivv7d.apps.googleusercontent.com";     // pre-assigned by service
    NSString *kMyClientSecret = @"1ggvIxWh-rV_Eb9OX9so7aCt"; // pre-assigned by service
    
    NSString *scope = @"https://mail.google.com/"; // scope for Gmail
    
    GTMOAuth2ViewControllerTouch *viewController;
    viewController = [[GTMOAuth2ViewControllerTouch alloc] initWithScope:scope
                                                                 clientID:kMyClientID
                                                             clientSecret:kMyClientSecret
                                                         keychainItemName:kKeychainItemName
                                                                 delegate:self
                                                         finishedSelector:@selector(viewController:finishedWithAuth:error:)];
    [[self navigationController] pushViewController:viewController
                                           animated:YES];
}

- (void)viewController:(GTMOAuth2ViewControllerTouch *)viewController
      finishedWithAuth:(GTMOAuth2Authentication *)auth
                 error:(NSError *)error {
    if (error != nil) {
        // Authentication failed
    } else {
        NSString * email = [auth userEmail];
        NSString * accessToken = [auth accessToken];
        
        MCOIMAPSession * imapSession = [[MCOIMAPSession alloc] init];
        [EmailService instance].imapSession = imapSession;
        [imapSession setAuthType:MCOAuthTypeXOAuth2];
        [imapSession setOAuth2Token:accessToken];
        [imapSession setUsername:email];
        
        MCOSMTPSession * smtpSession = [[MCOSMTPSession alloc] init];
        [smtpSession setAuthType:MCOAuthTypeXOAuth2];
        [smtpSession setOAuth2Token:accessToken];
        [smtpSession setUsername:email];
        
        MainVC *mainvc = [[MainVC alloc] init];
        UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:mainvc];
        [self.navigationController presentViewController:nav animated:YES completion:nil];
        // Authentication succeeded
    }
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

@end
