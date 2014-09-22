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
#import "RNBlurModalView.h"
#import "UIView+Toast.h"
#import "MTStatusBarOverlay.h"
#import "MCTMsgViewController.h"
#import "LoginViewController.h"
#import "FMCreateFunnlViewController.h"

@implementation UILabel (Additions)

- (void)sizeToFitWithAlignmentRight {
    CGRect beforeFrame = self.frame;
    [self sizeToFit];
    CGRect afterFrame = self.frame;
    self.frame = CGRectMake(beforeFrame.origin.x + beforeFrame.size.width - afterFrame.size.width-3, self.frame.origin.y, self.frame.size.width, self.frame.size.height);
}

@end

static NSString *FILTER_VIEW_CELL = @"FilterViewCell";
static NSString *mailCellIdentifier = @"MailCell";
static NSString *inboxInfoIdentifier = @"InboxStatusCell";

@interface EmailsTableViewController ()
@end

@implementation EmailsTableViewController
@synthesize tablecontroller,activityIndicator,isSearching,helpFlag,helpButton,displayStirng,disclosureArrow;
UIView *greyView;

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

- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
        [self setupView];
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    tempCellForDisplay = nil;
    currentIndexPath = nil;
    tempAppDelegate = APPDELEGATE;
    [self setupView];
    // MUSTFIX: code doesn't work without below line, but it doesn't seem like it really belongs
    self.emailFolder = INBOX;
    searchMessages = [[NSMutableArray alloc] init];
    isSearching = NO;
    self.ClearTable = 0;
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    greyView = [[UIView alloc] initWithFrame:CGRectMake(0, 144, self.view.bounds.size.width, self.view.bounds.size.height)];
    greyView.hidden = YES;
    [greyView setBackgroundColor:[UIColor colorWithWhite:0.0 alpha:0.78]];
    [self.view addSubview:greyView];
    [self.view bringSubviewToFront:greyView];
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
  
}



