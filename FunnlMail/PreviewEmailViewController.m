//
//  PreviewEmailViewController.m
//  FunnlMail
//
//  Created by Pranav Herur on 6/15/14.
//  Copyright (c) 2014 FunnlMail. All rights reserved.
//

#import "PreviewEmailViewController.h"
#include <MailCore/MailCore.h>
#import <MessageUI/MessageUI.h>
#import <QuartzCore/QuartzCore.h>

@interface PreviewEmailViewController ()

@end

@implementation PreviewEmailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

NSString *msgHTMLBody;
NSData * rfc822Data;
UITextField *to;
UITextField *cc;
UITextField *bcc;
UITextField *subject;

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIView *centeredButtons = [[UIView alloc]initWithFrame:CGRectMake(0, 28, 66, 28)];
    centeredButtons.backgroundColor = [UIColor whiteColor];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:centeredButtons];
    self.navigationItem.rightBarButtonItem = rightItem;
    
    UIButton *cancel = [UIButton buttonWithType:UIButtonTypeCustom];
    UIButton *sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [cancel addTarget:self action:@selector(cancelButtonSelected) forControlEvents:UIControlEventTouchUpInside];
    cancel.frame = CGRectMake(33, 0, 33, 28);
    [cancel setTitle:@"X" forState:UIControlStateNormal];
    [cancel setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [centeredButtons addSubview:cancel];
    
    [sendButton addTarget:self action:@selector(sendButtonSelected) forControlEvents:UIControlEventTouchUpInside];
    sendButton.frame = CGRectMake(0, 0, 33, 28);
    [sendButton setBackgroundImage:[UIImage imageNamed:@"Mail.png"] forState:UIControlStateNormal];
    [centeredButtons addSubview:sendButton];
    [self.view addSubview:centeredButtons];
    
    to = [[UITextField alloc] initWithFrame:CGRectMake(0, 60, 320, 20)];
    cc = [[UITextField alloc] initWithFrame:CGRectMake(0, 80, 320, 20)];
    bcc = [[UITextField alloc]initWithFrame:CGRectMake(0, 100, 320, 20)];
    subject = [[UITextField alloc]initWithFrame:CGRectMake(0, 120, 320, 20)];
    to.text = [self.address nonEncodedRFC822String];

    to.layer.masksToBounds=YES;
    to.layer.borderColor=[[UIColor blackColor]CGColor];
    to.layer.borderWidth= 1.0f;
    
    cc.layer.masksToBounds=YES;
    cc.layer.borderColor=[[UIColor blackColor]CGColor];
    cc.layer.borderWidth= 1.0f;
    
    bcc.layer.masksToBounds=YES;
    bcc.layer.borderColor=[[UIColor blackColor]CGColor];
    bcc.layer.borderWidth= 1.0f;
    
    subject.layer.masksToBounds=YES;
    subject.layer.borderColor=[[UIColor blackColor]CGColor];
    subject.layer.borderWidth= 1.0f;
    
    [self.view addSubview:to];
    [self.view addSubview:cc];
    [self.view addSubview:bcc];
    [self.view addSubview:subject];
    UIWebView *email = [[UIWebView alloc]initWithFrame:CGRectMake(0, 140, 320, self.view.bounds.size.height-140)];
    [email loadHTMLString:[self.message htmlRenderingWithFolder:self.folder delegate:nil] baseURL:nil];
    [email setBackgroundColor:[UIColor blackColor]];
    [self.view addSubview:email];
    
    MCOIMAPFetchContentOperation *operation = [self._session fetchMessageByUIDOperationWithFolder:@"INBOX" uid:self.message.uid];
    
    [operation start:^(NSError *error, NSData *data) {
        MCOMessageParser *messageParser = [[MCOMessageParser alloc] initWithData:data];
        msgHTMLBody = [messageParser htmlBodyRendering];
        [email loadHTMLString:msgHTMLBody baseURL:nil];
        [self.view addSubview:email];
    }];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)sendButtonSelected{
    NSLog(@"Username: %@",self._session.username);
    NSLog(@"Password: %@",self._session.password);
    
    MCOSMTPSession *smtpSession = [[MCOSMTPSession alloc] init];
    smtpSession.hostname = @"smtp.gmail.com";
    smtpSession.port = 465;
    smtpSession.username = self._session.username;
    smtpSession.password = self._session.password;
    smtpSession.authType = (MCOAuthTypeSASLPlain | MCOAuthTypeSASLLogin);
    smtpSession.connectionType = MCOConnectionTypeTLS;
    
    MCOMessageBuilder * builder = [[MCOMessageBuilder alloc] init];
    [[builder header] setFrom:[MCOAddress addressWithDisplayName:nil mailbox:self._session.username]];
    NSMutableArray *toArray = [[NSMutableArray alloc] init];
    MCOAddress *newAddress = [MCOAddress addressWithMailbox:to.text];
    [toArray addObject:newAddress];
    [[builder header] setTo:toArray];
    NSMutableArray *ccArray = [[NSMutableArray alloc] init];
    newAddress = [MCOAddress addressWithMailbox:cc.text];
    [ccArray addObject:newAddress];
    [[builder header] setCc:ccArray];
    NSMutableArray *bccArray = [[NSMutableArray alloc] init];
    newAddress = [MCOAddress addressWithMailbox:bcc.text];
    [bccArray addObject:newAddress];
    [[builder header] setBcc:bccArray];
    [[builder header] setSubject:subject.text];
    [builder setHTMLBody:msgHTMLBody];
    rfc822Data = [builder data];
    
    MCOSMTPSendOperation *sendOperation = [smtpSession sendOperationWithData:rfc822Data];
    [sendOperation start:^(NSError *error) {
        if(error) {
            NSLog(@"%@ Error sending email:%@", self._session.username, error);
        } else {
            NSLog(@"%@ Successfully sent email!", self._session.username);
        }
    }];
    [self dismissViewControllerAnimated:YES completion:NULL];


}

-(void)cancelButtonSelected{
    NSLog(@"Cancel button pressed");
    to = nil;
    cc = nil;
    bcc = nil;
    subject = nil;
    [self dismissViewControllerAnimated:YES completion:NULL];
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
