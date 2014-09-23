//
//  MsgViewController.m
//  FunnlMail
//
//  Created by Daniel Judd on 4/4/14.
//  Copyright (c) 2014 FunnlMail. All rights reserved.
//

// a bunch of code taken from: https://github.com/MailCore/mailcore2

#import "MsgViewController.h"
#import <CoreGraphics/CoreGraphics.h>
#import <ImageIO/ImageIO.h>
#import "MCOMessageView.h"
#import <MessageUI/MessageUI.h>
#import "AppDelegate.h"
#import "ComposeViewController.h"
#import <Mixpanel/Mixpanel.h>
#import "CreateFunnlViewController.h"
#import "FunnelService.h"
#import "EmailService.h"
#import "FunnelModel.h"
#import "FunnlPopUpView.h"
#import "FMCreateFunnlViewController.h"


@interface MsgViewController () <MCOMessageViewDelegate>

@end

@implementation MsgViewController

@synthesize folder = _folder;
@synthesize session = _session;
@synthesize selectedIndexPath;
@synthesize messageModel;
- (void) awakeFromNib
{
    _storage = [[NSMutableDictionary alloc] init];
    _ops = [[NSMutableArray alloc] init];
    _pending = [[NSMutableSet alloc] init];
    _callbacks = [[NSMutableDictionary alloc] init];
}

- (id)init {
    self = [super init];
    
    if(self) {
        [self awakeFromNib];
    }
    
    return self;
}

-(void)viewWillAppear:(BOOL)animated{
    [self.navigationController.navigationBar setBarTintColor:UIColorFromRGB(0xF7F7F7)];

}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor whiteColor]];
   
    [self setUpView];
    AppDelegate *tempAppDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    tempAppDelegate.headerViewForMailDetailView = headerView;
    UIView *seperator = [[UIView alloc] initWithFrame:CGRectMake(25, headerView.frame.origin.y + headerView.frame.size.height, WIDTH - 20, 0)];
    [seperator setBackgroundColor:[UIColor lightGrayColor]];
    
    subjectView.frame = CGRectMake(0, 0, WIDTH, subjectHeight + 20);
    
    _messageView = [[MCOMessageView alloc] initWithFrame:CGRectMake(0, 64, WIDTH, HEIGHT-44)];
    _messageView.tempMessageModel = _message;
    _messageView.webView.opaque = YES;
    _messageView.webView.backgroundColor = CLEAR_COLOR;
    [self.view addSubview:_messageView];

    messageTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, 2000)];
    [messageTableView setScrollEnabled:NO];
    messageTableView.delegate = self;
    messageTableView.dataSource = self;
    messageTableView.tableFooterView = seperator;
    [_messageView setHeaderViewHeight:headerView.frame.size.height];
    
    [_messageView setHeaderView:headerView];

    UIView *centeredButtons = [[UIView alloc]initWithFrame:CGRectMake(0, self.view.bounds.size.height-42, self.view.bounds.size.width, 42)];
    centeredButtons.backgroundColor = [UIColor colorWithHexString:@"FEFEFE"];
    //EBE6E9 spare color i was testing
    
    UIButton *replyButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIButton *replyAllButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIButton *forwardButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [replyButton addTarget:self action:@selector(replyButtonSelected) forControlEvents:UIControlEventTouchUpInside];
    replyButton.frame = CGRectMake(51, 0, 42, 42);
    [replyButton setImage:[UIImage imageNamed:@"emailDetailViewReply.png"] forState:UIControlStateNormal];
    [replyButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
    [replyButton setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
    [centeredButtons addSubview:replyButton];
    
    [replyAllButton addTarget:self action:@selector(replyAllButtonSelected) forControlEvents:UIControlEventTouchUpInside];
    replyAllButton.frame = CGRectMake(140, 0, 42, 42);
    [replyAllButton setImage:[UIImage imageNamed:@"emailDetailViewReplyAll.png"] forState:UIControlStateNormal];
    [replyAllButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
    [replyAllButton setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
    [centeredButtons addSubview:replyAllButton];

    [forwardButton addTarget:self action:@selector(forwardButtonSelected) forControlEvents:UIControlEventTouchUpInside];
    forwardButton.frame = CGRectMake(WIDTH - 42 - 51, 0, 42, 42);
    [forwardButton setImage:[UIImage imageNamed:@"emailDetailViewForward.png"] forState:UIControlStateNormal];
    [forwardButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
    [forwardButton setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
    [centeredButtons addSubview:forwardButton];
    
    UIView *topBorder = [[UIView alloc] initWithFrame:CGRectMake(0,0,self.view.bounds.size.width,1)];
    topBorder.backgroundColor = [UIColor lightGrayColor];
    [centeredButtons addSubview:topBorder];
    
    [self.view addSubview:centeredButtons];
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"FetchFullMessageEnabled"]) {
        [_messageView setDelegate:self];
        [_messageView setFolder:_folder];
        [_messageView setMessage:_message];
    }
    else {
        [_messageView setMessage:NULL];
        MCOIMAPFetchContentOperation * op = [_session fetchMessageByUIDOperationWithFolder:_folder uid:[_message uid]];
        [_ops addObject:op];
        [op start:^(NSError * error, NSData * data) {
            if ([error code] != MCOErrorNone) {
                return;
            }
            
            NSAssert(data != nil, @"data != nil");
            
            MCOMessageParser * msg = [MCOMessageParser messageParserWithData:data];
            [_messageView setDelegate:self];
            [_messageView setFolder:_folder];
            [_messageView setMessage:msg];
            
        }];
    }
    
    //customize back button.
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"backArrow.png"] style:UIBarButtonItemStylePlain target:self action:@selector(back)];
    [self.navigationItem setLeftBarButtonItem:leftButton];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 150, 40)];
    [titleLabel setFont:[UIFont systemFontOfSize:22]];
    [titleLabel setTextColor:[UIColor colorWithHexString:DONE_BUTTON_BLUE_COLOR]];
    if ([tempAppDelegate.currentFunnelString.lowercaseString isEqualToString:[ALL_FUNNL lowercaseString]] || [tempAppDelegate.currentFunnelString.lowercaseString isEqualToString:[ALL_OTHER_FUNNL lowercaseString]]) {
        self.navigationItem.title =@"";
    }
    else {
        self.navigationItem.title = @"";
    }
    
    UIBarButtonItem *funnelButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"emailDetailViewFunnel.png"] style:UIBarButtonItemStylePlain target:self action:@selector(createFunnl:)];
