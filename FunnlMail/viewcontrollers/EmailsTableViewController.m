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

static NSString *FILTER_VIEW_CELL = @"FilterViewCell";

#define CLIENT_ID @"the-client-id"
#define CLIENT_SECRET @"the-client-secret"
#define KEYCHAIN_ITEM_NAME @"MailCore OAuth 2.0 Token"

#define NUMBER_OF_MESSAGES_TO_LOAD		10
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
    
    filterNavigationView = [[UIView alloc]init];
    filterNavigationView.backgroundColor = [UIColor orangeColor];
    [self.view addSubview:filterNavigationView];
    
    [filterNavigationView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_top).with.offset(44); // we should calculate this (self.topLayoutGuide.length?)
        make.left.equalTo(self.view.mas_left).with.offset(0);
        make.right.equalTo(self.view.mas_right).with.offset(0);
    }];
    
    // need to figure out how to do this with Masonry
    
    
    filterLabel = [[UILabel alloc] init];
    filterLabel.textColor = [UIColor whiteColor];
    filterLabel.backgroundColor = (self.filterModel!=nil ? self.filterModel.barColor : [UIColor yellowColor]);
    filterLabel.text = (self.filterModel!=nil ? self.filterModel.filterTitle : @"");
    filterLabel.textAlignment = NSTextAlignmentCenter;
    [filterNavigationView addSubview:filterLabel];
    [filterLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(filterNavigationView.mas_top).with.offset(0);
        make.left.equalTo(filterNavigationView.mas_left).with.offset(0);
        make.right.equalTo(filterNavigationView.mas_right).with.offset(0);
        make.bottom.equalTo(filterNavigationView.mas_bottom).with.offset(0);
    }];
    
    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 100, self.view.frame.size.width, self.view.frame.size.height - 100)];
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
    
	[self.tableView registerClass:[EmailCell class]
           forCellReuseIdentifier:mailCellIdentifier];
    
	self.loadMoreActivityView =
	[[UIActivityIndicatorView alloc]
	 initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
}

-(void) setFilterModel:(FilterModel *)filterModel{
    _filterModel = filterModel;
    
    if(filterLabel!=nil){
        filterLabel.backgroundColor = (self.filterModel!=nil ? self.filterModel.barColor : [UIColor yellowColor]);
        filterLabel.text = (self.filterModel!=nil ? self.filterModel.filterTitle : @"");
    }
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
	
	return [EmailService instance].messages.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	switch (indexPath.section)
	{
		case 0:
		{
			EmailCell *cell = [tableView dequeueReusableCellWithIdentifier:mailCellIdentifier forIndexPath:indexPath];
			MCOIMAPMessage *message = [EmailService instance].messages[indexPath.row];
			
			cell.textLabel.text = message.header.subject;
			
			NSString *uidKey = [NSString stringWithFormat:@"%d", message.uid];
			NSString *cachedPreview = [EmailService instance].messagePreviews[uidKey];
			
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
					[EmailService instance].messagePreviews[uidKey] = plainTextBodyString;
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	switch (indexPath.section)
	{
		case 0:
		{
			MCOIMAPMessage *msg = [EmailService instance].messages[indexPath.row];
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 71.0;
}

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

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
