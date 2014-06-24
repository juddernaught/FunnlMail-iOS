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
#import "EmailService.h"


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
    self.imapSession = [EmailService instance].imapSession;

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
    
    to = [[UITextField alloc] initWithFrame:CGRectMake(22, 60, 300, 20)];
    cc = [[UITextField alloc] initWithFrame:CGRectMake(22, 80, 300, 20)];
    bcc = [[UITextField alloc]initWithFrame:CGRectMake(32, 100, 288, 20)];
    subject = [[UITextField alloc]initWithFrame:CGRectMake(50, 120, 270, 20)];
    UITextField *to2 = [[UITextField alloc] initWithFrame:CGRectMake(0, 60, 22, 20)];
    UITextField *cc2 = [[UITextField alloc] initWithFrame:CGRectMake(0, 80, 22, 20)];
    UITextField *bcc2 = [[UITextField alloc] initWithFrame:CGRectMake(0, 100, 32, 20)];
    UITextField *subject2 = [[UITextField alloc] initWithFrame:CGRectMake(0, 120, 50, 20)];
    to.text = [self.address nonEncodedRFC822String];
    
    to2.text = @" to:";
    cc2.text = @" cc:";
    bcc2.text = @" bcc:";
    subject2.text = @" subject:";
    
    [to2 setFont:[UIFont systemFontOfSize:12]];
    [cc2 setFont:[UIFont systemFontOfSize:12]];
    [bcc2 setFont:[UIFont systemFontOfSize:12]];
    [subject2 setFont:[UIFont systemFontOfSize:12]];

    UIView *bottomBorder = [[UIView alloc]
                            initWithFrame:CGRectMake(0,to.frame.size.height-1,to.frame.size.width,1)];
    bottomBorder.backgroundColor = [UIColor blackColor];
    
    UIView *sideBorder = [[UIView alloc]
                            initWithFrame:CGRectMake(to2.frame.size.width-1,0,1,to2.frame.size.height)];
    sideBorder.backgroundColor = [UIColor lightGrayColor];
    
    
    [to addSubview:bottomBorder];
    
    bottomBorder = [[UIView alloc]
                            initWithFrame:CGRectMake(0,to.frame.size.height-1,to.frame.size.width,1)];
    bottomBorder.backgroundColor = [UIColor blackColor];
    [to2 addSubview:bottomBorder];
    
    bottomBorder = [[UIView alloc]
                            initWithFrame:CGRectMake(0,to.frame.size.height-1,to.frame.size.width,1)];
    bottomBorder.backgroundColor = [UIColor blackColor];
    [cc addSubview:bottomBorder];
    
    bottomBorder = [[UIView alloc]
                            initWithFrame:CGRectMake(0,to.frame.size.height-1,to.frame.size.width,1)];
    bottomBorder.backgroundColor = [UIColor blackColor];
    [cc2 addSubview:bottomBorder];
    
    bottomBorder = [[UIView alloc]
                            initWithFrame:CGRectMake(0,to.frame.size.height-1,to.frame.size.width,1)];
    bottomBorder.backgroundColor = [UIColor blackColor];
    [bcc addSubview:bottomBorder];
    
    bottomBorder = [[UIView alloc]
                            initWithFrame:CGRectMake(0,to.frame.size.height-1,to.frame.size.width,1)];
    bottomBorder.backgroundColor = [UIColor blackColor];
    [bcc2 addSubview:bottomBorder];
    
    bottomBorder = [[UIView alloc]
                            initWithFrame:CGRectMake(0,to.frame.size.height-1,to.frame.size.width,1)];
    bottomBorder.backgroundColor = [UIColor blackColor];
    [subject2 addSubview:bottomBorder];
    
    bottomBorder = [[UIView alloc]
                            initWithFrame:CGRectMake(0,to.frame.size.height-1,to.frame.size.width,1)];
    bottomBorder.backgroundColor = [UIColor blackColor];
    [subject addSubview:bottomBorder];
    
    bottomBorder = [[UIView alloc]
                            initWithFrame:CGRectMake(0,to.frame.size.height-1,to.frame.size.width,1)];
    bottomBorder.backgroundColor = [UIColor blackColor];

    
    if (self.forward) {
        NSLog(@"self.forward");
        NSMutableString *temp = [[NSMutableString alloc] initWithString:@"FWD: "];
        [temp appendString:self.message.header.subject];
        subject.text = temp;
    }
    else if (self.reply){
        NSLog(@"self.reply");
        NSMutableString *temp = [[NSMutableString alloc] initWithString:@"Re: "];
        [temp appendString:self.message.header.subject];
        subject.text = temp;
    }

    [self.view addSubview:to2];
    [self.view addSubview:cc2];
    [self.view addSubview:bcc2];
    [self.view addSubview:subject2];
    [self.view addSubview:to];
    [self.view addSubview:cc];
    [self.view addSubview:bcc];
    [self.view addSubview:subject];

    //dont use webview for now
//    UIWebView *email = [[UIWebView alloc]initWithFrame:CGRectMake(0, 140, 320, self.view.bounds.size.height-140)];
//    email.userInteractionEnabled = true;

    UITextView *body = [[UITextView alloc] initWithFrame:CGRectMake(0, 140, 320, self.view.bounds.size.height-140)];
    
    
    if (!self.compose) {
        MCOIMAPFetchContentOperation *operation = [self.imapSession fetchMessageByUIDOperationWithFolder:@"INBOX" uid:self.message.uid];
        
        [operation start:^(NSError *error, NSData *data) {
            MCOMessageParser *messageParser = [[MCOMessageParser alloc] initWithData:data];
            msgHTMLBody = [messageParser plainTextBodyRendering];
            body.text = msgHTMLBody;
            
        }];
        NSLog(@"message is empty");
    }
    [self.view addSubview:body];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)sendButtonSelected{
    MCOSMTPSession *smtpSession = [[MCOSMTPSession alloc] init];
    smtpSession.hostname = @"smtp.gmail.com";
    smtpSession.port = 465;
    smtpSession.username = @"herurpranav@gmail.com";
    smtpSession.password = @"bye2bye2";
    smtpSession.authType = (MCOAuthTypeSASLPlain | MCOAuthTypeSASLLogin);
    smtpSession.connectionType = MCOConnectionTypeTLS;
    //[EmailService instance].smtpSession.OAuth2Token
    
    
    MCOMessageBuilder * builder = [[MCOMessageBuilder alloc] init];
    [[builder header] setFrom:[MCOAddress addressWithDisplayName:nil mailbox:self.imapSession.username]];
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
            NSLog(@"%@ Error sending email:%@", self.imapSession.username, error);
        } else {
            NSLog(@"%@ Successfully sent email!", self.imapSession.username);
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