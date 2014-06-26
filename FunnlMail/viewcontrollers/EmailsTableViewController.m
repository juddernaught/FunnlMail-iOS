//
//  EmailsTableViewController.m
//  FunnlMail
//
//  Created by Daniel Judd on 5/26/14.
//  Copyright (c) 2014 FunnlMail. All rights reserved.
//

#import "EmailsTableViewController.h"
#import "EmailService.h"
#import "MBProgressHUD.h"
#import "FilterViewCell.h"
#import "View+MASAdditions.h"
//#import "FilterModel.h"
#import "FunnelModel.h"
#import <MailCore/MailCore.h>
#import "EmailCell.h"
#import "MsgViewController.h"
#import "KeychainItemWrapper.h"
#import "EmailService.h"
#import "CreateFunnlviewController.h"
#import "UIColor+HexString.h"
#import "NSDate+TimeAgo.h"
#import "FunnlPopUpView.h"

static NSString *FILTER_VIEW_CELL = @"FilterViewCell";
static NSString *mailCellIdentifier = @"MailCell";
static NSString *inboxInfoIdentifier = @"InboxStatusCell";

@interface EmailsTableViewController ()
@end

@implementation EmailsTableViewController
@synthesize tablecontroller,activityIndicator;

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

- (void)viewDidLoad
{
    [super viewDidLoad];
    tempAppDelegate = APPDELEGATE;
    [[EmailService instance] startLogin: self];
    [self setupView];
    // MUSTFIX: code doesn't work without below line, but it doesn't seem like it really belongs
    self.emailFolder = INBOX;
    searchMessages = [[NSMutableArray alloc] init];
    isSearching = NO;
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
}

- (void)viewWillAppear:(BOOL)animated
{
    if ([EmailService instance].filterMessages.count > 0) {
        [self.tableView reloadData];
    }
    funnlArray = [[FunnelService instance] allFunnels];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (void)setupView
{
    
	// Do any additional setup after loading the view.
    self.view.backgroundColor= [UIColor grayColor];
    
    //    filterNavigationView = [[UIView alloc]initWithFrame:CGRectMake(0, 44, 320, 40)];
    //    filterNavigationView.backgroundColor = [UIColor orangeColor];
    //    [self.view addSubview:filterNavigationView];
    
    /*[filterNavigationView mas_makeConstraints:^(MASConstraintMaker *make) {
     make.top.equalTo(self.view.mas_top).with.offset(44); // we should calculate this (self.topLayoutGuide.length?)
     make.left.equalTo(self.view.mas_left).with.offset(0);
     make.right.equalTo(self.view.mas_right).with.offset(0);
     }];*/
    
    
    // This is the green or purple All bar
    
//    AppDelegate *tempAppDelegate = APPDELEGATE;
    
    filterLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 44+20, 320, 40)];
    [self.view addSubview:tempAppDelegate.progressHUD];
    [self.view bringSubviewToFront:tempAppDelegate.progressHUD];
    [tempAppDelegate.progressHUD show:YES];
    [tempAppDelegate.progressHUD setHidden:NO];
    activityIndicator = tempAppDelegate.appActivityIndicator;
    [activityIndicator setBackgroundColor:[UIColor clearColor]];
    [activityIndicator startAnimating];
    [filterLabel addSubview:activityIndicator];
    filterLabel.textColor = [UIColor whiteColor];
    filterLabel.backgroundColor = (self.filterModel!=nil ? self.filterModel.barColor : [UIColor colorWithHexString:@"#2EB82E"]);
    filterLabel.text = (self.filterModel!=nil ? self.filterModel.filterTitle : @"Alllllllllllllllllll");
    filterLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:filterLabel];
    
    
    
    /*
     [filterLabel mas_makeConstraints:^(MASConstraintMaker *make) {
     make.top.equalTo(filterNavigationView.mas_top).with.offset(0);
     make.left.equalTo(filterNavigationView.mas_left).with.offset(0);
     make.right.equalTo(filterNavigationView.mas_right).with.offset(0);
     make.bottom.equalTo(filterNavigationView.mas_bottom).with.offset(0);
     }];
     
     */
    
    //<<<<<<< HEAD
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    
    refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Pull to Refresh"];
    [refreshControl addTarget:self action:@selector(fetchLatestEmail) forControlEvents:UIControlEventValueChanged];
    tablecontroller = [[UITableViewController alloc] init];
    //=======
    
    
    //>>>>>>> newbranch
    //<<<<<<< HEAD
    //    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-104)];
    //=======
    
    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height-64)];
    UIView *tempView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    self.tableView.tableFooterView = tempView;
    tempView = nil;
    //>>>>>>> Change 2
    tablecontroller.tableView = self.tableView;
    tablecontroller.refreshControl = refreshControl;
    self.tableView.rowHeight = 71.0;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.tableView registerClass:[FilterViewCell class] forCellReuseIdentifier:FILTER_VIEW_CELL];
    //<<<<<<< HEAD
    [self.view addSubview:tablecontroller.view];
    //=======
    [self.view addSubview:self.tableView];
    //>>>>>>> newbranch
    // TODO: change self.view.mas_top to bottom of filter label
    /*[self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
     //make.top.equalTo(filterNavigationView.mas_top).with.offset(0);
     make.left.equalTo(self.view.mas_left).with.offset(0);
     make.right.equalTo(self	.view.mas_right).with.offset(0);
     make.bottom.equalTo(self.view.mas_bottom).with.offset(0);
     }];*/
    
	[self.tableView registerClass:[EmailCell class] forCellReuseIdentifier:mailCellIdentifier];
    
	self.loadMoreActivityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    mailSearchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 40)];
    mailSearchBar.delegate = self;
    self.tableView.tableHeaderView = mailSearchBar;
    //    searchDisplayController = [[UISearchDisplayController alloc] initWithSearchBar:searchBar contentsController:self];
    //    searchDisplayController.delegate = self;
    //    searchDisplayController.searchResultsDataSource = self;
    //    searchDisplayController.searchResultsDelegate = self;
    //[self.tableView insertSubview:self.searchDisplayController.searchBar aboveSubview:self.tableView];
    if ([[MessageService instance] messagesAllTopMessages].count > 0) {
        
    }
    else
        [self.view bringSubviewToFront:tempAppDelegate.progressHUD];
}