//    [self.navigationItem setLeftBarButtonItem:leftButton1];
    
    UIBarButtonItem *archiveButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"emailDetailViewArchive.png"] style:UIBarButtonItemStylePlain target:self action:@selector(archiveMail:)];
//    [self.navigationItem setLeftBarButtonItem:leftButton2];
    
    UIBarButtonItem *emailButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"emailDetailViewMail.png"] style:UIBarButtonItemStylePlain target:self action:@selector(unreadMail:)];
//    [self.navigationItem setLeftBarButtonItem:leftButton3];
    
    UIBarButtonItem *deleteButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"emailDetailViewTrash.png"] style:UIBarButtonItemStylePlain target:self action:@selector(deleteMail:)];
//    [self.navigationItem setLeftBarButtonItem:leftButton4];
    [self.navigationItem setRightBarButtonItems:[NSArray arrayWithObjects:deleteButton, archiveButton, emailButton, funnelButton, nil]];
}

-(void)updateWebView{
    CGFloat contentHeight = _messageView.webView.scrollView.contentSize.height;
    NSLog(@"----> %d %d",_messageView.height,contentHeight);

    CGRect frame = _messageView.webView.frame;
    frame.size.height = 1;
    _messageView.webView.frame = frame;
    CGSize fittingSize = [_messageView.webView sizeThatFits:CGSizeZero];
    frame.size = fittingSize;
    float wHeight = frame.size.height;
    wHeight = MAX(wHeight, 500);
    NSLog(@"size: %f, %f", fittingSize.width, fittingSize.height);
    _messageView.webView.frame = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, wHeight - 60);
    _messageView.frame = CGRectMake(_messageView.frame.origin.x, _messageView.frame.origin.y, _messageView.frame.size.width, wHeight - 60);
    NSLog(@"size: %f, %f", _messageView.webView.frame.size.width,  _messageView.webView.frame.size.height);
    
    
