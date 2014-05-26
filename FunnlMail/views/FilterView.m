//
//  FilterView.m
//  FunnlMail
//
//  Created by Michael Raber on 4/9/14.
//  Copyright (c) 2014 FunnlMail. All rights reserved.
//

#import "FilterView.h"
#import "FilterViewCell.h"
#import "View+MASAdditions.h"
#import "FilterModel.h"
#import <MailCore/MailCore.h>
#import "EmailCell.h"
#import "MsgViewController.h"
#import "KeychainItemWrapper.h"
#import "EmailService.h"
#import "CreateFunnlviewController.h"

static NSString *FILTER_VIEW_CELL = @"FilterViewCell";

#define CLIENT_ID @"the-client-id"
#define CLIENT_SECRET @"the-client-secret"
#define KEYCHAIN_ITEM_NAME @"MailCore OAuth 2.0 Token"

#define NUMBER_OF_MESSAGES_TO_LOAD		10
static NSString *mailCellIdentifier = @"MailCell";
static NSString *inboxInfoIdentifier = @"InboxStatusCell";

@interface FilterView ()

@end

@implementation FilterView

- (id)init
{
    self = [super init];
    if (self) {
        [self setupView];
        // This logs a user in and loads emails into the tableview
        [[EmailService instance] startLogin: self];
    }
    return self;
}


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupView];
    }
    return self;
}

- (void)setupView
{
	// Do any additional setup after loading the view.
    
    filterNavigationView = [[UIView alloc]init];
    filterNavigationView.backgroundColor = [UIColor orangeColor];
    [self addSubview:filterNavigationView];
    
    [filterNavigationView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_top).with.offset(44); // we should calculate this (self.topLayoutGuide.length?)
        make.left.equalTo(self.mas_left).with.offset(0);
        make.right.equalTo(self.mas_right).with.offset(0);
    }];
    
    // need to figure out how to do this with Masonry
    /*NSLayoutConstraint *constraint;
    constraint = [NSLayoutConstraint
                  constraintWithItem:filterNavigationView
                  attribute: NSLayoutAttributeHeight
                  relatedBy:NSLayoutRelationEqual
                  toItem:filterNavigationView
                  attribute:NSLayoutAttributeHeight
                  multiplier:0
                  constant:22];
    
    [self addConstraint:constraint];*/
    
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
    
    self.tableView = [[UITableView alloc]init];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self addSubview:self.tableView];
    
    [self.tableView registerClass:[FilterViewCell class] forCellReuseIdentifier:FILTER_VIEW_CELL];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(filterLabel.mas_bottom).with.offset(0);
        make.left.equalTo(self.mas_left).with.offset(0);
        make.right.equalTo(self.mas_right).with.offset(0);
        make.bottom.equalTo(self.mas_bottom).with.offset(0);
    }];
    
	[self.tableView registerClass:[EmailCell class]
           forCellReuseIdentifier:mailCellIdentifier];
    
	self.loadMoreActivityView =
	[[UIActivityIndicatorView alloc]
	 initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
	
	//[[NSUserDefaults standardUserDefaults] registerDefaults:@{ HostnameKey: @"imap.gmail.com" }];
	
    /*if ([[NSUserDefaults standardUserDefaults] boolForKey:@"OAuth2Enabled"]) {
     [self startOAuth2];
     } else {}*/
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
			
            UIButton *addButton = [UIButton buttonWithType:UIButtonTypeContactAdd];
            [addButton addTarget:self action:@selector(createAddFunnlView) forControlEvents:UIControlEventTouchUpInside];
            cell.accessoryView = addButton;
   
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

-(void)createAddFunnlView{
    CreateFunnlViewController *creatFunnlViewController = [[CreateFunnlViewController alloc] init];
    [self.mainVCdelegate pushViewController:creatFunnlViewController];
    creatFunnlViewController = nil;
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath{
    [self createAddFunnlView];
}

@end