- (void)fetchLatestEmail
{
//    [self.view bringSubviewToFront:tempAppDelegate.progressHUD];
//    [tempAppDelegate.progressHUD show:YES];
//    [tempAppDelegate.progressHUD setHidden:NO];
    [activityIndicator startAnimating];
    [[EmailService instance] loadLatestMail:1 withTableController:self withFolder:INBOX];
}

-(void) setFilterModel:(FunnelModel *)filterModel{
    _filterModel = filterModel;
    if(self.emailFolder == nil || self.emailFolder.length <= 0){
        self.emailFolder = INBOX;
    }
    
    if(filterLabel!=nil){
        filterLabel.backgroundColor = (self.filterModel!=nil ? self.filterModel.barColor : [UIColor colorWithHexString:@"#2EB82E"]);
        filterLabel.text = (self.filterModel!=nil ? self.filterModel.filterTitle : @"All");
        [[EmailService instance] loadLastNMessages:[EmailService instance].messages.count withTableController:self withFolder:self.emailFolder];
    }
}

/*- (void)searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller {
 self.tableView.tableHeaderView = searchBar;
 }*/

- (void)searchDisplayController:(UISearchDisplayController *)controller didLoadSearchResultsTableView:(UITableView *)tableView
{
	[tableView registerClass:[EmailCell class] forCellReuseIdentifier:mailCellIdentifier];
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if ([tempAppDelegate.currentFunnelString isEqualToString:@"all"]) {
        return 2;
    }
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if(isSearching == NO){
        if (section == 1)
        {
            if ([EmailService instance].totalNumberOfInboxMessages >= 0 || [EmailService instance].filterMessages.count > 0)
                return 1;
            return 0;
        }
        return [EmailService instance].filterMessages.count;
    }
    else{
        return searchMessages.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(isSearching == NO){
        switch (indexPath.section){
            case 0:{
                EmailCell *cell = [tableView dequeueReusableCellWithIdentifier:mailCellIdentifier forIndexPath:indexPath];
                cell.delegate = self;
                MCOIMAPMessage *message = [MCOIMAPMessage importSerializable:[(MessageModel*)[EmailService instance].filterMessages[indexPath.row] messageJSON]];
                if ([(MessageModel*)[EmailService instance].filterMessages[indexPath.row] numberOfEmailInThread] > 1) {
                    if ([self isThreadRead:[NSString stringWithFormat:@"%llul",message.gmailThreadID]])
                        cell.readLabel.backgroundColor = [UIColor clearColor];
                    else
                        cell.readLabel.backgroundColor = [UIColor colorWithHexString:@"#007AFF"];
                }
                else{
                    if([(MessageModel*)[EmailService instance].filterMessages[indexPath.row] read])
                        cell.readLabel.backgroundColor = [UIColor clearColor];
                    else
                        cell.readLabel.backgroundColor = [UIColor colorWithHexString:@"#007AFF"];
                }
                
                NSTimeInterval interval = [message.header.date timeIntervalSinceNow];
                interval = -interval;
                if (interval <= 24*60*60) {
                    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                    [dateFormatter setDateFormat:@"hh:mm a"];
                    NSString *dateString = [dateFormatter stringFromDate:message.header.date];
                    cell.dateLabel.text = dateString.uppercaseString;
                }
                else
                    cell.dateLabel.text = [message.header.date timeAgo];
//                if([message.header.date isToday]){
//                    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//                    [dateFormatter setDateFormat:@"hh:mm a"];
//                    NSString *dateString = [dateFormatter stringFromDate:message.header.date];
//                    cell.dateLabel.text = dateString.uppercaseString;
//                }
//                else
//                    cell.dateLabel.text = [message.header.date timeAgo];
                if(message.header.sender.displayName.length)
                    cell.senderLabel.text = [NSString stringWithFormat:@"%@",message.header.sender.displayName];
                else
                    cell.senderLabel.text = cell.senderLabel.text = [NSString stringWithFormat:@"%@",message.header.sender.mailbox];
                
                CGFloat tempFloat = [self findTheSizeOf:cell.senderLabel.text];
                
                if (tempFloat < 320-105-6-60) {
                    cell.inclusiveFunnels.frame = CGRectMake(cell.senderLabel.frame.origin.x + tempFloat + 5, cell.senderLabel.frame.origin.y, WIDTH - cell.senderLabel.frame.origin.x - tempFloat - 80, 40);
                    [cell.inclusiveFunnels setBackgroundColor:[UIColor clearColor]];
                }
                else {
                    cell.inclusiveFunnels.frame = CGRectMake(32 + (320-105-6-60) + 5, cell.senderLabel.frame.origin.y, WIDTH - cell.senderLabel.frame.origin.y - tempFloat - 80, 40);
                    [cell.inclusiveFunnels setBackgroundColor:[UIColor clearColor]];
                }
                
                if (indexPath.row % 2 == 0) {
                    UIView *funnelView = [[UIView alloc] initWithFrame:CGRectMake(2, 4, 12, 12)];
                    funnelView.clipsToBounds = YES;
                    funnelView.layer.cornerRadius = 6.0f;
                    [funnelView setBackgroundColor:[UIColor orangeColor]];
                    [cell.inclusiveFunnels addSubview:funnelView];
                    funnelView = nil;
                    funnelView = [[UIView alloc] initWithFrame:CGRectMake(2 + 12 + 2, 4, 12, 12)];
                    funnelView.clipsToBounds = YES;
                    funnelView.layer.cornerRadius = 6.0f;
                    [funnelView setBackgroundColor:[UIColor greenColor]];
                    [cell.inclusiveFunnels addSubview:funnelView];
                    funnelView = nil;
                }
                else {
                    UIView *funnelView = [[UIView alloc] initWithFrame:CGRectMake(2, 4, 12, 12)];
                    funnelView.clipsToBounds = YES;
                    funnelView.layer.cornerRadius = 6.0f;
                    [funnelView setBackgroundColor:[UIColor purpleColor]];
                    [cell.inclusiveFunnels addSubview:funnelView];
                    funnelView = nil;
                    funnelView = [[UIView alloc] initWithFrame:CGRectMake(2 + 12 + 2, 4, 12, 12)];
                    funnelView.clipsToBounds = YES;
                    funnelView.layer.cornerRadius = 6.0f;
                    [funnelView setBackgroundColor:[UIColor redColor]];
                    [cell.inclusiveFunnels addSubview:funnelView];
                    funnelView = nil;
                }
                cell.subjectLabel.text = message.header.subject;
                
                if([(MessageModel*)[EmailService instance].filterMessages[indexPath.row] numberOfEmailInThread] > 1){
                    cell.threadLabel.text = [NSString stringWithFormat:@"%d",[(MessageModel*)[EmailService instance].filterMessages[indexPath.row] numberOfEmailInThread]];
                    [cell.threadLabel setHidden:NO];
                    [cell.detailDiscloser setHidden:NO];
                }
                else{
                    cell.threadLabel.text = @"";
                    [cell.threadLabel setHidden:YES];
                    [cell.detailDiscloser setHidden:YES];
                }
                
                NSString *uidKey = [NSString stringWithFormat:@"%d", message.uid];
                NSString *cachedPreview = [EmailService instance].filterMessagePreviews[uidKey];
                if (cachedPreview)
                    cell.bodyLabel.text = cachedPreview;
                else{
                    cell.messageRenderingOperation = [[EmailService instance].imapSession plainTextBodyRenderingOperationWithMessage:message folder:self.emailFolder];
                    [cell.messageRenderingOperation start:^(NSString * plainTextBodyString, NSError * error) {
                        if (plainTextBodyString) {
                            if (plainTextBodyString.length > 0) {
                                if ([[plainTextBodyString substringWithRange:NSMakeRange(0, 1)] isEqualToString:@" "]) {
                                    cell.bodyLabel.text = [plainTextBodyString substringWithRange:NSMakeRange(1, plainTextBodyString.length - 1)];
                                }
                            }
                        }
                        cell.messageRenderingOperation = nil;
                        if(plainTextBodyString)
                            [EmailService instance].filterMessagePreviews[uidKey] = plainTextBodyString;
                    }];
                }
                
                UIView *archiveView = [self viewWithImageName:@"archive"];
                UIColor *yellowColor = [UIColor colorWithHexString:@"#F9CA47"];
                
                UIView *fullFunnlView = [self viewWithImageName:@"FunnlNew1"];
//                UIColor *fullFunnlColor = [UIColor colorWithHexString:@"#4068AE"];
                UIColor *fullFunnlColor = [UIColor colorWithHexString:@"#43F377"];
                
                UIView *halfFunnlView = [self viewWithImageName:@"FunnlNew1"];
//                UIColor *halfFunnlColor = [UIColor colorWithHexString:@"#448DEC"];
                UIColor *halfFunnlColor = [UIColor colorWithHexString:@"#4487E9"];
                
                [cell setSwipeGestureWithView:archiveView color:yellowColor mode:MCSwipeTableViewCellModeExit state:MCSwipeTableViewCellState1 completionBlock:^(MCSwipeTableViewCell *cell, MCSwipeTableViewCellState state, MCSwipeTableViewCellMode mode) {
                    NSLog(@"Did swipe \"Archive\" cell");
                    MCOIMAPOperation *msgOperation = [[EmailService instance].imapSession storeFlagsOperationWithFolder:self.emailFolder uids:[MCOIndexSet indexSetWithIndex:message.uid] kind:MCOIMAPStoreFlagsRequestKindAdd flags:MCOMessageFlagDeleted];
                    [msgOperation start:^(NSError * error)
                     {
                         [tableView beginUpdates];
                         [[EmailService instance].filterMessagePreviews removeObjectForKey:uidKey];
                         [[EmailService instance].filterMessages removeObjectAtIndex:indexPath.row];
                         [[EmailService instance].messages removeObjectIdenticalTo:message];
                         [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationLeft];
                         [tableView endUpdates];
                         NSLog(@"selected message flags %u UID is %u",message.flags,message.uid );
                     }];
                    [cell swipeToOriginWithCompletion:nil];
                }];
                
                if(funnlArray.count){
                    cell.firstTrigger = 0.1;
                    cell.secondTrigger = 0.5;
                    [cell setSwipeGestureWithView:halfFunnlView color:halfFunnlColor mode:MCSwipeTableViewCellModeSwitch state:MCSwipeTableViewCellState3 completionBlock:^(MCSwipeTableViewCell *cell, MCSwipeTableViewCellState state, MCSwipeTableViewCellMode mode) {
                        NSLog(@"Did swipe Half cell,  ");
                        if ([[FunnelService instance] allFunnels].count > 1) {
                            FunnlPopUpView *funnlPopUpView = [[FunnlPopUpView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) withNewPopup:NO withMessageId:uidKey withMessage:nil subViewOnViewController:self];
                            funnlPopUpView.mainVCdelegate = self.mainVCdelegate;
                            [self.view addSubview:funnlPopUpView];
                        }
                        
                    }];
                }
                
                [cell setSwipeGestureWithView:fullFunnlView color:fullFunnlColor mode:MCSwipeTableViewCellModeExit state:MCSwipeTableViewCellState4 completionBlock:^(MCSwipeTableViewCell *cell, MCSwipeTableViewCellState state, MCSwipeTableViewCellMode mode) {
                    NSLog(@"Did swipe full cell, ");
                    
                    [cell swipeToOriginWithCompletion:nil];
                    MCOIMAPMessage *message = [MCOIMAPMessage importSerializable:[(MessageModel*)[EmailService instance].filterMessages[indexPath.row] messageJSON]];
                    FunnlPopUpView *funnlPopUpView = [[FunnlPopUpView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) withNewPopup:YES withMessageId:uidKey withMessage:message subViewOnViewController:self];
                    funnlPopUpView.mainVCdelegate = self.mainVCdelegate;

                    [self.view addSubview:funnlPopUpView];
                    
                }];
                
                return cell;
                break;
            }
                
            case 1:
            {
                UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:inboxInfoIdentifier];
                if (!cell)
                {
                    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:inboxInfoIdentifier];
                    cell.textLabel.font = [UIFont boldSystemFontOfSize:14];
                    cell.textLabel.textAlignment = NSTextAlignmentCenter;
                    cell.detailTextLabel.textAlignment = NSTextAlignmentCenter;
                    cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
                }
                
                if ([EmailService instance].messages.count < [EmailService instance].totalNumberOfInboxMessages)
                    cell.textLabel.text = [NSString stringWithFormat:@"Load %u more",MIN([EmailService instance].totalNumberOfInboxMessages - [EmailService instance].messages.count, NUMBER_OF_MESSAGES_TO_LOAD)];
                else
                    cell.textLabel.text = nil;
                
                if ([EmailService instance].totalNumberOfInboxMessages > 0)
                    cell.detailTextLabel.text = [NSString stringWithFormat:@"%ld message(s)",(long)[EmailService instance].totalNumberOfInboxMessages];
                cell.accessoryView = self.loadMoreActivityView;
                
                if (self.isLoading)
                    [self.loadMoreActivityView startAnimating];
                else
                {
                    [tempAppDelegate.progressHUD show:NO];
                    [self.loadMoreActivityView stopAnimating];
                }
                
                return cell;
                break;
            }
                
            default:
                return nil;
                break;
        }
    }
    else{
        EmailCell *cell = [tableView dequeueReusableCellWithIdentifier:mailCellIdentifier forIndexPath:indexPath];
        MCOIMAPMessage *message = searchMessages[indexPath.row];
        if([message.header.date isToday]){
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"HH:mm"];
            NSString *dateString = [dateFormatter stringFromDate:message.header.date];
            cell.dateLabel.text = dateString;
        }
        else
            cell.dateLabel.text = [message.header.date timeAgo];
        
        if(message.header.sender.displayName.length)
            cell.senderLabel.text = message.header.sender.displayName;
        else
            cell.senderLabel.text = message.header.sender.mailbox;
        
        cell.subjectLabel.text = message.header.subject;
        cell.threadLabel.text = @"";
        cell.messageRenderingOperation = [[EmailService instance].imapSession plainTextBodyRenderingOperationWithMessage:message folder:self.emailFolder];
        [cell.messageRenderingOperation start:^(NSString * plainTextBodyString, NSError * error) {
            cell.bodyLabel.text = plainTextBodyString;
            cell.messageRenderingOperation = nil;
        }];
        return cell;
    }
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(isSearching == NO){
        switch (indexPath.section)
        {
            case 0:
            {
                MCOIMAPMessage *msg = [MCOIMAPMessage importSerializable:[(MessageModel*)[EmailService instance].filterMessages[indexPath.row] messageJSON]];
                MsgViewController *vc = [[MsgViewController alloc] init];
                vc.folder = self.emailFolder;
                vc.message = msg;
                vc.address = msg.header.from;
                vc.session = [EmailService instance].imapSession;
                msg.flags = msg.flags | MCOMessageFlagSeen;
                MCOIMAPOperation *msgOperation=[[EmailService instance].imapSession storeFlagsOperationWithFolder:self.emailFolder uids:[MCOIndexSet indexSetWithIndex:msg.uid] kind:MCOIMAPStoreFlagsRequestKindAdd flags:MCOMessageFlagSeen];
                [msgOperation start:^(NSError * error)
                 {
                     NSLog(@"selected message flags %u UID is %u",msg.flags,msg.uid );
                 }];
                //[self.navigationController pushViewController:vc animated:YES];
                if ([(MessageModel*)[EmailService instance].filterMessages[indexPath.row] numberOfEmailInThread] > 1) {
                    EmailThreadTableViewController *threadViewController = [[EmailThreadTableViewController alloc] initWithGmailThreadID:[NSString stringWithFormat:@"%llu",msg.gmailThreadID]];
                    [self.navigationController pushViewController:threadViewController animated:YES];
                }
                else{
                    [self setReadMessage:(MessageModel*)[EmailService instance].filterMessages[indexPath.row]];
                    [self.mainVCdelegate pushViewController:vc];
                }
                break;
            }
                
            case 1:
            {
                UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
                if (!self.isLoading &&
                    [EmailService instance].messages.count < [EmailService instance].totalNumberOfInboxMessages)
                {
                    int totalNumberOfMessage = [[MessageService instance] messagesAllTopMessages].count + NUMBER_OF_MESSAGES_TO_LOAD;
                    NSLog(@"[EmailsTableViewController didSelect] %d",totalNumberOfMessage);
                    [[EmailService instance] loadLastNMessages:totalNumberOfMessage withTableController:self withFolder:INBOX];
                    cell.accessoryView = self.loadMoreActivityView;
                    [self.loadMoreActivityView startAnimating];
                }
                [tableView deselectRowAtIndexPath:indexPath animated:YES];
                break;
            }
                
            default:
                break;
        }
    }
    else{
        MCOIMAPMessage *msg = searchMessages[indexPath.row];
        MsgViewController *vc = [[MsgViewController alloc] init];
        vc.folder = self.emailFolder;
        vc.message = msg;
        vc.session = [EmailService instance].imapSession;
        //[self.navigationController pushViewController:vc animated:YES];
        [self.mainVCdelegate pushViewController:vc];
    }
    
}