//    dispatch_async(dispatch_get_main_queue(), ^{
//        //webViewHeight = MAX(HEIGHT-40, _messageView.height+60);
//        _messageView.webView.scrollView.alwaysBounceVertical = NO;
//        _messageView.frame = CGRectMake(0, _messageView.frame.origin.y, _messageView.webView.frame.size.width, 2024);
//        _messageView.webView.frame = CGRectMake(0, _messageView.webView.frame.origin.y, _messageView.webView.frame.size.width, 2000);
////        [messageTableView setFrame:CGRectMake(0, 0, WIDTH, 1023)];
//        
//        [messageTableView reloadData];
//    });
}

#pragma mark -
#pragma mark Helper
- (void)setReadMessage:(MessageModel*)messageRead
{
    [messageRead setRead:NO];
    messageRead.read = FALSE;
    [[MessageService instance] updateMessage:messageRead];
}

- (void)setUpView
{
    headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, 100)];
    int padding = 0;
    UILabel *fromLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, padding + 10, 50, 16)];
    [fromLabel setTextAlignment:NSTextAlignmentLeft];
    [fromLabel setTextColor:[UIColor blackColor]];
    fromLabel.text = @"From:";
    [fromLabel setFont:[UIFont systemFontOfSize:16]];
    [headerView addSubview:fromLabel];
    fromLabel = nil;
    
    UIButton *fromValue = [[UIButton alloc] initWithFrame:CGRectMake(20 + 50 - 5, padding + 10, WIDTH - 20 - 50, 16)];
    [fromValue setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    if (_message.header.sender.displayName) {
        [fromValue setTitle:_message.header.sender.displayName forState:UIControlStateNormal];
    }
    else
        [fromValue setTitle:_message.header.sender.mailbox forState:UIControlStateNormal];
    [fromValue setTitleColor:[UIColor colorWithHexString:DONE_BUTTON_BLUE_COLOR] forState:UIControlStateNormal];
    [fromValue.titleLabel setFont:[UIFont systemFontOfSize:16]];
    [headerView addSubview:fromValue];
    fromValue = nil;
    
    UILabel *toLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, padding + 10 + 16 + 8, 25, 16)];
    [toLabel setTextAlignment:NSTextAlignmentLeft];
    [toLabel setTextColor:[UIColor blackColor]];
    toLabel.text = @"To:";
    [toLabel setFont:[UIFont systemFontOfSize:16]];
    [headerView addSubview:toLabel];
    toLabel = nil;

    int finalY = [self insertToAddress:_message.header.to withX:45 andY:padding + 10 + 16 + 8];
    if (_message.header.cc.count > 0) {
        UILabel *ccLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, finalY, 25, 16)];
        [ccLabel setTextAlignment:NSTextAlignmentLeft];
        [ccLabel setTextColor:[UIColor blackColor]];
        ccLabel.text = @"Cc:";
        [ccLabel setFont:[UIFont systemFontOfSize:16]];
        [headerView addSubview:ccLabel];
        ccLabel = nil;
        finalY = [self insertCCAddress:_message.header.cc withX:45 andY:finalY];
    }
    UIView *seperator = [[UILabel alloc] initWithFrame:CGRectMake(20, finalY, 300, 0.5)];
    [seperator setBackgroundColor:[UIColor lightGrayColor]];
    [headerView addSubview:seperator];
    seperator = nil;
    
    finalY = finalY + 5;
    
    headerView.frame = CGRectMake(0, 0, WIDTH, finalY);
    headerHeight = finalY;
    int height = [self calculateSize:_message.header.subject];
    subjectHeight = height;
    UILabel *subjectLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, finalY, 280, height + 5)]; // Added +5 to enable multi-line
    [subjectLabel setFont:[UIFont boldSystemFontOfSize:16]];
    subjectLabel.lineBreakMode = NSLineBreakByWordWrapping;
    subjectLabel.numberOfLines = 0;
    subjectLabel.text = _message.header.subject;
    
    [headerView addSubview:subjectLabel];
    headerView.frame = CGRectMake(headerView.frame.origin.x, headerView.frame.origin.y, headerView.frame.size.width, headerView.frame.size.height + height + 30);
    
    subjectView = [[UIView alloc] init];
//    [subjectView addSubview:subjectLabel];
    subjectLabel = nil;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"d MMMM yyyy h:mm a"]; //Changed by Chad
    UILabel *dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, finalY + height + 3, 280, 15)];
    [dateLabel setFont:[UIFont systemFontOfSize:14]];
    [dateLabel setTextColor:[UIColor blackColor]];
    dateLabel.text = [dateFormatter stringFromDate:_message.header.date];
    [headerView addSubview:dateLabel];
