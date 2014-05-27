//
//  EmailsTableViewController.m
//  FunnlMail
//
//  Created by Daniel Judd on 5/26/14.
//  Copyright (c) 2014 FunnlMail. All rights reserved.
//

#import "EmailsTableViewController.h"
#import "EmailService.h"

#import "FilterViewCell.h"
#import "View+MASAdditions.h"
#import "FilterModel.h"
#import <MailCore/MailCore.h>
#import "EmailCell.h"
#import "MsgViewController.h"
#import "KeychainItemWrapper.h"
#import "EmailService.h"
#import "CreateFunnlviewController.h"
#import "UIColor+HexString.h"

static NSString *FILTER_VIEW_CELL = @"FilterViewCell";
static NSString *mailCellIdentifier = @"MailCell";
static NSString *inboxInfoIdentifier = @"InboxStatusCell";

@interface EmailsTableViewController ()
@end

@implementation EmailsTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[EmailService instance] startLogin: self];
    [self setupView];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
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
    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    self.tableView.rowHeight = 71.0;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;    
    [self.tableView registerClass:[FilterViewCell class] forCellReuseIdentifier:FILTER_VIEW_CELL];
    
    // TODO: change self.view.mas_top to bottom of filter label
    /*[self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        //make.top.equalTo(filterNavigationView.mas_top).with.offset(0);
        make.left.equalTo(self.view.mas_left).with.offset(0);
        make.right.equalTo(self	.view.mas_right).with.offset(0);
        make.bottom.equalTo(self.view.mas_bottom).with.offset(0);
    }];*/
    
	[self.tableView registerClass:[EmailCell class] forCellReuseIdentifier:mailCellIdentifier];
//    [self.tableView setContentInset:UIEdgeInsetsMake(40,0,0,0)];
  
    filterNavigationView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 80)];
    filterNavigationView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:filterNavigationView];
    
    /*[filterNavigationView mas_makeConstraints:^(MASConstraintMaker *make) {
      make.top.equalTo(self.view.mas_top).with.offset(44); // we should calculate this (self.topLayoutGuide.length?)
      make.left.equalTo(self.view.mas_left).with.offset(0);
      make.right.equalTo(self.view.mas_right).with.offset(0);
    }];*/
  
    filterLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 40)];
    filterLabel.textColor = [UIColor whiteColor];
    filterLabel.backgroundColor = (self.filterModel!=nil ? self.filterModel.barColor : [UIColor colorWithHexString:@"#2EB82E"]);
    filterLabel.text = (self.filterModel!=nil ? self.filterModel.filterTitle : @"All");
    filterLabel.textAlignment = NSTextAlignmentCenter;
    [filterNavigationView addSubview:filterLabel];
    [self.view bringSubviewToFront:filterLabel];
    /*
     [filterLabel mas_makeConstraints:^(MASConstraintMaker *make) {
     make.top.equalTo(filterNavigationView.mas_top).with.offset(0);
     make.left.equalTo(filterNavigationView.mas_left).with.offset(0);
     make.right.equalTo(filterNavigationView.mas_right).with.offset(0);
     make.bottom.equalTo(filterNavigationView.mas_bottom).with.offset(0);
     }];
     */
  
	self.loadMoreActivityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    
    searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 40, self.view.frame.size.width, 40)];
    searchBar.delegate = self;
    searchDisplayController = [[UISearchDisplayController alloc] initWithSearchBar:searchBar contentsController:self];
    searchDisplayController.delegate = self;
    searchDisplayController.searchResultsDataSource = self;
    searchDisplayController.searchResultsDelegate = self;
    [filterNavigationView addSubview:searchDisplayController.searchBar];
    //[self.tableView insertSubview:self.searchDisplayController.searchBar aboveSubview:self.tableView];
    self.tableView.tableHeaderView = filterNavigationView;
}