#pragma mark -
#pragma mark Helper
- (CGFloat)findTheSizeOf:(NSString*)nameString
{
    UIFont *font = [UIFont systemFontOfSize:16];
    NSDictionary *userAttributes = @{NSFontAttributeName: font, NSForegroundColorAttributeName: [UIColor blackColor]};
    CGSize sizeNeeded = [nameString sizeWithAttributes:userAttributes];
    if (sizeNeeded.width < 320-105-6-60) {
        return sizeNeeded.width;
    }
    return 320-105-6-60;
}

- (BOOL)isThreadRead:(NSString*)gmailThreadID
{
    NSArray *tempArray = [[MessageService instance] retrieveAllMessagesWithSameGmailID:[gmailThreadID substringWithRange:NSMakeRange(0, gmailThreadID.length-1)]];
    if (tempArray.count > 0) {
        return NO;
    }
    return YES;
}

- (void)setReadMessage:(MessageModel*)messageRead
{
    [messageRead setRead:YES];
    [[MessageService instance] updateMessage:messageRead];
}

#pragma mark - Table View
- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    return NO;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 90;
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"Create Funnl";
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        if(indexPath.section == 0){
            MCOIMAPMessage *message = [EmailService instance].filterMessages[indexPath.row];
            MCOAddress *emailAddress = message.header.from;
            NSMutableArray *mailArray = [[NSMutableArray alloc] init];
            [mailArray addObject:emailAddress];
            [mailArray addObjectsFromArray:message.header.cc];
            
            NSMutableDictionary *sendersDictionary = [[NSMutableDictionary alloc] init];
            int count = 0;
            for (MCOAddress *address in mailArray) {
                NSString *email = [address.mailbox lowercaseString];
                [sendersDictionary setObject:email forKey:[NSIndexPath indexPathForRow:count inSection:1]];
                count ++;
            }
            
            CreateFunnlViewController *creatFunnlViewController = [[CreateFunnlViewController alloc] initTableViewWithSenders:sendersDictionary subjects:nil filterModel:nil];
            creatFunnlViewController.mainVCdelegate = self.mainVCdelegate;
            [self.mainVCdelegate pushViewController:creatFunnlViewController];
            creatFunnlViewController = nil;
            self.tableView.editing = NO;
        }
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section == 0){
        return NO;
    }
    return NO;
}