//    [subjectView addSubview:dateLabel];
    dateLabel = nil;
    
    seperator = [[UILabel alloc] initWithFrame:CGRectMake(20, headerView.frame.size.height - 1, 300, 0.5)];
    [seperator setBackgroundColor:[UIColor lightGrayColor]];
    [headerView addSubview:seperator];
    seperator = nil;
}

- (CGFloat)calculateSize:(NSString*)string
{
    CGSize maximumSize = CGSizeMake(280, 568);
    UIFont *myFont = [UIFont boldSystemFontOfSize:16];
    CGSize myStringSize = [string sizeWithFont:myFont constrainedToSize:maximumSize lineBreakMode:NSLineBreakByWordWrapping];
    return myStringSize.height;
}

- (int)insertCCAddress:(NSArray*)to withX:(int)x andY:(int)y{
    for (int counter = 0; counter < to.count; counter++) {
        NSString *toString = nil;
        if ([[_message.header.cc objectAtIndex:counter] displayName]) {
            toString = [[_message.header.cc objectAtIndex:counter] displayName];
        }
        else
            toString = [[_message.header.cc objectAtIndex:counter] mailbox];
        int expectedLength = [self getLengthOf:toString];
        if (expectedLength > (WIDTH - 40 - x)) {
            y = y + 16 + 8;
            x = 20;
        }
        UIButton *toValue = [[UIButton alloc] initWithFrame:CGRectMake(x+3, y, expectedLength, 16)];
        [toValue setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        if (toString) {
            [toValue setTitle:[NSString stringWithFormat:@"%@",toString] forState:UIControlStateNormal];
        }
        else
        {
            [toValue setTitle:[[_message.header.to objectAtIndex:0] mailbox] forState:UIControlStateNormal];
        }
        [toValue setTitleColor:[UIColor colorWithHexString:DONE_BUTTON_BLUE_COLOR] forState:UIControlStateNormal];
        [toValue.titleLabel setFont:[UIFont systemFontOfSize:16]];
        toValue.tag = CC_TAG_STARTING + counter;
        [headerView addSubview:toValue];
        toValue = nil;
        UIImageView *arrorImageView = [[UIImageView alloc] initWithFrame:CGRectMake(x + expectedLength-5, y, 16, 16)];
        [arrorImageView setImage:[UIImage imageNamed:@"arrow.png"]];
        [headerView addSubview:arrorImageView];
        arrorImageView = nil;
        x = x + expectedLength + 15;
    }
    return y + 16 + 8;
}

- (int)insertToAddress:(NSArray*)to withX:(int)x andY:(int)y{
    for (int counter = 0; counter < to.count; counter++) {
        NSString *toString = nil;
        if ([[_message.header.to objectAtIndex:counter] displayName]) {
            toString = [[_message.header.to objectAtIndex:counter] displayName];
        }
        else
            toString = [[_message.header.to objectAtIndex:counter] mailbox];
        int expectedLength = [self getLengthOf:toString];
        if (expectedLength > (WIDTH - 40 - x)) {
            y = y + 16 + 8;
            x = 20;
        }
        UIButton *toValue = [[UIButton alloc] initWithFrame:CGRectMake(x, y, expectedLength, 16)];
        [toValue setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        if (toString) {
            [toValue setTitle:[NSString stringWithFormat:@"%@",toString] forState:UIControlStateNormal];
        }
        else
        {
            [toValue setTitle:[[_message.header.to objectAtIndex:0] mailbox] forState:UIControlStateNormal];
        }
        [toValue setTitleColor:[UIColor colorWithHexString:DONE_BUTTON_BLUE_COLOR] forState:UIControlStateNormal];
        [toValue.titleLabel setFont:[UIFont systemFontOfSize:16]];
        toValue.tag = TO_TAG_STARTING + counter;
        [headerView addSubview:toValue];
        toValue = nil;
        UIImageView *arrorImageView = [[UIImageView alloc] initWithFrame:CGRectMake(x + expectedLength-5, y, 16, 16)];
        [arrorImageView setImage:[UIImage imageNamed:@"arrow.png"]];
        [headerView addSubview:arrorImageView];
        arrorImageView = nil;
        x = x + expectedLength + 15;
    }
    return y + 16 + 8;
}

- (CGFloat)getLengthOf:(NSString*)string {
    UIFont *font = [UIFont systemFontOfSize:16];
    NSDictionary *userAttributes = @{NSFontAttributeName: font, NSForegroundColorAttributeName: [UIColor blackColor]};
    CGSize sizeNeeded = [string sizeWithAttributes:userAttributes];
    return sizeNeeded.width + 5;
}

#pragma mark -
#pragma mark UITableViewDelegate & DataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (indexPath.row == 0) {
        [cell.contentView addSubview:headerView];
    }
    else if (indexPath.row == 1)
        [cell.contentView addSubview:subjectView];
    else{
        
    }
        //[cell.contentView addSubview:_messageView];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        return headerHeight;
    }
    else if (indexPath.row == 1)
        return subjectView.frame.size.height + 20;
    else
        return webViewHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark -
