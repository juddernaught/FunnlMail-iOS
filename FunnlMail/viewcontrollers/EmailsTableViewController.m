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
#import "FunnelModel.h"
#import <MailCore/MailCore.h>
#import "EmailCell.h"
#import "MsgViewController.h"
#import "KeychainItemWrapper.h"
#import "EmailService.h"
#import "MessageFilterXRefService.h"
#import "CreateFunnlviewController.h"
#import "UIColor+HexString.h"
#import "NSDate+TimeAgo.h"
#import "FunnlPopUpView.h"
#import <Mixpanel/Mixpanel.h>

static NSString *FILTER_VIEW_CELL = @"FilterViewCell";
static NSString *mailCellIdentifier = @"MailCell";
static NSString *inboxInfoIdentifier = @"InboxStatusCell";

@interface EmailsTableViewController ()
@end

@implementation EmailsTableViewController
@synthesize tablecontroller,activityIndicator,isSearching;

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
    tempCellForDisplay = nil;
    currentIndexPath = nil;
    tempAppDelegate = APPDELEGATE;
//    [[EmailService instance] startLogin: self];
    [self setupView];
    // MUSTFIX: code doesn't work without below line, but it doesn't seem like it really belongs
    self.emailFolder = INBOX;
    searchMessages = [[NSMutableArray alloc] init];
    isSearching = NO;
    self.ClearTable = 0;
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
    // This is the green or purple All bar
    
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
    filterLabel.text = (self.filterModel!=nil ? self.filterModel.filterTitle : ALL_FUNNL);
    filterLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:filterLabel];
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    
//    refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Pull to Refresh"];
    [refreshControl addTarget:self action:@selector(fetchLatestEmail) forControlEvents:UIControlEventValueChanged];
    tablecontroller = [[UITableViewController alloc] init];
    
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
        
	[self.tableView registerClass:[EmailCell class] forCellReuseIdentifier:mailCellIdentifier];
    
	self.loadMoreActivityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    mailSearchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 40)];
    mailSearchBar.delegate = self;
    mailSearchBar.placeholder = @"Search";
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
//    [tempAppDelegate.progressHUD show:YES];=
//    [tempAppDelegate.progressHUD setHidden:NO];
    [activityIndicator startAnimating];
    [[EmailService instance] loadLatestMail:10 withTableController:self withFolder:INBOX];
}