#pragma mark Helpers
- (UIView *)viewWithImageName:(NSString *)imageName {
    UIImage *image = [UIImage imageNamed:imageName];
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.frame = CGRectMake(10, 0, 40, 40);
    [imageView setImage:image];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    return imageView;
}


#pragma mark - MCSwipeTableViewCell delegates
// When the user starts swiping the cell this method is called
- (void)swipeTableViewCellDidStartSwiping:(MCSwipeTableViewCell *)cell {
    // NSLog(@"Did start swiping the cell!");
}

// When the user ends swiping the cell this method is called
- (void)swipeTableViewCellDidEndSwiping:(MCSwipeTableViewCell *)cell {
    //NSLog(@"Did end swiping the cell!");
}

// When the user is dragging, this method is called and return the dragged percentage from the border
- (void)swipeTableViewCell:(MCSwipeTableViewCell *)cell didSwipeWithPercentage:(CGFloat)percentage {
    // NSLog(@"Did swipe with percentage : %f", percentage);
}

#pragma mark - SearchBar delegates
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar;{
    searchBar.showsCancelButton = YES;
    return YES;
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar;{
    return YES;
}

- (BOOL)searchBar:(UISearchBar *)searchBar shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    return YES;
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar;{
    
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar;{
    
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar;{
    filterLabel.text = @"Search Results";
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [searchMessages removeAllObjects];
    MCOIMAPSearchOperation *searchOperation = [[EmailService instance].imapSession searchOperationWithFolder:self.emailFolder kind:MCOIMAPSearchKindFrom searchString:searchBar.text];
    [searchOperation start:^(NSError *error, MCOIndexSet *searchResult) {
        if (error)
        {
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            NSLog(@"%@",error.description);
        }
        else
        {
            NSLog(@"%d", [searchResult count]);
            filterLabel.text = [NSString stringWithFormat:@"Search Results : %d",searchResult.count];
            if (searchResult) {
                MCOIMAPMessagesRequestKind requestKind = (MCOIMAPMessagesRequestKind)
                (MCOIMAPMessagesRequestKindHeaders | MCOIMAPMessagesRequestKindStructure |
                 MCOIMAPMessagesRequestKindInternalDate | MCOIMAPMessagesRequestKindHeaderSubject |
                 MCOIMAPMessagesRequestKindFlags);
                
                MCOIMAPSession *session = [EmailService instance].imapSession;
                MCOIMAPFetchMessagesOperation * op = [session fetchMessagesByUIDOperationWithFolder:self.emailFolder requestKind:requestKind uids:searchResult];
                [op start:^(NSError * error, NSArray * messages, MCOIndexSet * vanishedMessages) {
                    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"header.date" ascending:NO];
                    searchMessages = [[NSMutableArray alloc] initWithArray:[messages sortedArrayUsingDescriptors:@[sort]]];
                    isSearching = YES;
                    [self.tableView reloadData];
                    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                }];
            }
            else{
                [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            }
        }
    }];
    [searchBar resignFirstResponder];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar;{
    filterLabel.text = self.filterModel.filterTitle;
    searchBar.text = @"";
    [searchBar resignFirstResponder];
    isSearching = NO;
    searchBar.showsCancelButton = NO;
    [self.tableView reloadData];
}

@end