-(void) setFilterModel:(FilterModel *)filterModel{
    _filterModel = filterModel;
    if(filterLabel!=nil){
        filterLabel.backgroundColor = (self.filterModel!=nil ? self.filterModel.barColor : [UIColor colorWithHexString:@"#2EB82E"]);
        filterLabel.text = (self.filterModel!=nil ? self.filterModel.filterTitle : @"All");
      [[EmailService instance] loadLastNMessages:[EmailService instance].messages.count + NUMBER_OF_MESSAGES_TO_LOAD : self];
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
	return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (section == 1)
	{
		if ([EmailService instance].totalNumberOfInboxMessages >= 0)
			return 1;
		
		return 0;
	}
	
	return [EmailService instance].filterMessages.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	switch (indexPath.section)
	{
		case 0:
		{
			EmailCell *cell = [tableView dequeueReusableCellWithIdentifier:mailCellIdentifier forIndexPath:indexPath];
			MCOIMAPMessage *message = [EmailService instance].filterMessages[indexPath.row];
			
			cell.textLabel.text = message.header.subject;
			
			NSString *uidKey = [NSString stringWithFormat:@"%d", message.uid];
			NSString *cachedPreview = [EmailService instance].filterMessagePreviews[uidKey];
			
			if (cachedPreview)
			{
				cell.detailTextLabel.text = cachedPreview;
			}
			else
			{
				cell.messageRenderingOperation = [[EmailService instance].imapSession plainTextBodyRenderingOperationWithMessage:message folder:@"INBOX"];
				[cell.messageRenderingOperation start:^(NSString * plainTextBodyString, NSError * error) {
					cell.detailTextLabel.text = plainTextBodyString;
					cell.messageRenderingOperation = nil;
					[EmailService instance].filterMessagePreviews[uidKey] = plainTextBodyString;
				}];
			}
			return cell;
			break;
		}
			
		case 1:
		{
			UITableViewCell *cell =
			[tableView dequeueReusableCellWithIdentifier:inboxInfoIdentifier];
			
			if (!cell)
			{
				cell =
				[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                       reuseIdentifier:inboxInfoIdentifier];
				
				cell.textLabel.font = [UIFont boldSystemFontOfSize:14];
				cell.textLabel.textAlignment = NSTextAlignmentCenter;
				cell.detailTextLabel.textAlignment = NSTextAlignmentCenter;
                cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
			}
			
			if ([EmailService instance].messages.count < [EmailService instance].totalNumberOfInboxMessages)
			{
				cell.textLabel.text =
				[NSString stringWithFormat:@"Load %lu more",
				 MIN([EmailService instance].totalNumberOfInboxMessages - [EmailService instance].messages.count,
                     NUMBER_OF_MESSAGES_TO_LOAD)];
			}
			else
			{
				cell.textLabel.text = nil;
			}
			
			cell.detailTextLabel.text =
			[NSString stringWithFormat:@"%ld message(s)",
			 (long)[EmailService instance].totalNumberOfInboxMessages];
			
			cell.accessoryView = self.loadMoreActivityView;
			
			if (self.isLoading)
				[self.loadMoreActivityView startAnimating];
			else
				[self.loadMoreActivityView stopAnimating];
			
			return cell;
			break;
		}
			
		default:
			return nil;
			break;
	}
	
}
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    NSLog(@"started editing");
    [searchBar becomeFirstResponder];
    //self.tableView.tableHeaderView = searchBar;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	switch (indexPath.section)
	{
		case 0:
		{
			MCOIMAPMessage *msg = [EmailService instance].filterMessages[indexPath.row];
			MsgViewController *vc = [[MsgViewController alloc] init];
			vc.folder = @"INBOX";
			vc.message = msg;
			vc.session = [EmailService instance].imapSession;
            
            //[self.navigationController pushViewController:vc animated:YES];
			[self.mainVCdelegate pushViewController:vc];
            
			break;
		}
			
		case 1:
		{
			UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
			
			if (!self.isLoading &&
                [EmailService instance].messages.count < [EmailService instance].totalNumberOfInboxMessages)
			{
				[[EmailService instance] loadLastNMessages:[EmailService instance].messages.count + NUMBER_OF_MESSAGES_TO_LOAD : self];
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

#pragma mark - Table View
- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    // TODO: Implement this
    return NO;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 71.0;
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
      
      CreateFunnlViewController *creatFunnlViewController = [[CreateFunnlViewController alloc] initTableViewWithSenders:sendersDictionary subjects:nil];
      [self.mainVCdelegate pushViewController:creatFunnlViewController];
      creatFunnlViewController = nil;
      self.tableView.editing = NO;
    }
  }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
  if(indexPath.section == 0){
    return YES;
  }
  return NO;
}


@end