- (void)viewWillAppear:(BOOL)animated
{
    headerViewFlag = FALSE;
    self.tableView.tableHeaderView = [self headerView];
    NSLog(@"how often does this happen");
    NSLog(@"what is emailFolder: %@",self.emailFolder);
    if ([EmailService instance].filterMessages.count > 0) {
        [self.tableView reloadData];
    }
    funnlArray = [[FunnelService instance] allFunnels];
    tempAppDelegate.mainVCdelegate = self.mainVCdelegate;
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [_tableView reloadData];
    //newly added for VIP funnl
    if (IS_VIP_ENABLED) {
        [tempAppDelegate performSelector:@selector(loadVIPFunnelViewController) withObject:nil afterDelay:kVIP_FUNNEL_POP_UP_DISPLY_INTERVAL];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Toast
- (void)undoButtonPressed:(UIButton*)sender {
//    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(deleteMessageAfterOperation:) object:nil];
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    if (sender.tag == 1) {
        
    }
    
    else if (sender.tag == 2) {
        
    }
    [self.tableView beginUpdates];
    [[EmailService instance].filterMessages insertObject:selectedMessageModel atIndex:selectedIndexPath.row];
    [[EmailService instance].messages addObject:selectedMessageModel];
    [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:selectedIndexPath] withRowAnimation:UITableViewRowAnimationLeft];
    [self.tableView endUpdates];
    [returnView setHidden:YES];
}

- (UIView*)tostViewForOperation:(int)operation {
    
    returnView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, 50)];
    returnView.clipsToBounds = YES;
    returnView.layer.cornerRadius = 2;
    [returnView setBackgroundColor:[UIColor colorWithWhite:COLOR_OF_WHITE alpha:ALPHA_FOR_TOST]];
    
    UILabel *sampleLable = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 250 - 10, 50)];
    [sampleLable setTextAlignment:NSTextAlignmentLeft];
    [sampleLable setFont:[UIFont systemFontOfSize:14]];
    [sampleLable setTextColor:[UIColor whiteColor]];
    [sampleLable setBackgroundColor:[UIColor clearColor]];
    if(operation == 1)
        sampleLable.text = ARCHIVE_TEXT;
    else if(operation == 2)
        sampleLable.text = DELETE_TEXT;
        
    [returnView addSubview:sampleLable];
    sampleLable = nil;
    
    UIView *seperatorView = [[UIView alloc] initWithFrame:CGRectMake(250, 0, 0.5, 50)];
    [seperatorView setBackgroundColor:[UIColor whiteColor]];
    [returnView addSubview:seperatorView];
    seperatorView = nil;
    
    UIButton *sampleButton = [[UIButton alloc] initWithFrame:CGRectMake(250, 0, 50, 50)];
    sampleButton.tag = operation;
    [sampleButton addTarget:self action:@selector(undoButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [sampleButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [sampleButton setTitle:@"Undo" forState:UIControlStateNormal];
    [sampleButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [returnView addSubview:sampleButton];
    sampleButton = nil;
    return returnView;
}

- (void)deleteMessageAfterOperation:(NSString*)operation {
    NSString *uidKey = [NSString stringWithFormat:@"%d", messageSelected.uid];
    if ([operation isEqualToString:@"1"]) {
        [[MessageService instance] deleteMessage:uidKey];
        MCOIMAPOperation *msgOperation = [[EmailService instance].imapSession storeFlagsOperationWithFolder:self.emailFolder uids:[MCOIndexSet indexSetWithIndex:messageSelected.uid] kind:MCOIMAPStoreFlagsRequestKindAdd flags:MCOMessageFlagDeleted];
        [msgOperation start:^(NSError * error)
         {
//             NSLog(@"selected message flags %u UID is %u",messageSelected.flags,messageSelected.uid );
         }];
    }
    else {
        [[MessageService instance] deleteMessage:uidKey];
        MCOIMAPCopyMessagesOperation *opt = [[EmailService instance].imapSession copyMessagesOperationWithFolder:self.emailFolder uids:[MCOIndexSet indexSetWithIndex:messageSelected.uid] destFolder:TRASH];
        [opt start:^(NSError *error, NSDictionary *uidMapping) {
            NSLog(@"copied to folder with UID %@", uidMapping);
        }];
    }
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
    filterLabel.backgroundColor = (self.filterModel!=nil ? self.filterModel.barColor : [UIColor colorWithHexString:@"#F7F7F7"]);
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
    [self.view addSubview:tablecontroller.view];
    [self.view addSubview:self.tableView];

    for (UITextView *view in self.view.subviews) {
        if ([view isKindOfClass:[UITextView class]]) {
            view.scrollsToTop = NO;
        }
    }
    self.tableView.scrollsToTop = YES;

	[self.tableView registerClass:[EmailCell class] forCellReuseIdentifier:mailCellIdentifier];
    
	self.loadMoreActivityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    mailSearchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 40)];
    mailSearchBar.delegate = self;
    mailSearchBar.placeholder = @"Search";
    self.tableView.tableHeaderView = [self headerView];
}

- (UIView *)headerView {
    UIView *returnHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, 100)];
    
    if (!helpButton) {
        [helpButton removeFromSuperview];
        helpButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 40, WIDTH, 60)];
        [helpButton.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:18]];
        [helpButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        helpButton.contentEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 34);
    }
    
    UIImage *nextImage = [UIImage imageNamed:@"nextImage.png"];
    nextImage = [nextImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    disclosureArrow = [[UIImageView alloc] initWithFrame:CGRectMake(WIDTH - 10 - 24, 40 + 30 - 12, 24, 24)];
    [disclosureArrow setImage:nextImage];
    disclosureArrow.tintColor = UIColorFromRGB(0x007AFF);
    nextImage = nil;
 
    
    [helpButton setBackgroundColor:[UIColor clearColor]];
    if (!helpFlag) {
        disclosureArrow.hidden = NO;
        [helpButton setTitle:HELP_COMMENT forState:UIControlStateNormal];
        [helpButton setTitleColor:[UIColor colorWithHexString:DONE_BUTTON_BLUE] forState:UIControlStateNormal];
    }
    else {
        disclosureArrow.hidden = YES;
        [helpButton setTitle:GUIDE_FOR_SWIPING_CELL forState:UIControlStateNormal];
        [helpButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    }
    
//    [helpButton.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:18]];
    [helpButton addTarget:self action:@selector(helpButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [helpButton removeFromSuperview];
    [returnHeaderView addSubview:disclosureArrow];
    [returnHeaderView addSubview:helpButton];
    
    
    mailSearchBar.frame = CGRectMake(0, 0, WIDTH, 40);
    mailSearchBar.showsScopeBar = NO;
    
    if (!headerViewFlag) {
        returnHeaderView.frame = CGRectMake(0, 0, WIDTH, 60);
        helpButton.frame = CGRectMake(0, 0, WIDTH, 60);
        disclosureArrow.frame = CGRectMake(WIDTH - 10 - 24, 30 - 12, 24, 24);
        [mailSearchBar removeFromSuperview];
        
        UIView *sampleView = [[UIView alloc] initWithFrame:CGRectMake(0, 59.5, WIDTH, 0.5)];
        [sampleView setBackgroundColor:[UIColor lightGrayColor]];
        [returnHeaderView addSubview:sampleView];
        sampleView = nil;
    }
    else {
        returnHeaderView.frame = CGRectMake(0, 0, WIDTH, 100);
        helpButton.frame = CGRectMake(0, 40, WIDTH, 60);
        disclosureArrow.frame = CGRectMake(WIDTH - 10 - 24, 40 + 30 - 12, 24, 24);
        [returnHeaderView addSubview:mailSearchBar];
        
        UIView *sampleView = [[UIView alloc] initWithFrame:CGRectMake(0, 99.5, WIDTH, 0.5)];
        [sampleView setBackgroundColor:[UIColor lightGrayColor]];
        [returnHeaderView addSubview:sampleView];
        sampleView = nil;
    }
    
    return returnHeaderView;
}

- (void)fetchLatestEmail
{
//    [self.view bringSubviewToFront:tempAppDelegate.progressHUD];
//    [tempAppDelegate.progressHUD show:YES];=
//    [tempAppDelegate.progressHUD setHidden:NO];

    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    if(appDelegate.internetAvailable){
        appDelegate.isPullToRefresh = TRUE;
        [[EmailService instance] startAutoRefresh];
    }
    else{
        [tablecontroller.refreshControl endRefreshing];
    }
}

-(void) setFilterModel:(FunnelModel *)filterModel{
    _filterModel = filterModel;
    if(self.emailFolder == nil || self.emailFolder.length <= 0){
        self.emailFolder = INBOX;
    }
    
    if(filterLabel!=nil){
        filterLabel.backgroundColor = (self.filterModel!=nil ? self.filterModel.barColor : [UIColor colorWithHexString:@"#F7F7F7"]);
        filterLabel.text = (self.filterModel!=nil ? self.filterModel.filterTitle : ALL_FUNNL);
        if([EmailService instance].filterMessages.count == 0){
            NSLog(@"Call to loadLastNMessages from setFilterModel function");
            [[EmailService instance] loadLastNMessages:NUMBER_OF_MESSAGES_TO_LOAD_AT_START withTableController:self withFolder:self.emailFolder  withFetchRange:MCORangeEmpty];
        }
    }
}

/*- (void)searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller {
 self.tableView.tableHeaderView = searchBar;
 }*/

- (void)searchDisplayController:(UISearchDisplayController *)controller didLoadSearchResultsTableView:(UITableView *)tableView
{
	[tableView registerClass:[EmailCell class] forCellReuseIdentifier:mailCellIdentifier];
}

#pragma mark ScrollView
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (!headerViewFlag && scrollView.contentOffset.y < -5) {
        headerViewFlag = TRUE;
        self.tableView.tableHeaderView = nil;
        self.tableView.tableHeaderView = [self headerView];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {

}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if ([[tempAppDelegate.currentFunnelString lowercaseString] isEqualToString:[ALL_FUNNL lowercaseString]] || [[tempAppDelegate.currentFunnelString lowercaseString] isEqualToString:[ALL_OTHER_FUNNL lowercaseString]]) {
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
    if (helpFlag) {
        disclosureArrow.hidden = YES;
    }
    else {
        disclosureArrow.hidden = NO;
    }
    
    if(isSearching == NO){
        switch (indexPath.section){
            case 0:{
                EmailCell *cell = [tableView dequeueReusableCellWithIdentifier:mailCellIdentifier forIndexPath:indexPath];
                if (helpFlag && indexPath.row == 0) {
                    [cell.backgroundImageView setHidden:NO];
                }
                else {
                    [cell.backgroundImageView setHidden:YES];
                }
                if (tempCellForDisplay.tag == indexPath.row) {
                    tempCellForDisplay = nil;
                }
//                else
//                    [cell resetToOriginalState];
                cell.funnlLabel1.text = @"";
                cell.funnlLabel2.text = @"";
                cell.funnlLabel3.text = @"";
                cell.funnlLabel1.backgroundColor = CLEAR_COLOR;
                cell.funnlLabel2.backgroundColor = CLEAR_COLOR;
                cell.funnlLabel3.backgroundColor = CLEAR_COLOR;
                
                NSArray *tempMessageArray = [EmailService instance].filterMessages;
                if(tempMessageArray.count == 0){
                    return cell;
                }
                MessageModel *messageModel =tempMessageArray[indexPath.row];
                NSMutableDictionary *funnlLabelDictionary= [self getFunnlsDictionary:messageModel];
                int funnlLabelCount = 0;
                for (NSString *key in funnlLabelDictionary.allKeys) {
                    if (funnlLabelDictionary.allKeys.count > 0) {
                        if (funnlLabelDictionary.allKeys.count > 1) {
                            cell.funnlLabel1.text = [NSString stringWithFormat:@"%@ + %ld",key,(long)funnlLabelDictionary.allKeys.count - 1];
                            cell.funnlLabel1.backgroundColor = [UIColor colorWithHexString:[funnlLabelDictionary objectForKey:key]];
                            cell.funnlLabel1.textColor = [UIColor whiteColor];
                        }
                        else {
                            cell.funnlLabel1.text = key;
                            cell.funnlLabel1.backgroundColor = [UIColor colorWithHexString:[funnlLabelDictionary objectForKey:key]];
                            cell.funnlLabel1.textColor = [UIColor whiteColor];
                        }
                    }
//                    if(funnlLabelCount == 0){
//                    
//                    }
//                    else if(funnlLabelCount == 1){
//                        cell.funnlLabel2.text = key;
//                        if(funnlLabelDictionary.allKeys.count > 1){
//                            cell.funnlLabel2.text = [NSString stringWithFormat:@"%@ + %d ",key,funnlLabelDictionary.allKeys.count-1];
//                            cell.funnlLabel2.backgroundColor = [UIColor colorWithHexString:[funnlLabelDictionary objectForKey:key]];
//                            cell.funnlLabel2.textColor = [UIColor whiteColor];
//                        }
//                    }
                    [cell.funnlLabel1 sizeThatFits:CGSizeMake(60, 20)];
                    [cell.funnlLabel2 sizeThatFits:CGSizeMake(60, 20)];
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
                        
                        cell.senderLabel.frame = CGRectMake(30 - 17, 13, 320-108 + 17, 20);
                        cell.subjectLabel.frame = CGRectMake(30 - 17, 33 + 2.25, 320-108 + 17, 16);
                        cell.bodyLabel.frame = CGRectMake(30 - 17, 33 + 2.25 + 15 + 2, 320-108 + 17, 35);
                    }
                    else {
                        cell.readLabel.hidden = NO;
                        cell.readLabel.backgroundColor = [UIColor colorWithHexString:@"#007AFF"];
                        
                        cell.senderLabel.frame = CGRectMake(30, 13, 320-108, 20);
                        cell.subjectLabel.frame = CGRectMake(30 - 17, 33 + 2.25, 320-108 + 17, 16);
                        cell.bodyLabel.frame = CGRectMake(30 - 17, 33 + 2.25 + 15 + 2, 320-108 + 17, 35);
                    }
                }
                else{
                    if([(MessageModel*)[EmailService instance].filterMessages[indexPath.row] read]) {
                        cell.readLabel.backgroundColor = [UIColor clearColor];
                        cell.readLabel.hidden = YES;
                        
                        cell.senderLabel.frame = CGRectMake(30 - 17, 13, 320-108 + 17, 20);
                        cell.subjectLabel.frame = CGRectMake(30 - 17, 33 + 2.25, 320-108 + 17, 16);
                        cell.bodyLabel.frame = CGRectMake(30 - 17, 33 + 2.25 + 15 + 2, 320-108 + 17, 35);
                    }
                    else {
                        cell.readLabel.hidden = NO;
                        cell.readLabel.backgroundColor = [UIColor colorWithHexString:@"#007AFF"];
                        
                        cell.senderLabel.frame = CGRectMake(30, 13, 320-108, 20);
                        cell.subjectLabel.frame = CGRectMake(30 - 17, 33 + 2.25, 320-108 + 17, 16);
                        cell.bodyLabel.frame = CGRectMake(30 - 17, 33 + 2.25 + 15 + 2, 320-108 + 17, 35);
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
//                if(message.header.from.displayName.length){
//                    cell.senderLabel.text = [self removeAngularBracket:message.header.from.displayName];
//                }
//                else {
//                    cell.senderLabel.text = [self removeAngularBracket:message.header.from.mailbox];
//                }
                NSString *senderLabelText = [self removeAngularBracket:[self getDisplayName:message]];
                if (senderLabelText) {
                    cell.senderLabel.text = senderLabelText;
                }
                else {
                    cell.senderLabel.text = @"XXX";
                }
                // Changed by Chad
                // commented out by iauro
                cell.subjectLabel.text = message.header.subject;
                
                if (cell.subjectLabel.text.length == 0)
                    cell.subjectLabel.text = @"No Subject";
                else {
                    NSString *subjectString = cell.subjectLabel.text;
                    NSLog(@"%@",subjectString);
                    if ([self willFitString:cell.subjectLabel.text InLabel:cell.subjectLabel]) {
                        CGSize labelSize = [cell.subjectLabel.text sizeWithFont:MAIL_SUBJECT_FONT constrainedToSize:CGSizeMake(cell.subjectLabel.frame.size.width, cell.subjectLabel.frame.size.height) lineBreakMode:NSLineBreakByCharWrapping];
                        cell.threadLabel.frame = CGRectMake(13 + labelSize.width, 33 + 1.5, cell.threadLabel.frame.size.width, cell.threadLabel.frame.size.height);
                    }
                    else {
                        cell.threadLabel.frame = CGRectMake(13 + 320 - 108 + 17, 33 + 1.5, 48-5, 15);
                    }
                }
                
                if([(MessageModel*)[EmailService instance].filterMessages[indexPath.row] numberOfEmailInThread] > 1){
                    cell.threadLabel.text = [NSString stringWithFormat:@" (%d)",[(MessageModel*)[EmailService instance].filterMessages[indexPath.row] numberOfEmailInThread]];
                    [cell.threadLabel setHidden:NO];
                    [cell.detailDiscloser setHidden:YES];
                }
                else{
                    cell.threadLabel.text = @"";
                    [cell.threadLabel setHidden:YES];
                    [cell.detailDiscloser setHidden:YES];
                }
                
                
                NSString *uidKey = [NSString stringWithFormat:@"%d", message.uid];
                NSString *cachedPreview = [[MessageService instance] retrievePreviewContentWithID:uidKey];
                if ( cachedPreview != nil && ![cachedPreview isEqualToString:@""]) {
                    cell.bodyLabel.text = cachedPreview;
                }
                else{
                    // loads email body and stores in database
                    if(FETCH_MSG_BODY_AT_MSG_LOADING){
                        MCOIMAPMessageRenderingOperation * op = [[EmailService instance].imapSession htmlBodyRenderingOperationWithMessage:message folder:@"INBOX"];
                    
                        [op start:^(NSString * htmlString, NSError * error) {
                            NSArray *tempArray = [htmlString componentsSeparatedByString:@"<head>"];
                            if (tempArray.count > 1) {
                                htmlString = [tempArray objectAtIndex:1];
                            }
                            else {
                                tempArray = [htmlString componentsSeparatedByString:@"Subject:"];
                                if (tempArray.count > 1) {
                                    htmlString = [tempArray objectAtIndex:1];
                                }
                            }
                            NSMutableDictionary *paramDict = [[NSMutableDictionary alloc] init];
                            if(htmlString){
                                paramDict[uidKey] = htmlString;
                                NSLog(@"----ListView: HTML data callback recieved -----");
                                [[MessageService instance] updateMessageWithHTMLContent:paramDict];
                            }
                        }];
                    }

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
                                
                                //if (plainTextBodyString.length == 0)
                                
                                NSMutableDictionary *paramDict = [[NSMutableDictionary alloc] init];
                                paramDict[uidKey] = [self removeStartingSpaceFromString:plainTextBodyString];
                                [[MessageService instance] updateMessageWithDictionary:paramDict];
                                cell.bodyLabel.text = [[MessageService instance] retrievePreviewContentWithID:uidKey];
                                
                            }
                            else {
                                cell.bodyLabel.text = @"This message has no content.";
                            }
                        }
                        // message body is empty
                        else {
                            cell.bodyLabel.text = @"This message has no content.";

                        }
                        
                        cell.messageRenderingOperation = nil;
                    }];
                }
                
                UIView *archiveView = [self viewWithImageName:@"swipeArchive"];
                UIColor *yellowColor = [UIColor colorWithHexString:@"#FD814A"];

                UIView *trashView = [self viewWithImageName:@"swipeTrash"];
                UIColor *redColor = [UIColor colorWithHexString:@"#FD4747"];

                UIView *fullFunnlView = [self viewWithImageName:@"swipeFunnl"];
                UIColor *fullFunnlColor = [UIColor colorWithHexString:@"#57DB7F"];
                
                
                [cell setSwipeGestureWithView:archiveView color:yellowColor mode:MCSwipeTableViewCellModeExit state:MCSwipeTableViewCellState1 completionBlock:^(MCSwipeTableViewCell *cell, MCSwipeTableViewCellState state, MCSwipeTableViewCellMode mode) {
#ifdef TRACK_MIXPANEL
                    [[Mixpanel sharedInstance] track:@" Swiped an email left to right for Archive "];
#endif
                    NSLog(@"Did swipe \"Archive\" cell");
                    NSIndexPath *deleteIndexPath = [tableView indexPathForCell:cell];
                    selectedIndexPath = deleteIndexPath;
                    [tableView beginUpdates];
                    selectedMessageModel = [[EmailService instance].filterMessages objectAtIndex:deleteIndexPath.row];
                    [[EmailService instance].filterMessages removeObjectAtIndex:deleteIndexPath.row];
                    [[EmailService instance].messages removeObjectIdenticalTo:message];
                    [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObjects:deleteIndexPath, nil] withRowAnimation:UITableViewRowAnimationLeft];
                    [tableView endUpdates];
                    [cell swipeToOriginWithCompletion:nil];
                    [self.view showToast:[self tostViewForOperation:1] duration:TOST_DISPLAY_DURATION position:@"bottom"];
                    messageSelected = message;
                    [self performSelector:@selector(deleteMessageAfterOperation:) withObject:@"1" afterDelay:TOST_DISPLAY_DURATION];
                }];
                
                
                
                [cell setSwipeGestureWithView:trashView color:redColor mode:MCSwipeTableViewCellModeExit state:MCSwipeTableViewCellState2 completionBlock:^(MCSwipeTableViewCell *cell, MCSwipeTableViewCellState state, MCSwipeTableViewCellMode mode) {
#ifdef TRACK_MIXPANEL
                    [[Mixpanel sharedInstance] track:@"Swiped an email left to right for Trash"];
#endif
                    NSLog(@"Did swipe \"Trash\" cell");
                    NSIndexPath *deleteIndexPath = [tableView indexPathForCell:cell];
                    selectedIndexPath = deleteIndexPath;
                    selectedMessageModel = [[EmailService instance].filterMessages objectAtIndex:deleteIndexPath.row];
                    [tableView beginUpdates];
                    [[EmailService instance].filterMessagePreviews removeObjectForKey:uidKey];
                    [[EmailService instance].filterMessages removeObjectAtIndex:deleteIndexPath.row];
                    [[EmailService instance].messages removeObjectIdenticalTo:message];
                    [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObjects:deleteIndexPath, nil] withRowAnimation:UITableViewRowAnimationLeft];
                    [tableView endUpdates];
                    [self performSelector:@selector(deleteMessageAfterOperation:) withObject:@"2" afterDelay:TOST_DISPLAY_DURATION];
                    [cell swipeToOriginWithCompletion:nil];
                    [self.view showToast:[self tostViewForOperation:2] duration:TOST_DISPLAY_DURATION position:@"bottom"];
                    messageSelected = message;
                }];
                
                
                [cell setSwipeGestureWithView:fullFunnlView color:fullFunnlColor mode:MCSwipeTableViewCellModeExit state:MCSwipeTableViewCellState3 completionBlock:^(MCSwipeTableViewCell *cell, MCSwipeTableViewCellState state, MCSwipeTableViewCellMode mode) {
                    NSLog(@"Did swipe full cell, ");
                    helpFlag = FALSE;
                    if (indexPath.row == 0) {
                        [[(EmailCell *)cell backgroundImageView] setHidden:YES];
                    }
                    else {
                        EmailCell *tableViewCell = (EmailCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                        [tableViewCell.backgroundImageView setHidden:YES];
                    }
                    self.tableView.tableHeaderView = [self headerView];
#ifdef TRACK_MIXPANEL
                    [[Mixpanel sharedInstance] track:@"Swiped an email right to left to add to Funnl"];
#endif
                    
                    [cell swipeToOriginWithCompletion:nil];
                    MCOIMAPMessage *message = [MCOIMAPMessage importSerializable:[(MessageModel*)[EmailService instance].filterMessages[indexPath.row] messageJSON]];
                    FunnlPopUpView *funnlPopUpView = [[FunnlPopUpView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) withNewPopup:YES withMessageId:uidKey withMessage:message subViewOnViewController:self];
                    funnlPopUpView.mainVCdelegate = self.mainVCdelegate;
                    if ([FunnelService instance].allFunnels.count < 4){
//                        RNBlurModalView *modal = [[RNBlurModalView alloc] initWithViewController:self title:@"Hello Funnler!" message:@"Funnls help you to filter out emails from important senders – you can add multiple senders to a Funnl (eg. team) or create a new Funnl for key senders (eg. boss)"];
//                        [modal show];
                    }
                    [self.view addSubview:funnlPopUpView];
                    /*funnlPopUpView.alpha = 0;
                    funnlPopUpView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 2, 2);
                    [UIView animateWithDuration:ANIMATION_DURATION
                                          delay:0.0
                                        options: UIViewAnimationOptionCurveEaseInOut
                                     animations:^{
                                         funnlPopUpView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1, 1);
                                         funnlPopUpView.alpha = 1;
                                     }
                                     completion:^(BOOL finished){
                                         if(finished)
                                         {
                                             
                                         }
                                         // do any stuff here if you want
                                     }];*/
                    
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
                
                if ([EmailService instance].messages.count < [EmailService instance].totalNumberOfMessages){
                    cell.textLabel.text = @"Load more";
                }
//                    cell.textLabel.text = [NSString stringWithFormat:@"Load %lu more",MIN([EmailService instance].totalNumberOfMessages - [EmailService instance].messages.count, NUMBER_OF_MESSAGES_TO_LOAD)];
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
                
                
                cell.funnlLabel1.text = @"";
                cell.funnlLabel2.text = @"";
                cell.funnlLabel3.text = @"";
                cell.funnlLabel1.backgroundColor = CLEAR_COLOR;
                cell.funnlLabel2.backgroundColor = CLEAR_COLOR;
                cell.funnlLabel3.backgroundColor = CLEAR_COLOR;
                
                if ([(MessageModel*)searchMessages[indexPath.row] numberOfEmailInThread] > 1) {
                    if ([self isThreadRead:[NSString stringWithFormat:@"%llul",message.gmailThreadID]]) {
                        cell.readLabel.backgroundColor = [UIColor clearColor];
                        cell.readLabel.hidden = YES;
                        
                        cell.senderLabel.frame = CGRectMake(30 - 17, 13, 320-108 + 17, 20);
                        cell.subjectLabel.frame = CGRectMake(30 - 17, 33 + 2.25, 320-108 + 17, 15);
                        cell.bodyLabel.frame = CGRectMake(30 - 17, 33 + 2.25 + 15 + 2, 320-108 + 17, 35);
                    }
                    else {
                        cell.readLabel.hidden = NO;
                        cell.readLabel.backgroundColor = MAIL_READ_BLUE_COLOR;
                        
                        cell.senderLabel.frame = CGRectMake(30, 13, 320-108, 20);
                        cell.subjectLabel.frame = CGRectMake(30, 33 + 2.25, 320-108, 15);
                        cell.bodyLabel.frame = CGRectMake(30, 33 + 2.25 + 15 + 2, 320-108, 35);
                    }
                }
                else{
                    if([(MessageModel*)searchMessages[indexPath.row] read]) {
                        cell.readLabel.backgroundColor = [UIColor clearColor];
                        cell.readLabel.hidden = YES;
                        
                        cell.senderLabel.frame = CGRectMake(30 - 17, 13, 320-108 + 17, 20);
                        cell.subjectLabel.frame = CGRectMake(30 - 17, 33 + 2.25, 320-108 + 17, 15);
                        cell.bodyLabel.frame = CGRectMake(30 - 17, 33 + 2.25 + 15 + 2, 320-108 + 17, 35);
                    }
                    else {
                        cell.readLabel.hidden = NO;
                        cell.readLabel.backgroundColor = MAIL_READ_BLUE_COLOR;
                        
                        cell.senderLabel.frame = CGRectMake(30, 13, 320-108, 20);
                        cell.subjectLabel.frame = CGRectMake(30, 33 + 2.25, 320-108, 15);
                        cell.bodyLabel.frame = CGRectMake(30, 33 + 2.25 + 15 + 2, 320-108, 35);
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
                    
#ifdef TRACK_MIXPANEL
                    [[Mixpanel sharedInstance] track:@"Swiped an email left to right for Archive"];
#endif
                    
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
//                         NSLog(@"selected message flags %u UID is %u",message.flags,message.uid );
                     }];
                    [cell swipeToOriginWithCompletion:nil];
                }];
                
                
                [cell setSwipeGestureWithView:fullFunnlView color:fullFunnlColor mode:MCSwipeTableViewCellModeExit state:MCSwipeTableViewCellState3 completionBlock:^(MCSwipeTableViewCell *cell, MCSwipeTableViewCellState state, MCSwipeTableViewCellMode mode) {
                    NSLog(@"Did swipe full cell, -----");
#ifdef TRACK_MIXPANEL
                    [[Mixpanel sharedInstance] track:@"Add email to Funnl"];
#endif
                    [cell swipeToOriginWithCompletion:nil];
                    MCOIMAPMessage *message = [MCOIMAPMessage importSerializable:[(MessageModel*)searchMessages[indexPath.row] messageJSON]];
                    FunnlPopUpView *funnlPopUpView = [[FunnlPopUpView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) withNewPopup:YES withMessageId:uidKey withMessage:message subViewOnViewController:self];
                    funnlPopUpView.mainVCdelegate = self.mainVCdelegate;
                    
                    [self.view addSubview:funnlPopUpView];
                    funnlPopUpView.alpha = 0;
                    funnlPopUpView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 2, 2);
                    [UIView animateWithDuration:ANIMATION_DURATION
                                          delay:0.0
                                        options: UIViewAnimationOptionCurveEaseInOut
                                     animations:^{
                                         funnlPopUpView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1, 1);
                                         funnlPopUpView.alpha = 1;
                                     }
                                     completion:^(BOOL finished){
                                         if(finished)
                                         {
                                             
                                         }
                                         // do any stuff here if you want
                                     }];
                    
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
                
                if(self.filterModel == nil || [self.filterModel.funnelId isEqualToString:@"0"] || [self.filterModel.funnelId isEqualToString:@"1"]){

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
#ifdef TRACK_MIXPANEL
    [[Mixpanel sharedInstance] track:@"left swipe: Archive"];
#endif
    MCOIMAPMessage *message = [MCOIMAPMessage importSerializable:[(MessageModel*)[EmailService instance].filterMessages[sender.tag] messageJSON]];
    
    [_tableView beginUpdates];
    [[EmailService instance].filterMessagePreviews removeObjectForKey:[NSString stringWithFormat:@"%d",message.uid]];
    [[EmailService instance].filterMessages removeObjectAtIndex:sender.tag];
    [[EmailService instance].messages removeObjectIdenticalTo:message];
    [_tableView deleteRowsAtIndexPaths:[NSArray arrayWithObjects:[NSIndexPath indexPathForItem:sender.tag inSection:0], nil] withRowAnimation:UITableViewRowAnimationLeft];
    [_tableView endUpdates];
    [_tableView reloadData];
//    NSLog(@"selected message flags %u UID is %u",message.flags,message.uid );
}

- (void)fullSwipe:(UIButton*)sender {
    [_tableView reloadData];
    NSLog(@"in [fullSwipe]");
#ifdef TRACK_MIXPANEL
    [[Mixpanel sharedInstance] track:@"fullSwipe: add to funnl pressed"];
#endif
    MCOIMAPMessage *message = [MCOIMAPMessage importSerializable:[(MessageModel*)[EmailService instance].filterMessages[sender.tag] messageJSON]];
    FunnlPopUpView *funnlPopUpView = [[FunnlPopUpView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) withNewPopup:YES withMessageId:[NSString stringWithFormat:@"%d",message.uid] withMessage:message subViewOnViewController:self];
    funnlPopUpView.mainVCdelegate = self.mainVCdelegate;
    [self.view addSubview:funnlPopUpView];
}

- (void)halfSwipe:(UIButton*)sender {
    [_tableView reloadData];
    NSLog(@"in [halfSwipe]");
#ifdef TRACK_MIXPANEL
    [[Mixpanel sharedInstance] track:@"halfSwipe"];
#endif
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
#ifdef TRACK_MIXPANEL
    [[Mixpanel sharedInstance] track:@"User Loaded more emails"];
#endif
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
//        NSLog(@"selected message flags %u UID is %u",message.flags,message.uid );
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
#ifdef TRACK_MIXPANEL
                [[Mixpanel sharedInstance] track:@"User Viewed Email"];
#endif
                MCOIMAPMessage *msg = [MCOIMAPMessage importSerializable:[(MessageModel*)[EmailService instance].filterMessages[indexPath.row] messageJSON]];
                //MsgViewController *vc = [[MsgViewController alloc] init];
                MCTMsgViewController *vc = [[MCTMsgViewController alloc] init];
                vc.folder = self.emailFolder;
                vc.selectedIndexPath = indexPath;
                vc.messageModel = (MessageModel*)[EmailService instance].filterMessages[indexPath.row];
                vc.address = msg.header.from;
                vc.message = msg;
                vc.session = [EmailService instance].imapSession;
//                msg.flags = msg.flags | MCOMessageFlagSeen;
//                MCOIMAPOperation *msgOperation=[[EmailService instance].imapSession storeFlagsOperationWithFolder:self.emailFolder uids:[MCOIndexSet indexSetWithIndex:msg.uid] kind:MCOIMAPStoreFlagsRequestKindAdd flags:MCOMessageFlagSeen];
//                [msgOperation start:^(NSError * error)
//                 {
//                     NSLog(@"selected message flags %u UID is %u",msg.flags,msg.uid );
//                 }];
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
//                    NSLog(@"[EmailsTableViewController didSelect] %d",totalNumberOfMessage);
                    NSLog(@"Call to loadLastNMessages from  didSelectRowAtIndexPath   function & isSearching = NO");
                    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
                    if(appDelegate.internetAvailable){
                        NSString *PRIMARY_PAGE_TOKEN = [[NSUserDefaults standardUserDefaults] objectForKey:@"PRIMARY_PAGE_TOKEN"];
                        //if(PRIMARY_PAGE_TOKEN)
                        [appDelegate.loginViewController getPrimaryMessages:[EmailService instance].userEmailID nextPageToken:PRIMARY_PAGE_TOKEN numberOfMaxResult:100 ];
                        
                        //int totalNumberOfMessage = (int)[[MessageService instance] messagesAllTopMessages].count + NUMBER_OF_MESSAGES_TO_LOAD;
                        [[EmailService instance] loadLastNMessages:NUMBER_OF_MESSAGES_TO_LOAD withTableController:self withFolder:INBOX  withFetchRange:MCORangeEmpty];
                        cell.accessoryView = self.loadMoreActivityView;
                        [self.loadMoreActivityView startAnimating];
                    }
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
            if(self.filterModel == nil || [self.filterModel.funnelId isEqualToString:@"0"] || [self.filterModel.funnelId isEqualToString:@"1"]){
                [self searchOnlineWithString:mailSearchBar.text];
            }
            else{
                
            }
        }
        else {
#ifdef TRACK_MIXPANEL
            [[Mixpanel sharedInstance] track:@"User viewed email"];
#endif
            MCOIMAPMessage *msg = [MCOIMAPMessage importSerializable:[(MessageModel*)searchMessages[indexPath.row] messageJSON]];
            //MsgViewController *vc = [[MsgViewController alloc] init];
            MCTMsgViewController *vc = [[MCTMsgViewController alloc] init];
            vc.selectedIndexPath = indexPath;
            vc.messageModel = (MessageModel*)searchMessages[indexPath.row];
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
- (NSString *)getDisplayName:(MCOIMAPMessage *)message {
    NSString *displayName = nil;
    if (message.header.from.displayName) {
        displayName = message.header.from.displayName;
    }
    else if (message.header.from.mailbox) {
        displayName = message.header.from.mailbox;
    }
    else if (message.header.sender.displayName) {
        displayName = message.header.sender.displayName;
    }
    else if (message.header.sender.mailbox) {
        displayName = message.header.sender.mailbox;
    }
    else
        displayName = nil;
    return displayName;
}

- (BOOL)willFitString:(NSString *)string InLabel:(UILabel *)label {
    CGSize labelSize = [string sizeWithFont:MAIL_SUBJECT_FONT constrainedToSize:CGSizeMake(1000, label.frame.size.height) lineBreakMode:NSLineBreakByTruncatingTail];
    if (labelSize.width > label.frame.size.width) {
        return NO;
    }
    return YES;
}


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
    return 100.25;
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"Create Funnl";
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        if(indexPath.section == 0){
//            MCOIMAPMessage *message = [EmailService instance].filterMessages[indexPath.row];
//            MCOAddress *emailAddress = message.header.from;
//            NSMutableArray *mailArray = [[NSMutableArray alloc] init];
//            [mailArray addObject:emailAddress];
//            [mailArray addObjectsFromArray:message.header.cc];
//            
//            NSMutableDictionary *sendersDictionary = [[NSMutableDictionary alloc] init];
//            int count = 0;
//            for (MCOAddress *address in mailArray) {
//                NSString *email = [address.mailbox lowercaseString];
//                [sendersDictionary setObject:email forKey:[NSIndexPath indexPathForRow:count inSection:1]];
//                count ++;
//            }
            
            MCOIMAPMessage *message = [EmailService instance].filterMessages[indexPath.row];
            MCOAddress *emailAddress = message.header.from;
            MCOAddress *listservEmailAdress = message.header.sender; //Added by Chad
            NSMutableArray *mailArray = [[NSMutableArray alloc] init];
            
            BOOL flag = TRUE;
            for (MCOAddress *emailID in message.header.cc) {
                if ([emailAddress.mailbox.lowercaseString isEqual:emailID.mailbox.lowercaseString]) {
                    flag = FALSE;
                }
            }
            
            if (flag) {
                
                // Check if the 2 email addresses are equivalent and if the listserv email is already in the array
                
                if (![emailAddress.mailbox.lowercaseString isEqual:listservEmailAdress.mailbox.lowercaseString]) {
                    //for (MCOAddress *emailID in message.header.cc) {
                    // if ([listservEmailAdress.mailbox.lowercaseString isEqual:emailID.mailbox.lowercaseString]) {
                    [mailArray addObject:listservEmailAdress.mailbox];
                    // }
                    //}
                }
                [mailArray addObject:emailAddress.mailbox];
            }
            
            for (MCOAddress *emailID in message.header.cc) {
                if (![emailID.mailbox isEqualToString:message.header.sender.mailbox]) {
                    [mailArray addObject:emailID.mailbox];
                }
            }
            
            NSMutableDictionary *sendersDictionary = [[NSMutableDictionary alloc] init];
            
            for (int count = 0 ; count < mailArray.count ; count ++) {
                [sendersDictionary setObject:[mailArray objectAtIndex:count] forKey:[NSIndexPath indexPathForRow:count inSection:1]];
            }
           
            if(IS_NEW_CREATE_FUNNEL){
                FMCreateFunnlViewController *createFunnlViewController = [[FMCreateFunnlViewController alloc] initWithSelectedContactArray:nil name:nil andSubjects:nil];
                createFunnlViewController.mainVCdelegate = self.mainVCdelegate;
                [self.mainVCdelegate pushViewController:createFunnlViewController];
                createFunnlViewController = nil;
            }else{
                CreateFunnlViewController *creatFunnlViewController = [[CreateFunnlViewController alloc] initTableViewWithSenders:sendersDictionary subjects:nil filterModel:nil];
                creatFunnlViewController.mainVCdelegate = self.mainVCdelegate;
                [self.mainVCdelegate pushViewController:creatFunnlViewController];
                creatFunnlViewController = nil;
                self.tableView.editing = NO;
            }
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
- (void)helpButtonPressed:(UIButton *)sender {
    

    if (sender == helpButton && ([sender.titleLabel.text isEqualToString:GUIDE_FOR_SWIPING_CELL] || [sender.titleLabel.text isEqualToString:HELP_COMMENT])) {
        /*if (!helpFlag) {
            disclosureArrow.hidden = YES;

            [helpButton setTitle:GUIDE_FOR_SWIPING_CELL forState:UIControlStateNormal];
            [helpButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            if (isSearching == NO) {
                if ([[[EmailService instance] filterMessages] count]) {
                    EmailCell *tempCell = (EmailCell*)[_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                    [tempCell.backgroundImageView setHidden:NO];
                }
            }
            else {
                if (searchMessages.count) {
                    EmailCell *tempCell = (EmailCell*)[_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                    [tempCell.backgroundImageView setHidden:NO];
                }
            }
        }
        else {
            disclosureArrow.hidden = NO;
            
            [helpButton setTitle:HELP_COMMENT forState:UIControlStateNormal];
            [helpButton setTitleColor:[UIColor colorWithHexString:DONE_BUTTON_BLUE] forState:UIControlStateNormal];
            if(isSearching == NO){
                if ([[[EmailService instance] filterMessages] count]) {
                    EmailCell *tempCell = (EmailCell*)[_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                    [tempCell.backgroundImageView setHidden:YES];
                }
            }
            else {
                if ([searchMessages count]) {
                    EmailCell *tempCell = (EmailCell*)[_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                    [tempCell.backgroundImageView setHidden:YES];
                }
            }
        }
        helpFlag = !helpFlag;*/
        AppDelegate *appDelegate = APPDELEGATE;
        [appDelegate performSelector:@selector(loadVIPFunnelViewController) withObject:nil afterDelay:0];
    }
    else {
        disclosureArrow.hidden = NO;
        [self.helpButton setTitle:HELP_COMMENT forState:UIControlStateNormal];
        [helpButton setTitleColor:[UIColor colorWithHexString:DONE_BUTTON_BLUE] forState:UIControlStateNormal];
        helpFlag = FALSE;
        AppDelegate *tempApp = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        [[(MainVC *)tempApp.mainVCControllerInstance segmentControl] setSelectedSegmentIndex:1];
        [(MainVC *)tempApp.mainVCControllerInstance segmentControllerClicked:[(MainVC *)tempApp.mainVCControllerInstance segmentControl]];
    }
}

- (UIView *)viewWithImageName:(NSString *)imageName {
    UIImage *image = [UIImage imageNamed:imageName];
    UIImageView *imageView = [[UIImageView alloc] init];
    if ([imageName isEqualToString:@"swipeArchive"]) {
        imageView.frame = CGRectMake(-40, 0, 80, 80);
    }
    else if ([imageName isEqualToString:@"swipeTrash"]) {
        imageView.frame = CGRectMake(-40, 0, 80, 80);
    }
    else
        imageView.frame = CGRectMake(30, 0, 80, 80);
    [imageView setImage:image];
    imageView.contentMode = UIViewContentModeCenter;
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
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar{
#ifdef TRACK_MIXPANEL
    [[Mixpanel sharedInstance] track:@"Clicked in the Search bar"];
#endif
    CGRect searchBarFrame = searchBar.frame;
    searchBarFrame.size.height = 80.f;
    searchBar.frame = searchBarFrame;
    searchBar.showsCancelButton = YES;
    searchBar.showsScopeBar = YES;
    NSArray *scopeButtonTitles = @[@"All Mail",@"Current Funnl"];
    [searchBar setScopeButtonTitles:scopeButtonTitles];
    searchBar.selectedScopeButtonIndex = 1;
    scopeButtonPressedIndexNumber = YES;
    self.tableView.tableHeaderView = searchBar;
    [self.view bringSubviewToFront: greyView];
    greyView.hidden = NO;
    return YES;
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar{
    //commented by iauro
    /*CGRect searchBarFrame = searchBar.frame;
    searchBarFrame.size.height = 40.f;
    searchBar.frame = searchBarFrame;
    searchBar.showsCancelButton = NO;
    searchBar.showsScopeBar = NO;
    NSArray *scopeButtonTitles = nil;
    [searchBar setScopeButtonTitles:scopeButtonTitles];
    self.tableView.tableHeaderView = searchBar;*/
    self.tableView.tableHeaderView = nil;
    self.tableView.tableHeaderView = [self headerView];
    greyView.hidden = YES;
    [self.tableView reloadData];
    return YES;
}

- (void)searchBar:(UISearchBar *)searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope {
    scopeButtonPressedIndexNumber = selectedScope;
}


- (BOOL)searchBar:(UISearchBar *)searchBar shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    return YES;
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar;{
    greyView.hidden = NO;
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar;{
    greyView.hidden = YES;
}

#pragma mark SearchFunction
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    
    [searchBar resignFirstResponder];
    NSString *searchText = searchBar.text;
    isSearching = YES;
    greyView.hidden = YES;
    if(!scopeButtonPressedIndexNumber){
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
                        tempMessageModel.gmailMessageID = [NSString stringWithFormat:@"%llu",m.gmailMessageID];
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
    helpFlag = FALSE;
    filterLabel.text = self.filterModel.filterTitle;
    searchBar.text = @"";
    [searchBar resignFirstResponder];
    isSearching = NO;
    searchBar.showsCancelButton = NO;
//    [self.tableView reloadData];
//    self.tableView.tableHeaderView = [self headerView];
}

@end