#pragma mark EventHandler
- (void)unreadMail:(UIButton*)sender {
    _message.flags = MCOMessageFlagNone;
    MCOIMAPOperation *msgOperation=[[EmailService instance].imapSession storeFlagsOperationWithFolder:self.folder uids:[MCOIndexSet indexSetWithIndex:_message.uid] kind:MCOIMAPStoreFlagsRequestKindAdd flags:MCOMessageFlagSeen];
    [msgOperation start:^(NSError * error)
     {
         NSLog(@"selected message flags %u UID is %u",_message.flags,_message.uid );
     }];
    [self setReadMessage:messageModel];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)deleteMail:(UIButton*)sender {
    
    NSString *uidKey = [NSString stringWithFormat:@"%d",_message.uid];
    [[MessageService instance] deleteMessage:uidKey];
    MCOIMAPCopyMessagesOperation *opt = [[EmailService instance].imapSession copyMessagesOperationWithFolder:self.folder uids:[MCOIndexSet indexSetWithIndex:_message.uid] destFolder:TRASH];
    [opt start:^(NSError *error, NSDictionary *uidMapping) {
        NSLog(@"copied to folder with UID %@", uidMapping);
    }];
    [[EmailService instance].filterMessagePreviews removeObjectForKey:uidKey];
    [[EmailService instance].filterMessages removeObjectAtIndex:selectedIndexPath.row];
    [[EmailService instance].messages removeObjectIdenticalTo:_message];
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)archiveMail:(UIButton*)sender {
    
    NSString *uidKey = [NSString stringWithFormat:@"%d",_message.uid];
    [[MessageService instance] deleteMessage:uidKey];
    MCOIMAPOperation *msgOperation = [[EmailService instance].imapSession storeFlagsOperationWithFolder:self.folder uids:[MCOIndexSet indexSetWithIndex:_message.uid] kind:MCOIMAPStoreFlagsRequestKindAdd flags:MCOMessageFlagDeleted];
    [msgOperation start:^(NSError * error)
     {
         NSLog(@"selected message flags %u UID is %u",_message.flags,_message.uid );
     }];
    [[EmailService instance].filterMessagePreviews removeObjectForKey:uidKey];
    [[EmailService instance].filterMessages removeObjectAtIndex:selectedIndexPath.row];
    [[EmailService instance].messages removeObjectIdenticalTo:_message];
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)createFunnl:(UIButton*)sender{
    AppDelegate *appDelegate = APPDELEGATE;
    NSString *uidKey = [NSString stringWithFormat:@"%d",_message.uid];
    FunnlPopUpView *funnlPopUpView = [[FunnlPopUpView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) withNewPopup:YES withMessageId:uidKey withMessage:_message subViewOnViewController:self];
    funnlPopUpView.mainVCdelegate = appDelegate.mainVCdelegate;
    if ([FunnelService instance].allFunnels.count < 4){
    }
    [self.view addSubview:funnlPopUpView];

}

//newly added by iauro001 on 24th June 2014
- (void)back
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) setMessage:(MCOIMAPMessage *)message
{
	MCLog("set message : %s", message.description.UTF8String);
    NSLog(@"set message : %s", message.description.UTF8String);
    for(MCOOperation * op in _ops) {
        [op cancel];
    }
    [_ops removeAllObjects];
    
    [_callbacks removeAllObjects];
    [_pending removeAllObjects];
    [_storage removeAllObjects];
    _message = message;
}