-(void) setFilterModel:(FunnelModel *)filterModel{
    _filterModel = filterModel;
    if(self.emailFolder == nil || self.emailFolder.length <= 0){
        self.emailFolder = INBOX;
    }
    
    if(filterLabel!=nil){
        filterLabel.backgroundColor = (self.filterModel!=nil ? self.filterModel.barColor : [UIColor colorWithHexString:@"#2EB82E"]);
        filterLabel.text = (self.filterModel!=nil ? self.filterModel.filterTitle : ALL_FUNNL);
        NSLog(@"Call to loadLastNMessages from setFilterModel function");
        [[EmailService instance] loadLastNMessages:NUMBER_OF_MESSAGES_TO_LOAD withTableController:self withFolder:self.emailFolder  withFetchRange:MCORangeEmpty];
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
    if ([[tempAppDelegate.currentFunnelString lowercaseString] isEqualToString:[ALL_FUNNL lowercaseString]]) {
        return 2;
    }
    if (isSearching) {
        return 2;
    }
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(self.ClearTable) {
        NSLog(@"clear table == %d",self.ClearTable);
        return 0;
    }
	if(isSearching == NO){
        if (section == 1)
        {
            if ([EmailService instance].totalNumberOfMessages >= 0 || [EmailService instance].filterMessages.count > 0)
                return 1;
            return 0;
        }
        return [EmailService instance].filterMessages.count;
    }
    else{
        if (section == 1) {
            return 1;
        }
        return searchMessages.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(isSearching == NO){
        switch (indexPath.section){
            case 0:{
                EmailCell *cell = [tableView dequeueReusableCellWithIdentifier:mailCellIdentifier forIndexPath:indexPath];
                if (tempCellForDisplay.tag == indexPath.row) {
                    tempCellForDisplay = nil;
                }
//                else
//                    [cell resetToOriginalState];
                cell.funnlLabel1.text = @"";
                cell.funnlLabel2.text = @"";
                cell.funnlLabel3.text = @"";

                NSMutableDictionary *funnlLabelDictionary= [self getFunnlsDictionary:(MessageModel*)[EmailService instance].filterMessages[indexPath.row]];
                int funnlLabelCount = 0;
                for (NSString *key in funnlLabelDictionary.allKeys) {
                    if(funnlLabelCount == 0){
                        cell.funnlLabel1.text = key;
                        cell.funnlLabel1.textColor = [UIColor colorWithHexString:[funnlLabelDictionary objectForKey:key]];
                    }
                    else if(funnlLabelCount == 1){
                        cell.funnlLabel2.text = key;
                        if(funnlLabelDictionary.allKeys.count > 1){
                            cell.funnlLabel2.text = [NSString stringWithFormat:@"%@ + %d ",key,funnlLabelDictionary.allKeys.count-1];
                            cell.funnlLabel2.textColor = [UIColor colorWithHexString:[funnlLabelDictionary objectForKey:key]];
                        }
                    }
                    
                    funnlLabelCount++;
                }
                
                //[cell.labelNameText setAttributedText:[self returnFunnelString:(MessageModel*)[EmailService instance].filterMessages[indexPath.row]]];
                cell.tag = indexPath.row;
                cell.delegate = self;
                MCOIMAPMessage *message = [MCOIMAPMessage importSerializable:[(MessageModel*)[EmailService instance].filterMessages[indexPath.row] messageJSON]];
                if ([(MessageModel*)[EmailService instance].filterMessages[indexPath.row] numberOfEmailInThread] > 1) {
                    if ([self isThreadRead:[NSString stringWithFormat:@"%llul",message.gmailThreadID]]) {
                        cell.readLabel.backgroundColor = [UIColor clearColor];
                        cell.readLabel.hidden = YES;
                    }
                    else {
                        cell.readLabel.hidden = NO;
                        cell.readLabel.backgroundColor = [UIColor colorWithHexString:@"#007AFF"];
                    }
                }
                else{
                    if([(MessageModel*)[EmailService instance].filterMessages[indexPath.row] read]) {
                        cell.readLabel.backgroundColor = [UIColor clearColor];
                        cell.readLabel.hidden = YES;
                    }
                    else {
                        cell.readLabel.hidden = NO;
                        cell.readLabel.backgroundColor = [UIColor colorWithHexString:@"#007AFF"];
                    }
                }
                
                NSTimeInterval interval = [message.header.date timeIntervalSinceNow];
                interval = -interval;
                if (interval <= 24*60*60) {
                    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                    [dateFormatter setDateFormat:@"h:mm a"]; //Changed by Chad
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
                if(message.header.sender.displayName.length){
                    cell.senderLabel.text = [self removeAngularBracket:message.header.sender.displayName];
                }
                else {
                    cell.senderLabel.text = [self removeAngularBracket:message.header.sender.mailbox];
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
                    [cell.detailDiscloser setHidden:NO];
                }
                
                
                NSString *uidKey = [NSString stringWithFormat:@"%d", message.uid];
                NSString *cachedPreview = [[MessageService instance] retrievePreviewContentWithID:uidKey];
                if (cachedPreview == nil || cachedPreview.length == 0 )
                    cachedPreview = @"";

                if (![cachedPreview isEqualToString:@""])
                {
                    cell.bodyLabel.text = cachedPreview;
                }
                else{
                    cell.messageRenderingOperation = [[EmailService instance].imapSession plainTextBodyRenderingOperationWithMessage:message folder:self.emailFolder];
                    [cell.messageRenderingOperation start:^(NSString * plainTextBodyString, NSError * error) {
                        if (plainTextBodyString) {
                            if (plainTextBodyString.length > 0) {
                         
                                if ([[plainTextBodyString substringWithRange:NSMakeRange(0, 1)] isEqualToString:@" "]) {
                                    plainTextBodyString= [plainTextBodyString substringWithRange:NSMakeRange(1, plainTextBodyString.length - 1)];
                                }

                                if(plainTextBodyString.length > 150){
                                    NSRange stringRange = {0,150};
                                    plainTextBodyString = [plainTextBodyString substringWithRange:stringRange];
                                }
                                
                                NSMutableDictionary *paramDict = [[NSMutableDictionary alloc] init];
                                paramDict[uidKey] = [self removeStartingSpaceFromString:plainTextBodyString];
                                [[MessageService instance] updateMessageWithDictionary:paramDict];
                                cell.bodyLabel.text = plainTextBodyString;
                            }
                        }
                        cell.messageRenderingOperation = nil;
                    }];
                }
                
//                cell.delegate = self;
//                cell.tableView = tableView;
//                cell.revealDirection = RDSwipeableTableViewCellRevealDirectionRight | RDSwipeableTableViewCellRevealDirectionLeft;
                
                UIView *archiveView = [self viewWithImageName:@"swipeArchive"];
                UIColor *yellowColor = [UIColor colorWithHexString:@"#F8CB0A"];
                
                UIView *fullFunnlView = [self viewWithImageName:@"swipeFunnl"];
                UIColor *fullFunnlColor = [UIColor colorWithHexString:@"#92F190"];
                
                
                [cell setSwipeGestureWithView:archiveView color:yellowColor mode:MCSwipeTableViewCellModeExit state:MCSwipeTableViewCellState1 completionBlock:^(MCSwipeTableViewCell *cell, MCSwipeTableViewCellState state, MCSwipeTableViewCellMode mode) {
                    [[Mixpanel sharedInstance] track:@"Email Archived"];
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
                
                [cell setSwipeGestureWithView:fullFunnlView color:fullFunnlColor mode:MCSwipeTableViewCellModeExit state:MCSwipeTableViewCellState3 completionBlock:^(MCSwipeTableViewCell *cell, MCSwipeTableViewCellState state, MCSwipeTableViewCellMode mode) {
                    NSLog(@"Did swipe full cell, ");
                    [[Mixpanel sharedInstance] track:@"Add email to Funnl"];
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
                
                if ([EmailService instance].messages.count < [EmailService instance].totalNumberOfMessages)
                    cell.textLabel.text = [NSString stringWithFormat:@"Load %lu more",MIN([EmailService instance].totalNumberOfMessages - [EmailService instance].messages.count, NUMBER_OF_MESSAGES_TO_LOAD)];
                else
                    cell.textLabel.text = nil;
                
                if ([EmailService instance].totalNumberOfMessages > 0)
                    cell.detailTextLabel.text = [NSString stringWithFormat:@"%ld message(s)",(long)[EmailService instance].totalNumberOfMessages];
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
        switch (indexPath.section){
            case 0:{
                EmailCell *cell = [tableView dequeueReusableCellWithIdentifier:mailCellIdentifier forIndexPath:indexPath];
                MCOIMAPMessage *message = [MCOIMAPMessage importSerializable:[(MessageModel*)searchMessages[indexPath.row] messageJSON]];
                NSString *uidKey = [NSString stringWithFormat:@"%d", message.uid];
                if([message.header.date isToday]){
                    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                    [dateFormatter setDateFormat:@"h:mm"]; // Changed by Chad
                    NSString *dateString = [dateFormatter stringFromDate:message.header.date];
                    cell.dateLabel.text = dateString;
                }
                else
                    cell.dateLabel.text = [message.header.date timeAgo];
                
                if ([(MessageModel*)searchMessages[indexPath.row] numberOfEmailInThread] > 1) {
                    if ([self isThreadRead:[NSString stringWithFormat:@"%llul",message.gmailThreadID]]) {
                        cell.readLabel.backgroundColor = [UIColor clearColor];
                        cell.readLabel.hidden = YES;
                    }
                    else {
                        cell.readLabel.hidden = NO;
                        cell.readLabel.backgroundColor = [UIColor colorWithHexString:@"#007AFF"];
                    }
                }
                else{
                    if([(MessageModel*)searchMessages[indexPath.row] read]) {
                        cell.readLabel.backgroundColor = [UIColor clearColor];
                        cell.readLabel.hidden = YES;
                    }
                    else {
                        cell.readLabel.hidden = NO;
                        cell.readLabel.backgroundColor = [UIColor colorWithHexString:@"#007AFF"];
                    }
                }
                
                if([(MessageModel*)searchMessages[indexPath.row] numberOfEmailInThread] > 1){
                    cell.threadLabel.text = [NSString stringWithFormat:@"%d",[(MessageModel*)[EmailService instance].filterMessages[indexPath.row] numberOfEmailInThread]];
                    [cell.threadLabel setHidden:NO];
                    [cell.detailDiscloser setHidden:NO];
                }
                else{
                    cell.threadLabel.text = @"";
                    [cell.threadLabel setHidden:YES];
                    [cell.detailDiscloser setHidden:NO];
                }
                
                if(message.header.sender.displayName.length){
                    if([self.navigationItem.title isEqualToString:@"Sent"]) cell.senderLabel.text = message.header.from.displayName;
                    else cell.senderLabel.text = message.header.sender.displayName;
                }
                else{
                    if([self.navigationItem.title isEqualToString:@"Sent"]){
                        if(message.header.to.count){
                            MCOAddress *temp = message.header.to.firstObject;
                            cell.senderLabel.text = temp.mailbox;
                        }
                        else cell.senderLabel.text = @"Error retrieving recipients";
                    }
                    else cell.senderLabel.text = message.header.sender.mailbox;
                }
                cell.subjectLabel.text = message.header.subject;
                cell.threadLabel.text = @"";
                
                NSString *cachedPreview = [[MessageService instance] retrievePreviewContentWithID:uidKey];
                if (cachedPreview == nil || cachedPreview.length == 0 )
                    cachedPreview = @"";
                
                if (![cachedPreview isEqualToString:@""])
                {
                    cell.bodyLabel.text = cachedPreview;
                }
                else{
                    cell.messageRenderingOperation = [[EmailService instance].imapSession plainTextBodyRenderingOperationWithMessage:message folder:self.emailFolder];
                    [cell.messageRenderingOperation start:^(NSString * plainTextBodyString, NSError * error) {
                        if (plainTextBodyString) {
                            if (plainTextBodyString.length > 0) {
                                
                                if ([[plainTextBodyString substringWithRange:NSMakeRange(0, 1)] isEqualToString:@" "]) {
                                    plainTextBodyString= [plainTextBodyString substringWithRange:NSMakeRange(1, plainTextBodyString.length - 1)];
                                }
                                
                                if(plainTextBodyString.length > 150){
                                    NSRange stringRange = {0,150};
                                    plainTextBodyString = [plainTextBodyString substringWithRange:stringRange];
                                }
                                NSMutableDictionary *paramDict = [[NSMutableDictionary alloc] init];
                                paramDict[uidKey] = [self removeStartingSpaceFromString:plainTextBodyString];
                                [[MessageService instance] updateMessageWithDictionary:paramDict];
                                cell.bodyLabel.text = plainTextBodyString;
                            }
                        }
                        cell.messageRenderingOperation = nil;
                    }];
                }

                UIView *archiveView = [self viewWithImageName:@"swipeArchive"];
                UIColor *yellowColor = [UIColor colorWithHexString:@"#D8D8D8"];
                
                UIView *fullFunnlView = [self viewWithImageName:@"swipeFunnl"];
                UIColor *fullFunnlColor = [UIColor colorWithHexString:@"#D8D8D8"];
                
                
                [cell setSwipeGestureWithView:archiveView color:yellowColor mode:MCSwipeTableViewCellModeExit state:MCSwipeTableViewCellState1 completionBlock:^(MCSwipeTableViewCell *cell, MCSwipeTableViewCellState state, MCSwipeTableViewCellMode mode) {
                    [[Mixpanel sharedInstance] track:@"Email Archived"];
                    NSLog(@"Did swipe \"Archive\" cell");
                    MCOIMAPOperation *msgOperation = [[EmailService instance].imapSession storeFlagsOperationWithFolder:self.emailFolder uids:[MCOIndexSet indexSetWithIndex:message.uid] kind:MCOIMAPStoreFlagsRequestKindAdd flags:MCOMessageFlagDeleted];
                    [msgOperation start:^(NSError * error)
                     {
                         [tableView beginUpdates];
//                         [[EmailService instance].filterMessagePreviews removeObjectForKey:uidKey];
                         [searchMessages removeObjectAtIndex:indexPath.row];
                         [searchMessages removeObjectIdenticalTo:message];
                         [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationLeft];
                         [tableView endUpdates];
                         NSLog(@"selected message flags %u UID is %u",message.flags,message.uid );
                     }];
                    [cell swipeToOriginWithCompletion:nil];
                }];
                
                
                [cell setSwipeGestureWithView:fullFunnlView color:fullFunnlColor mode:MCSwipeTableViewCellModeExit state:MCSwipeTableViewCellState3 completionBlock:^(MCSwipeTableViewCell *cell, MCSwipeTableViewCellState state, MCSwipeTableViewCellMode mode) {
                    NSLog(@"Did swipe full cell, -----");
                    [[Mixpanel sharedInstance] track:@"Add email to Funnl"];
                    [cell swipeToOriginWithCompletion:nil];
                    MCOIMAPMessage *message = [MCOIMAPMessage importSerializable:[(MessageModel*)searchMessages[indexPath.row] messageJSON]];
                    FunnlPopUpView *funnlPopUpView = [[FunnlPopUpView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) withNewPopup:YES withMessageId:uidKey withMessage:message subViewOnViewController:self];
                    funnlPopUpView.mainVCdelegate = self.mainVCdelegate;
                    
                    [self.view addSubview:funnlPopUpView];
                    
                }];

                return cell;
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
                
                if(self.filterModel == nil || [self.filterModel.funnelId isEqualToString:@"0"]){

                    if ([EmailService instance].messages.count < [EmailService instance].totalNumberOfMessages)
//                        cell.textLabel.text = [NSString stringWithFormat:@"Load %lu more",MIN([EmailService instance].totalNumberOfMessages - [EmailService instance].messages.count, NUMBER_OF_MESSAGES_TO_LOAD_ON_SEARCH)];
                        cell.textLabel.text = @"Load more results";
                    else
                        cell.textLabel.text = nil;

                }
                
                //                if ([EmailService instance].totalNumberOfInboxMessages > 0)
                //                    cell.detailTextLabel.text = [NSString stringWithFormat:@"%ld message(s)",(long)[EmailService instance].totalNumberOfInboxMessages];
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
}

#pragma mark -
#pragma mark RDSwipeableTableViewCellDelgate
- (void)tableView:(UITableView *)tableView willBeginCellSwipe:(RDSwipeableTableViewCell *)cell inDirection:(RDSwipeableTableViewCellRevealDirection)direction
{
    if (tempCellForDisplay && cell != tempCellForDisplay) {
        [tempCellForDisplay resetToOriginalState];
    }
    tempCellForDisplay = cell;
    if(direction == RDSwipeableTableViewCellRevealDirectionRight){
        
        if ([[FunnelService instance] allFunnels].count > 1) {
            CGRect cellRect = cell.frame;
            
            UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.tag = cell.tag;

            button.frame = CGRectMake(cellRect.size.width - 80, 0, 80, cellRect.size.height);
            [button setImage:[UIImage imageNamed:@"moveToFunnlIcon.png"] forState:UIControlStateNormal];
            button.backgroundColor = [UIColor colorWithHexString:@"#4487E9"];
            [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [button addTarget:self action:@selector(halfSwipe:) forControlEvents:UIControlEventTouchUpInside];
            [cell.revealView addSubview:button];
            button = nil;
            
            UIButton *button1 = [UIButton buttonWithType:UIButtonTypeCustom];
            button1.tag = cell.tag;
            button1.frame = CGRectMake(cellRect.size.width - 160, 0, 80, cellRect.size.height);
            button1.backgroundColor = [UIColor colorWithHexString:@"#43F377"];
            [button1 setImage:[UIImage imageNamed:@"swipeFunnl"] forState:UIControlStateNormal];
            [button1 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [button1 addTarget:self action:@selector(fullSwipe:) forControlEvents:UIControlEventTouchUpInside];
            [cell.revealView addSubview:button1];
            button1 = nil;
            
            cell.revealDistance = 160;
        }
        else {
            CGRect cellRect = cell.frame;
            UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.tag = cell.tag;
            button.frame = CGRectMake(cellRect.size.width - 80, 0, 80, cellRect.size.height);
            [button setImage:[UIImage imageNamed:@"swipeFunnl"] forState:UIControlStateNormal];
            button.backgroundColor = [UIColor colorWithHexString:@"#43F377"];
            [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [button addTarget:self action:@selector(fullSwipe:) forControlEvents:UIControlEventTouchUpInside];
            [cell.revealView addSubview:button];
            button = nil;
            cell.revealDistance = 80;
        }
    }
    else{
        CGRect cellRect = cell.frame;
        UIButton * button;
        button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.tag = cell.tag;
        button.frame = CGRectMake(0, 0, 80, cellRect.size.height);
        button.backgroundColor = [UIColor colorWithHexString:@"#F9CA47"];
        [button setImage:[UIImage imageNamed:@"swipeArchive"] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(leftSwip:) forControlEvents:UIControlEventTouchUpInside];
        [cell.revealView addSubview:button];
        
        cell.revealDistance = 80;
        NSLog(@"%f,%f",cell.frame.origin.x,cell.frame.origin.y);
    }
}

- (void)leftSwip:(UIButton*)sender {
    NSLog(@"in [leftSwip]");
    [[Mixpanel sharedInstance] track:@"left swipe: Archive"];
    MCOIMAPMessage *message = [MCOIMAPMessage importSerializable:[(MessageModel*)[EmailService instance].filterMessages[sender.tag] messageJSON]];
    
    [_tableView beginUpdates];
    [[EmailService instance].filterMessagePreviews removeObjectForKey:[NSString stringWithFormat:@"%d",message.uid]];
    [[EmailService instance].filterMessages removeObjectAtIndex:sender.tag];
    [[EmailService instance].messages removeObjectIdenticalTo:message];
    [_tableView deleteRowsAtIndexPaths:[NSArray arrayWithObjects:[NSIndexPath indexPathForItem:sender.tag inSection:0], nil] withRowAnimation:UITableViewRowAnimationLeft];
    [_tableView endUpdates];
    [_tableView reloadData];
    NSLog(@"selected message flags %u UID is %u",message.flags,message.uid );
}

- (void)fullSwipe:(UIButton*)sender {
    [_tableView reloadData];
    NSLog(@"in [fullSwipe]");
    [[Mixpanel sharedInstance] track:@"fullSwipe: add to funnl pressed"];
    MCOIMAPMessage *message = [MCOIMAPMessage importSerializable:[(MessageModel*)[EmailService instance].filterMessages[sender.tag] messageJSON]];
    FunnlPopUpView *funnlPopUpView = [[FunnlPopUpView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) withNewPopup:YES withMessageId:[NSString stringWithFormat:@"%d",message.uid] withMessage:message subViewOnViewController:self];
    funnlPopUpView.mainVCdelegate = self.mainVCdelegate;
    [self.view addSubview:funnlPopUpView];
}

- (void)halfSwipe:(UIButton*)sender {
    [_tableView reloadData];
    NSLog(@"in [halfSwipe]");
    [[Mixpanel sharedInstance] track:@"halfSwipe"];
    MCOIMAPMessage *message = [MCOIMAPMessage importSerializable:[(MessageModel*)[EmailService instance].filterMessages[sender.tag] messageJSON]];
    if ([[FunnelService instance] allFunnels].count > 1) {
        FunnlPopUpView *funnlPopUpView = [[FunnlPopUpView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) withNewPopup:NO withMessageId:[NSString stringWithFormat:@"%d",message.uid] withMessage:nil subViewOnViewController:self];
        funnlPopUpView.mainVCdelegate = self.mainVCdelegate;
        [self.view addSubview:funnlPopUpView];
    }
}

- (void)tableView:(UITableView *)tableView didCellReset:(RDSwipeableTableViewCell *)cell
{
    [cell.revealView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
}


#pragma mark -
#pragma mark didPressDelete
- (void)didPressMore:(UIButton*)sender {
    [[Mixpanel sharedInstance] track:@"User Loaded more emails"];
    MCOIMAPMessage *message = nil;
    int row = 0;
    if (sender.tag < 100000) {
        row = 0;
        message = [MCOIMAPMessage importSerializable:[(MessageModel*)[EmailService instance].filterMessages[0] messageJSON]];
    }
    else {
        int index = (int)sender.tag / 100000;
        row = index;
        message = [MCOIMAPMessage importSerializable:[(MessageModel*)[EmailService instance].filterMessages[index] messageJSON]];
    }
    int buttonClicked = sender.tag % 100000;
    if (buttonClicked == 1) {
        if ([[FunnelService instance] allFunnels].count > 1) {
            FunnlPopUpView *funnlPopUpView = [[FunnlPopUpView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) withNewPopup:NO withMessageId:[NSString stringWithFormat:@"%d",message.uid] withMessage:nil subViewOnViewController:self];
            funnlPopUpView.mainVCdelegate = self.mainVCdelegate;
            [self.view addSubview:funnlPopUpView];
        }
    }
    else if (sender.tag == 2) {
        FunnlPopUpView *funnlPopUpView = [[FunnlPopUpView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) withNewPopup:YES withMessageId:[NSString stringWithFormat:@"%d",message.uid] withMessage:message subViewOnViewController:self];
        funnlPopUpView.mainVCdelegate = self.mainVCdelegate;
        [self.view addSubview:funnlPopUpView];
    }
    else if (sender.tag == 3) {
        [_tableView beginUpdates];
        [[EmailService instance].filterMessagePreviews removeObjectForKey:[NSString stringWithFormat:@"%d",message.uid]];
        [[EmailService instance].filterMessages removeObjectAtIndex:row];
        [[EmailService instance].messages removeObjectIdenticalTo:message];
        [_tableView deleteRowsAtIndexPaths:[NSArray arrayWithObjects:[NSIndexPath indexPathForItem:row inSection:0], nil] withRowAnimation:UITableViewRowAnimationLeft];
        [_tableView endUpdates];
        NSLog(@"selected message flags %u UID is %u",message.flags,message.uid );
    }
}

- (NSString *)removeStartingSpaceFromString:(NSString*)sourceString {
    if (sourceString.length > 1) {
        if ([[sourceString substringWithRange:NSMakeRange(0, 1)] isEqualToString:@" "]) {
            return [sourceString substringWithRange:NSMakeRange(1, sourceString.length -1)];
        }
        return sourceString;
    }
    else
        return sourceString;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(isSearching == NO){
        switch (indexPath.section)
        {
            case 0:
            {
                [[Mixpanel sharedInstance] track:@"User Viewed Email"];
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
                if (!self.isLoading && [EmailService instance].messages.count < [EmailService instance].totalNumberOfMessages)
                {
                    int totalNumberOfMessage = (int)[[MessageService instance] messagesAllTopMessages].count + NUMBER_OF_MESSAGES_TO_LOAD;
//                    NSLog(@"[EmailsTableViewController didSelect] %d",totalNumberOfMessage);
                    NSLog(@"Call to loadLastNMessages from  didSelectRowAtIndexPath   function & isSearching = NO");
                    [[EmailService instance] loadLastNMessages:NUMBER_OF_MESSAGES_TO_LOAD withTableController:self withFolder:INBOX  withFetchRange:MCORangeEmpty];
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
        if (indexPath.section == 1) {
            if(self.filterModel == nil || [self.filterModel.funnelId isEqualToString:@"0"]){
                [self searchOnlineWithString:mailSearchBar.text];
            }
            else{
                
            }
        }
        else {
            [[Mixpanel sharedInstance] track:@"User viewed email"];
            MCOIMAPMessage *msg = [MCOIMAPMessage importSerializable:[(MessageModel*)searchMessages[indexPath.row] messageJSON]];
            MsgViewController *vc = [[MsgViewController alloc] init];
            vc.folder = self.emailFolder;
            vc.message = msg;
            vc.session = [EmailService instance].imapSession;
            //[self.navigationController pushViewController:vc animated:YES];
            [self setReadMessage:(MessageModel*)searchMessages[indexPath.row]];
            [self.mainVCdelegate pushViewController:vc];
        }
    }
    
}

#pragma mark -
#pragma mark Helper

- (NSMutableDictionary*)getFunnlsDictionary:(MessageModel*)message {
    NSString *funnelJsonString = [message funnelJson];
    NSError *error = nil;
    if (funnelJsonString) {
        NSData *data = [funnelJsonString dataUsingEncoding:NSUTF8StringEncoding];
        NSMutableDictionary *tempDict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        if(tempDict != nil)
            return tempDict;
        
    }
    return nil;
}

- (NSMutableAttributedString*)returnFunnelString:(MessageModel*)message {
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] init];
    NSString *funnelJsonString = [message funnelJson];
    NSError *error = nil;
    if (funnelJsonString) {
        NSData *data = [funnelJsonString dataUsingEncoding:NSUTF8StringEncoding];
        NSMutableDictionary *tempDict = [NSJSONSerialization JSONObjectWithData:data
                                                                        options:kNilOptions
                                                                          error:&error];
        NSArray *keysArray = tempDict.allKeys;
        NSArray *valueArray = tempDict.allValues;
        for (int cnt = 0; cnt < keysArray.count; cnt++) {
            UIColor * color = [UIColor colorWithHexString:[valueArray objectAtIndex:cnt]];
            NSDictionary * attributes = [NSDictionary dictionaryWithObject:color forKey:NSForegroundColorAttributeName];
            NSAttributedString * subString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"  %@",[keysArray objectAtIndex:cnt]] attributes:attributes];
            [attributedString appendAttributedString:subString];
            subString = nil;
        }
    }
    return attributedString;
}

- (NSString*)removeAngularBracket:(NSString*)emailString {
    if (emailString.length > 0) {
        if ([[emailString substringWithRange:NSMakeRange(0, 1)] isEqualToString:@"<"]) {
            emailString = [emailString substringWithRange:NSMakeRange(1, emailString.length - 1)];
            if ([[emailString substringWithRange:NSMakeRange(emailString.length - 1, 1)] isEqualToString:@">"]) {
                emailString = [emailString substringWithRange:NSMakeRange(0, emailString.length - 1)];
            }
        }
    }
    return emailString;
}

- (void)resetSearchBar {
    mailSearchBar.text = @"";
}

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
    messageRead.read = TRUE;
    [[MessageService instance] updateMessage:messageRead];
}

#pragma mark - Table View
- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    return NO;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 98;
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
    if ([imageName isEqualToString:@"swipeArchive"]) {
        imageView.frame = CGRectMake(-40, 0, 80, 80);
    }
    else
        imageView.frame = CGRectMake(30, 0, 80, 80);
    [imageView setImage:image];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    [imageView setBackgroundColor:[UIColor clearColor]];
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

#pragma mark SearchFunction
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
    NSString *searchText = searchBar.text;
    isSearching = YES;
    if(self.filterModel == nil || [self.filterModel.funnelId isEqualToString:@"0"]){
        //All mailbox
        [self searchInMemory:searchText];
    }
    else{
        //Other funnsl
        [self searchInDatabaseWithSearchText:searchText withFunnelId:self.filterModel.funnelId];
    }

}

- (void)searchInDatabaseWithSearchText:(NSString*)searchText withFunnelId:(NSString*)funnelId{
    [searchMessages removeAllObjects];
    NSArray *tempArray = [[MessageService instance] messagesWithFunnelId:funnelId withSearchTerm:searchText];
    searchMessages = [NSMutableArray arrayWithArray:tempArray];
    [_tableView reloadData];
}


//search online
- (void)searchOnlineWithString:(NSString*)searchText {
    filterLabel.text = @"Search Results";
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
//    [searchMessages removeAllObjects];
    MCOIMAPSearchOperation *searchOperation = [[EmailService instance].imapSession searchOperationWithFolder:self.emailFolder kind:MCOIMAPSearchKindFrom searchString:searchText];
    [searchOperation start:^(NSError *error, MCOIndexSet *searchResult) {
        if (error)
        {
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
//            NSLog(@"%@",error.description);
        }
        else
        {
//            filterLabel.text = [NSString stringWithFormat:@"Search Results : %d",searchResult.count];
            if (searchResult) {
                MCOIMAPMessagesRequestKind requestKind = (MCOIMAPMessagesRequestKind)
                (MCOIMAPMessagesRequestKindHeaders | MCOIMAPMessagesRequestKindStructure |
                 MCOIMAPMessagesRequestKindInternalDate | MCOIMAPMessagesRequestKindHeaderSubject | MCOIMAPMessagesRequestKindGmailThreadID | MCOIMAPMessagesRequestKindGmailMessageID |	 MCOIMAPMessagesRequestKindFlags);
                for (MessageModel *tempMessageMOdel in searchMessages) {
                    [searchResult removeIndex:tempMessageMOdel.messageID.integerValue];
                }
                MCOIMAPSession *session = [EmailService instance].imapSession;
                MCOIMAPFetchMessagesOperation * op = [session fetchMessagesByUIDOperationWithFolder:self.emailFolder requestKind:requestKind uids:searchResult];
                [op start:^(NSError * error, NSArray * messages, MCOIndexSet * vanishedMessages) {
//                    [searchMessages removeAllObjects];
                    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"header.date" ascending:NO];
                    messages = [[NSMutableArray alloc] initWithArray:[messages sortedArrayUsingDescriptors:@[sort]]];
                    int counter = 0;
                    for (MCOIMAPMessage *m in messages) {
                        if (counter >= NUMBER_OF_MESSAGES_TO_LOAD_ON_SEARCH) {
                            break;
                        }
                        else
                            counter++;
                       
                        MessageModel *tempMessageModel = [[MessageModel alloc] init];
                        tempMessageModel.read = m.flags;
                        tempMessageModel.date = m.header.date;
                        tempMessageModel.messageID = [NSString stringWithFormat:@"%d",m.uid];
                        tempMessageModel.gmailThreadID = [NSString stringWithFormat:@"%llu",m.gmailThreadID];
                        tempMessageModel.messageJSON = [m serializable];
                        tempMessageModel.skipFlag = 0;
                        [[MessageService instance] insertMessage:tempMessageModel];
                        [searchMessages addObject:tempMessageModel];
                        tempMessageModel = nil;
                    }
                    //[[MessageService instance] insertBulkMessages:searchMessages];

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
}

//offline search
- (void)searchInMemory:(NSString*)searchText {
    [searchMessages removeAllObjects];
    NSArray *tempArray = [[MessageService instance] messagesAllTopMessages];
    for (int counter = 0; counter < [tempArray count] ; counter++) {
        MessageModel *tempModel = [tempArray objectAtIndex:counter];
        if ([self searchForString:searchText inMessage:tempModel]) {
            [searchMessages addObject:tempModel];
        }
    }
    [_tableView reloadData];
}

- (BOOL)searchForString:(NSString*)searchText inMessage:(MessageModel*)tempMessageModel {
    //    int numberOfOccurence = [tempMessageModel.messageBodyToBeRendered containsSubstring:searchText];
    if ([tempMessageModel.messageJSON.lowercaseString rangeOfString:searchText.lowercaseString].location == NSNotFound) {
        
    }
    else {
        return TRUE;
    }
    return FALSE;
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
