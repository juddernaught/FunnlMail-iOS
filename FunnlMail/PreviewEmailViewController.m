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

NSString *msgBody;
NSData * rfc822Data;
UITextField *to;
UITextField *cc;
UITextField *bcc;
UITextField *subject;
NSNumber *sendNum;

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.imapSession = [EmailService instance].imapSession;

    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIView *centeredButtons = [[UIView alloc]initWithFrame:CGRectMake(0, 28, self.view.bounds.size.width, 28)];
    centeredButtons.backgroundColor = [UIColor whiteColor];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:centeredButtons];
    self.navigationItem.rightBarButtonItem = rightItem;
    
    UIButton *cancel = [UIButton buttonWithType:UIButtonTypeCustom];
    UIButton *sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [cancel addTarget:self action:@selector(cancelButtonSelected) forControlEvents:UIControlEventTouchUpInside];
    cancel.frame = CGRectMake(0, 0, 33, 28);
    [cancel setTitle:@"X" forState:UIControlStateNormal];
    [cancel setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [centeredButtons addSubview:cancel];
    
    [sendButton addTarget:self action:@selector(sendButtonSelected) forControlEvents:UIControlEventTouchUpInside];
    sendButton.frame = CGRectMake(260, 0, 50, 28);
    [sendButton setTitle:@"Send" forState:UIControlStateNormal];
    [sendButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    //[sendButton setBackgroundImage:[UIImage imageNamed:@"Mail.png"] forState:UIControlStateNormal];
    [centeredButtons addSubview:sendButton];
    [self.view addSubview:centeredButtons];
    
    int height = 30;
    to = [[UITextField alloc] initWithFrame:CGRectMake(22, 60, 300, height)];
    cc = [[UITextField alloc] initWithFrame:CGRectMake(30, 90, 290, height)];
    bcc = [[UITextField alloc]initWithFrame:CGRectMake(32, 120, 288, height)];
    subject = [[UITextField alloc]initWithFrame:CGRectMake(50, 150, 270, height)];
    
    UITextField *to2 = [[UITextField alloc] initWithFrame:CGRectMake(0, 60, 22, height)];
    UITextField *cc2 = [[UITextField alloc] initWithFrame:CGRectMake(0, 90, 30, height)];
    cc2.delegate = self;
    UITextField *bcc2 = [[UITextField alloc] initWithFrame:CGRectMake(0, 120, 32, height)];
    UITextField *subject2 = [[UITextField alloc] initWithFrame:CGRectMake(0, 150, 50, height)];
    to.text = [self.address nonEncodedRFC822String];
    
    to2.text = @" To:";
    cc2.text = @" Cc:";
    bcc2.text = @" Bcc:";
    subject2.text = @" Subject: ";
    
    to2.userInteractionEnabled = false;
    cc2.userInteractionEnabled = false;
    bcc2.userInteractionEnabled = false;
    subject2.userInteractionEnabled = false;
    
    [to2 setFont:[UIFont boldSystemFontOfSize:12]];
    [cc2 setFont:[UIFont boldSystemFontOfSize:12]];
    [bcc2 setFont:[UIFont boldSystemFontOfSize:12]];
    [subject2 setFont:[UIFont boldSystemFontOfSize:12]];
    
    [to2 setTextColor:[UIColor grayColor]];
    [cc2 setTextColor:[UIColor grayColor]];
    [bcc2 setTextColor:[UIColor grayColor]];
    [subject2 setTextColor:[UIColor grayColor]];

    //actual textview bordering
    UIView *bottomBorder = [[UIView alloc]
                            initWithFrame:CGRectMake(0,to.frame.size.height-1,to.frame.size.width-30,1)];
    bottomBorder.backgroundColor = [UIColor colorWithHexString:@"D9D9D9"];
    [to addSubview:bottomBorder];
    
    bottomBorder = [[UIView alloc]
                    initWithFrame:CGRectMake(0,0,to.frame.size.width,1)];
    bottomBorder.backgroundColor = [UIColor blackColor];
    [to addSubview:bottomBorder];
    
    bottomBorder = [[UIView alloc]
                    initWithFrame:CGRectMake(0,0,to2.frame.size.width,1)];
    bottomBorder.backgroundColor = [UIColor blackColor];
    [to2 addSubview:bottomBorder];
    
    bottomBorder = [[UIView alloc]
                    initWithFrame:CGRectMake(0,to.frame.size.height-1,cc.frame.size.width-30,1)];
    bottomBorder.backgroundColor = [UIColor colorWithHexString:@"D9D9D9"];
    [cc addSubview:bottomBorder];
    
    bottomBorder = [[UIView alloc]
                            initWithFrame:CGRectMake(0,to.frame.size.height-1,bcc.frame.size.width-30,1)];
    bottomBorder.backgroundColor = [UIColor colorWithHexString:@"D9D9D9"];
    [bcc addSubview:bottomBorder];
    
    bottomBorder = [[UIView alloc]
                            initWithFrame:CGRectMake(0,to.frame.size.height-1,subject.frame.size.width-30,1)];
    bottomBorder.backgroundColor = [UIColor colorWithHexString:@"D9D9D9"];
    [subject addSubview:bottomBorder];
    
    //begin prefix bordering
    bottomBorder = [[UIView alloc]
                    initWithFrame:CGRectMake(0,to.frame.size.height-1,to2.frame.size.width,1)];
    bottomBorder.backgroundColor = [UIColor colorWithHexString:@"D9D9D9"];
    [to2 addSubview:bottomBorder];
    
    bottomBorder = [[UIView alloc]
                    initWithFrame:CGRectMake(0,to.frame.size.height-1,cc2.frame.size.width,1)];
    bottomBorder.backgroundColor = [UIColor colorWithHexString:@"D9D9D9"];
    [cc2 addSubview:bottomBorder];
    
    bottomBorder = [[UIView alloc]
                    initWithFrame:CGRectMake(0,to.frame.size.height-1,bcc2.frame.size.width,1)];
    bottomBorder.backgroundColor = [UIColor colorWithHexString:@"D9D9D9"];
    [bcc2 addSubview:bottomBorder];
    
    bottomBorder = [[UIView alloc]
                    initWithFrame:CGRectMake(0,to.frame.size.height-1, subject2.frame.size.width,1)];
    bottomBorder.backgroundColor = [UIColor colorWithHexString:@"D9D9D9"];
    [subject2 addSubview:bottomBorder];
    
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

    self.body = [[UITextView alloc] initWithFrame:CGRectMake(0, 180, 320, self.view.bounds.size.height-140)];
    
    
    if (!self.compose) {
        MCOIMAPFetchContentOperation *operation = [self.imapSession fetchMessageByUIDOperationWithFolder:@"INBOX" uid:self.message.uid];
        
        [operation start:^(NSError *error, NSData *data) {
            MCOMessageParser *messageParser = [[MCOMessageParser alloc] initWithData:data];
            msgBody = [messageParser plainTextRendering];
            NSMutableString *temp = [[NSMutableString alloc] initWithString:@"____________________________________________________"];
            [temp appendString:msgBody];
            self.body.text = temp;
            temp = nil;
        }];
        NSLog(@"message is empty");
    }
    [self.view addSubview:self.body];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)sendButtonSelected{
    
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
    [builder setHTMLBody:self.body.text];
    rfc822Data = [builder data];
    
    MCOSMTPSendOperation *sendOperation = [[EmailService instance].smtpSession sendOperationWithData:rfc822Data];
    [sendOperation start:^(NSError *error) {
        if(error) {
            NSLog(@"%@ Error sending email:%@", [EmailService instance].smtpSession.username, error);
        } else {
            NSLog(@"%@ Successfully sent email!", [EmailService instance].smtpSession.username);
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