- (MCOIMAPMessage *) message
{
    return _message;
}

- (MCOIMAPFetchContentOperation *) _fetchIMAPPartWithUniqueID:(NSString *)partUniqueID folder:(NSString *)folder
{
    MCLog("%s is missing, fetching", partUniqueID.description.UTF8String);
    
    if ([_pending containsObject:partUniqueID]) {
        return nil;
    }
    
    MCOIMAPPart * part = (MCOIMAPPart *) [_message partForUniqueID:partUniqueID];
    NSAssert(part != nil, @"part != nil");
    
    [_pending addObject:partUniqueID];
    
    MCOIMAPFetchContentOperation * op = [_session fetchMessageAttachmentByUIDOperationWithFolder:folder uid:[_message uid] partID:[part partID] encoding:[part encoding]];
    [_ops addObject:op];
    [op start:^(NSError * error, NSData * data) {
        if ([error code] != MCOErrorNone) {
            [self _callbackForPartUniqueID:partUniqueID error:error];
            return;
        }
        
        NSAssert(data != NULL, @"data != nil");
        [_ops removeObject:op];
        [_storage setObject:data forKey:partUniqueID];
        [_pending removeObject:partUniqueID];
        MCLog("downloaded %s", partUniqueID.description.UTF8String);
        
        [self _callbackForPartUniqueID:partUniqueID error:nil];
    }];
    
    return op;
}

typedef void (^DownloadCallback)(NSError * error);

- (void) _callbackForPartUniqueID:(NSString *)partUniqueID error:(NSError *)error
{
    NSArray * blocks;
    blocks = [_callbacks objectForKey:partUniqueID];
    for(DownloadCallback block in blocks) {
        block(error);
    }
}

- (void) MCOMessageView:(MCOMessageView *)view getFunlShareString:(NSString *)dataString;
{
    if(dataString.length){
        NSData *decodedData = [[NSData alloc] initWithBase64EncodedString:dataString options:0];
        NSError *error = nil;
        id jsonObj = [NSJSONSerialization JSONObjectWithData:decodedData options:kNilOptions error:&error];
        BOOL isValid = [NSJSONSerialization isValidJSONObject:jsonObj];
        if(isValid){
            NSString *decodedString = [[NSString alloc] initWithData:decodedData encoding:NSUTF8StringEncoding];
            NSLog(@"%@", decodedString);
            NSData *data = [decodedString dataUsingEncoding:NSUTF8StringEncoding];
            id json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            if([json isKindOfClass:[NSDictionary class]]){
                NSString *name = [json objectForKey:@"name"];
                NSArray *sendersArray = [json objectForKey:@"senders"];
                NSArray *subjectsArray = [json objectForKey:@"subjects"];
                
                
//                BOOL isFunnlAlreadyPresent = NO;
//                NSArray *exisitngfunnlsArray = [[FunnelService instance] allFunnels];
//                for (FunnelModel *fm in exisitngfunnlsArray) {
//                    if([[fm.filterTitle lowercaseString] isEqualToString:[name lowercaseString]]){
//                        isFunnlAlreadyPresent = YES;
//                        break;
//                    }
//                }
//                
//                if(isFunnlAlreadyPresent){
//                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"FunnlMail" message:@"Funnl is already present, please rename the exisiting funnl and try again." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
//                    [alert show];
//                    return;
//                }
                [MBProgressHUD showHUDAddedTo:self.view animated:YES];

                NSArray *randomColors = GRADIENT_ARRAY;
                NSInteger gradientInt = randomColors.count;
                NSString *colorString = [randomColors objectAtIndex:gradientInt];
                UIColor *color = [UIColor colorWithHexString:colorString];
                if(color == nil){
                    color = [UIColor colorWithHexString:@"#F7F7F7"];
                }
                FunnelModel *funnlModel = [[FunnelModel alloc] initWithBarColor:color filterTitle:name newMessageCount:0 dateOfLastMessage:nil sendersArray:sendersArray subjectsArray:subjectsArray skipAllFlag:NO funnelColor:colorString];
                [self performSelector:@selector(createFunnlFromShareLink:) withObject:funnlModel afterDelay:0.01];
              
                // save to db
            }
        }
        else{
            NSLog(@"%@",error.description);
        }
    }
}

