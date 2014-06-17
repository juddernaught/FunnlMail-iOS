//
//  EmailThreadTableViewController.m
//  FunnlMail
//
//  Created by iauro001 on 6/17/14.
//  Copyright (c) 2014 FunnlMail. All rights reserved.
//

#import "EmailThreadTableViewController.h"
#import "UIColor+HexString.h"
#import "NSDate+TimeAgo.h"
#import "EmailService.h"

static NSString *mailCellIdentifier = @"MailCell";

@interface EmailThreadTableViewController ()

@end

@implementation EmailThreadTableViewController
@synthesize emailThreadTable,dataSourceArray,mainVCdelegate;

#pragma mark -
#pragma mark Lifecycle
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithGmailThreadID:(NSString*)gmailThreadID
{
    self = [super init];
    if (self) {
        // Custom initialization
        gmailThreadId = gmailThreadID;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    dataSourceArray = [[MessageService instance] retrieveAllMessagesForThread:gmailThreadId];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    emailThreadTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, [[UIScreen mainScreen] bounds].size.height)];
    [self.emailThreadTable registerClass:[EmailCell class] forCellReuseIdentifier:mailCellIdentifier];
    emailThreadTable.delegate = self;
    emailThreadTable.dataSource = self;
    [self.view addSubview:emailThreadTable];
}

- (void)viewWillAppear:(BOOL)animated
{
    [emailThreadTable reloadData];
}

#pragma mark -
#pragma mark UITableViewDataSource & UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return dataSourceArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 90;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    EmailCell *cell = [tableView dequeueReusableCellWithIdentifier:mailCellIdentifier forIndexPath:indexPath];
    MCOIMAPMessage *message = [MCOIMAPMessage importSerializable:[dataSourceArray[indexPath.row] messageJSON]];
    if([(MessageModel*)dataSourceArray[indexPath.row] read]){
        cell.readLabel.backgroundColor = [UIColor clearColor];
    }else{
        cell.readLabel.backgroundColor = [UIColor colorWithHexString:@"#007AFF"];
    }
    [cell.detailDiscloser setHidden:YES];
    [cell.threadLabel setHidden:YES];
    NSTimeInterval interval = [message.header.date timeIntervalSinceNow];
    interval = -interval;
    if([message.header.date isToday]){
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"hh:mm a"];
        NSString *dateString = [dateFormatter stringFromDate:message.header.date];
        cell.dateLabel.text = dateString;
    }
    else{
        cell.dateLabel.text = [message.header.date timeAgo];
    }
    if(message.header.sender.displayName.length)
        cell.senderLabel.text = [NSString stringWithFormat:@"%@",message.header.sender.displayName];
    else
        cell.senderLabel.text = cell.senderLabel.text = [NSString stringWithFormat:@"%@",message.header.sender.mailbox];
    cell.subjectLabel.text = message.header.subject;
//    
    NSString *uidKey = [NSString stringWithFormat:@"%d", message.uid];
    NSString *cachedPreview = [EmailService instance].filterMessagePreviews[uidKey];
    if (cachedPreview)
    {
        cell.bodyLabel.text = cachedPreview;
    }
    else
    {
        cell.messageRenderingOperation = [[EmailService instance].imapSession plainTextBodyRenderingOperationWithMessage:message folder:INBOX];
        [cell.messageRenderingOperation start:^(NSString * plainTextBodyString, NSError * error) {
            cell.bodyLabel.text = plainTextBodyString;
            cell.messageRenderingOperation = nil;
            [EmailService instance].filterMessagePreviews[uidKey] = plainTextBodyString;
        }];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    MCOIMAPMessage *msg = [MCOIMAPMessage importSerializable:[(MessageModel*)dataSourceArray[indexPath.row] messageJSON]];
    [(MessageModel*)dataSourceArray[indexPath.row] setRead:YES];
    MsgViewController *vc = [[MsgViewController alloc] init];
    vc.folder = INBOX;
    vc.message = msg;
    vc.session = [EmailService instance].imapSession;
    msg.flags = msg.flags | MCOMessageFlagSeen;
    MCOIMAPOperation *msgOperation=[[EmailService instance].imapSession storeFlagsOperationWithFolder:INBOX uids:[MCOIndexSet indexSetWithIndex:msg.uid] kind:MCOIMAPStoreFlagsRequestKindAdd flags:MCOMessageFlagSeen];
    [msgOperation start:^(NSError * error)
     {
         NSLog(@"selected message flags %u UID is %u",msg.flags,msg.uid );
     }];
    [self setReadMessage:(MessageModel*)dataSourceArray[indexPath.row]];
    [self.navigationController pushViewController:vc animated:YES];

//    [self.mainVCdelegate pushViewController:vc];
}

#pragma mark -
#pragma mark Helper
- (void)setReadMessage:(MessageModel*)messageRead
{
    [messageRead setRead:YES];
    [[MessageService instance] updateMessage:messageRead];
}

#pragma mark -
#pragma mark Memory Management
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