-(void)createFunnlFromShareLink:(FunnelModel*)fm{

    NSMutableDictionary *sendersDictionary = [[NSMutableDictionary alloc] init];
    int count = 0;
    for (NSString *address in fm.sendersArray) {
        [sendersDictionary setObject:[address lowercaseString] forKey:[NSIndexPath indexPathForRow:count inSection:1]];
        count ++;
    }
    
    NSMutableDictionary *subjectsDictionary = [[NSMutableDictionary alloc] init];
    count = 0;
    for (NSString *subject in fm.subjectsArray) {
        if (![subject isEqualToString:@""])
        {
            [subjectsDictionary setObject:[subject lowercaseString] forKey:[NSIndexPath indexPathForRow:count inSection:2]];
            count ++;
        }
    }

    if(IS_NEW_CREATE_FUNNEL){
        FMCreateFunnlViewController *viewController = [[FMCreateFunnlViewController alloc] initWithSelectedContactArray:[sendersDictionary allValues] name:nil andSubjects:[subjectsDictionary allValues]];
//        viewController.mainVCdelegate = self.mainVCdelegate;
//        [self.mainVCdelegate pushViewController:viewController];
//        viewController = nil;

    }
    else{
        CreateFunnlViewController *creatFunnlViewController = [[CreateFunnlViewController alloc] initTableViewWithSenders:sendersDictionary subjects:subjectsDictionary filterModel:fm];
        creatFunnlViewController.isEdit = NO;
        [self.navigationController pushViewController:creatFunnlViewController animated:YES];
        creatFunnlViewController = nil;
    }
    
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
}

- (NSString *) MCOMessageView_templateForAttachment:(MCOMessageView *)view
{
    return @"<div><img src=\"http://www.iconshock.com/img_jpg/OFFICE/general/jpg/128/attachment_icon.jpg\"/></div>\
    {{#HASSIZE}}\
    <div>- {{FILENAME}}, {{SIZE}}</div>\
    {{/HASSIZE}}\
    {{#NOSIZE}}\
    <div>- {{FILENAME}}</div>\
    {{/NOSIZE}}";
}

- (NSString *) MCOMessageView_templateForMessage:(MCOMessageView *)view
{
    return @"<div style=\"padding-bottom: 20px; font-family: Helvetica; font-size: 13px;\">{{HEADER}}</div><div>{{BODY}}</div>";
}

- (BOOL) MCOMessageView:(MCOMessageView *)view canPreviewPart:(MCOAbstractPart *)part
{
    // tiff, tif, pdf
    NSString * mimeType = [[part mimeType] lowercaseString];
    if ([mimeType isEqualToString:@"image/tiff"]) {
        return YES;
    }
    else if ([mimeType isEqualToString:@"image/tif"]) {
        return YES;
    }
    else if ([mimeType isEqualToString:@"application/pdf"]) {
        return YES;
    }
    
    NSString * ext = nil;
    if ([part filename] != nil) {
        if ([[part filename] pathExtension] != nil) {
            ext = [[[part filename] pathExtension] lowercaseString];
        }
    }
    if (ext != nil) {
        if ([ext isEqualToString:@"tiff"]) {
            return YES;
        }
        else if ([ext isEqualToString:@"tif"]) {
            return YES;
        }
        else if ([ext isEqualToString:@"pdf"]) {
            return YES;
        }
    }
    
    return NO;
}

- (NSString *) MCOMessageView:(MCOMessageView *)view filteredHTML:(NSString *)html
{
    return html;
}

- (NSData *) MCOMessageView:(MCOMessageView *)view dataForPartWithUniqueID:(NSString *)partUniqueID
{
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"FetchFullMessageEnabled"]) {
		MCOAttachment * attachment = (MCOAttachment *) [[_messageView message] partForUniqueID:partUniqueID];
		return [attachment data];
	}
	else {
		NSData * data = [_storage objectForKey:partUniqueID];
		return data;
	}
    //[self updateWebView];
}

- (void) MCOMessageView:(MCOMessageView *)view fetchDataForPartWithUniqueID:(NSString *)partUniqueID
     downloadedFinished:(void (^)(NSError * error))downloadFinished
{

    MCOIMAPFetchContentOperation * op = [self _fetchIMAPPartWithUniqueID:partUniqueID folder:_folder];
    [op setProgress:^(unsigned int current, unsigned int maximum) {
        MCLog("progress content: %u/%u", current, maximum);
    }];
    if (op != nil) {
        [_ops addObject:op];
    }
    if (downloadFinished != NULL) {
        NSMutableArray * blocks;
        blocks = [_callbacks objectForKey:partUniqueID];
        if (blocks == nil) {
            blocks = [NSMutableArray array];
            [_callbacks setObject:blocks forKey:partUniqueID];
        }
        [blocks addObject:[downloadFinished copy]];
    }
    //[self updateWebView];
}

- (void) MCOMessageViewLoadingCompleted:(MCOMessageView *)view;
{
    //[self updateWebView];
}

- (NSData *) MCOMessageView:(MCOMessageView *)view previewForData:(NSData *)data isHTMLInlineImage:(BOOL)isHTMLInlineImage
{
    if (isHTMLInlineImage) {
        return data;
    }
    else {
        return [self _convertToJPEGData:data];
    }
}

#define IMAGE_PREVIEW_HEIGHT 300
#define IMAGE_PREVIEW_WIDTH 500

- (NSData *) _convertToJPEGData:(NSData *)data {
    NSLog(@"Got here");
    CGImageSourceRef imageSource;
    CGImageRef thumbnail;
    NSMutableDictionary * info;
    int width;
    int height;
    float quality;
    
    width = IMAGE_PREVIEW_WIDTH;
    height = IMAGE_PREVIEW_HEIGHT;
    quality = 1.0;
    
    imageSource = CGImageSourceCreateWithData((__bridge CFDataRef) data, NULL);
    if (imageSource == NULL)
        return nil;
    
    info = [[NSMutableDictionary alloc] init];
    [info setObject:(id) kCFBooleanTrue forKey:(__bridge id) kCGImageSourceCreateThumbnailWithTransform];
    [info setObject:(id) kCFBooleanTrue forKey:(__bridge id) kCGImageSourceCreateThumbnailFromImageAlways];
    [info setObject:(id) [NSNumber numberWithFloat:(float) IMAGE_PREVIEW_WIDTH] forKey:(__bridge id) kCGImageSourceThumbnailMaxPixelSize];
    thumbnail = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, (__bridge CFDictionaryRef) info);
    
    CGImageDestinationRef destination;
    NSMutableData * destData = [NSMutableData data];
    
    destination = CGImageDestinationCreateWithData((__bridge CFMutableDataRef) destData,
                                                   (CFStringRef) @"public.jpeg",
                                                   1, NULL);
    
    CGImageDestinationAddImage(destination, thumbnail, NULL);
    CGImageDestinationFinalize(destination);
    
    CFRelease(destination);
    
    CFRelease(thumbnail);
    CFRelease(imageSource);
    
    return destData;
}


-(void) replyButtonSelected{
#ifdef TRACK_MIXPANEL
    [[Mixpanel sharedInstance] track:@"Reply Email Selected"];
#endif
    NSLog(@"reply Email selected");
    ComposeViewController *viewEmail = [[ComposeViewController alloc]init];
    viewEmail.address = self.message.header.from;
    viewEmail.message = _message;
    viewEmail.folder = _folder;
    viewEmail.imapSession = _session;
    viewEmail.reply = @1;
    [self.navigationController pushViewController:viewEmail animated:YES];
}

-(void) replyAllButtonSelected{
#ifdef TRACK_MIXPANEL
    [[Mixpanel sharedInstance] track:@"Reply All selected"];
#endif
    NSLog(@"reply Email selected");
    ComposeViewController *viewEmail = [[ComposeViewController alloc]init];
    viewEmail.addressArray = self.message.header.to;
    viewEmail.address = self.message.header.from;
    viewEmail.message = _message;
    viewEmail.folder = _folder;
    viewEmail.imapSession = _session;
    viewEmail.replyAll = @1;
    [self.navigationController pushViewController:viewEmail animated:YES];
}

-(void) forwardButtonSelected{
#ifdef TRACK_MIXPANEL
    [[Mixpanel sharedInstance] track:@"Forward selected"];
#endif
    NSLog(@"reply Email selected");
    ComposeViewController *viewEmail = [[ComposeViewController alloc]init];
    viewEmail.message = _message;
    viewEmail.folder = _folder;
    viewEmail.imapSession = _session;
    viewEmail.forward = @1;
    [self.navigationController pushViewController:viewEmail animated:YES];
}


@end
