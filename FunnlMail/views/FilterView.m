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

static NSString *FILTER_VIEW_CELL = @"FilterViewCell";

#define CLIENT_ID @"the-client-id"
#define CLIENT_SECRET @"the-client-secret"
#define KEYCHAIN_ITEM_NAME @"MailCore OAuth 2.0 Token"

#define NUMBER_OF_MESSAGES_TO_LOAD		10
static NSString *mailCellIdentifier = @"MailCell";
static NSString *inboxInfoIdentifier = @"InboxStatusCell";

@interface FilterView ()
@property (nonatomic, strong) NSArray *messages;

@property (nonatomic, strong) MCOIMAPOperation *imapCheckOp;
@property (nonatomic, strong) MCOIMAPSession *imapSession;
@property (nonatomic, strong) MCOIMAPFetchMessagesOperation *imapMessagesFetchOp;


@property (nonatomic) NSInteger totalNumberOfInboxMessages;
@property (nonatomic) BOOL isLoading;
@property (nonatomic, strong) UIActivityIndicatorView *loadMoreActivityView;
@property (nonatomic, strong) NSMutableDictionary *messagePreviews;

@end

@implementation FilterView

- (id)init
{
  self = [super init];
  if (self) {
    [self setupView];
    [self startLogin];
  }
  return self;
}


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
      [self setupView];
      [self startLogin];
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
  NSLayoutConstraint *constraint;
  constraint = [NSLayoutConstraint
                constraintWithItem:filterNavigationView
                attribute: NSLayoutAttributeHeight
                relatedBy:NSLayoutRelationEqual
                toItem:filterNavigationView
                attribute:NSLayoutAttributeHeight
                multiplier:0
                constant:22];
  
  [self addConstraint:constraint];
  
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

- (void) startLogin
{
    KeychainItemWrapper *keychainItem = [[KeychainItemWrapper alloc] initWithIdentifier:@"UserLoginInfo" accessGroup:nil];

    
    NSString *username = [keychainItem objectForKey:(__bridge id)(kSecAttrAccount)];
	NSString *password = [keychainItem objectForKey:(__bridge id)(kSecAttrService)];
	NSString *hostname = @"imap.gmail.com";
  
  /* if (!username.length || !password.length) {
   [self performSelector:@selector(showSettingsViewController:) withObject:nil afterDelay:0.5];
   return;
   }*/
  
	[self loadAccountWithUsername:username password:password hostname:hostname oauth2Token:nil];
}

- (void)loadAccountWithUsername:(NSString *)username
                       password:(NSString *)password
                       hostname:(NSString *)hostname
                    oauth2Token:(NSString *)oauth2Token
{
	self.imapSession = [[MCOIMAPSession alloc] init];
	self.imapSession.hostname = hostname;
	self.imapSession.port = 993;
	self.imapSession.username = username;
	self.imapSession.password = password;
  if (oauth2Token != nil) {
    self.imapSession.OAuth2Token = oauth2Token;
    self.imapSession.authType = MCOAuthTypeXOAuth2;
  }
	self.imapSession.connectionType = MCOConnectionTypeTLS;
  FilterView * __weak weakSelf = self;
	self.imapSession.connectionLogger = ^(void * connectionID, MCOConnectionLogType type, NSData * data) {
    @synchronized(weakSelf) {
      if (type != MCOConnectionLogTypeSentPrivate) {
        //                NSLog(@"event logged:%p %i withData: %@", connectionID, type, [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
      }
    }
  };
	
	// Reset the inbox
	self.messages = nil;
	self.totalNumberOfInboxMessages = -1;
	self.isLoading = NO;
	self.messagePreviews = [NSMutableDictionary dictionary];
	[self.tableView reloadData];
  
	NSLog(@"checking account");
	self.imapCheckOp = [self.imapSession checkAccountOperation];
	[self.imapCheckOp start:^(NSError *error) {
		FilterView *strongSelf = weakSelf;
		NSLog(@"finished checking account.");
		if (error == nil) {
			[strongSelf loadLastNMessages:NUMBER_OF_MESSAGES_TO_LOAD];
		} else {
			NSLog(@"error loading account: %@", error);
		}
		
		strongSelf.imapCheckOp = nil;
	}];
}

- (void)loadLastNMessages:(NSUInteger)nMessages
{
	self.isLoading = YES;
	
	MCOIMAPMessagesRequestKind requestKind = (MCOIMAPMessagesRequestKind)
	(MCOIMAPMessagesRequestKindHeaders | MCOIMAPMessagesRequestKindStructure |
	 MCOIMAPMessagesRequestKindInternalDate | MCOIMAPMessagesRequestKindHeaderSubject |
	 MCOIMAPMessagesRequestKindFlags);
	
	NSString *inboxFolder = @"INBOX";
	MCOIMAPFolderInfoOperation *inboxFolderInfo = [self.imapSession folderInfoOperation:inboxFolder];
	
	[inboxFolderInfo start:^(NSError *error, MCOIMAPFolderInfo *info)
   {
     BOOL totalNumberOfMessagesDidChange =
     self.totalNumberOfInboxMessages != [info messageCount];
     
     self.totalNumberOfInboxMessages = [info messageCount];
     
     NSUInteger numberOfMessagesToLoad =
     MIN(self.totalNumberOfInboxMessages, nMessages);
     
     if (numberOfMessagesToLoad == 0)
     {
       self.isLoading = NO;
       return;
     }
     
     MCORange fetchRange;
     
     // If total number of messages did not change since last fetch,
     // assume nothing was deleted since our last fetch and just
     // fetch what we don't have
     if (!totalNumberOfMessagesDidChange && self.messages.count)
     {
       numberOfMessagesToLoad -= self.messages.count;
       
       fetchRange =
       MCORangeMake(self.totalNumberOfInboxMessages -
                    self.messages.count -
                    (numberOfMessagesToLoad - 1),
                    (numberOfMessagesToLoad - 1));
     }
     
     // Else just fetch the last N messages
     else
     {
       fetchRange =
       MCORangeMake(self.totalNumberOfInboxMessages -
                    (numberOfMessagesToLoad - 1),
                    (numberOfMessagesToLoad - 1));
     }
     
     self.imapMessagesFetchOp =
     [self.imapSession fetchMessagesByNumberOperationWithFolder:inboxFolder
                                                    requestKind:requestKind
                                                        numbers:
      [MCOIndexSet indexSetWithRange:fetchRange]];
     
     [self.imapMessagesFetchOp setProgress:^(unsigned int progress) {
       NSLog(@"Progress: %u of %lu", progress, (unsigned long)numberOfMessagesToLoad);
     }];
     
     __weak FilterView *weakSelf = self;
     [self.imapMessagesFetchOp start:
      ^(NSError *error, NSArray *messages, MCOIndexSet *vanishedMessages)
      {
        FilterView *strongSelf = weakSelf;
        NSLog(@"fetched all messages.");
        
        self.isLoading = NO;
        
        NSSortDescriptor *sort =
        [NSSortDescriptor sortDescriptorWithKey:@"header.date" ascending:NO];
        
        NSMutableArray *combinedMessages =
        [NSMutableArray arrayWithArray:messages];
        [combinedMessages addObjectsFromArray:strongSelf.messages];
        
        // TODO: remove the if statement. Primary is currently the same as the All Mail view.
        NSLog(@"Our funnl name: %@", _filterModel.filterTitle);
        if (![_filterModel.filterTitle isEqualToString: @"Primary"]) {
          NSSet *funnlEmailList = [FilterModel getEmailsForFunnl:_filterModel.filterTitle];
          for (int i = 0; i < [combinedMessages count]; i++) {
            MCOIMAPMessage *message = [combinedMessages objectAtIndex:i];
            MCOMessageHeader *header = [message header];
            NSString *emailAddress = [[header sender] mailbox];
            if (![funnlEmailList containsObject:emailAddress]) {
              [combinedMessages removeObjectAtIndex:i];
              // since we removed an element, all elements get pushed upwards by 1
              i --;
            }
          }
        }
        strongSelf.messages =
        [combinedMessages sortedArrayUsingDescriptors:@[sort]];
        [strongSelf.tableView reloadData];
      }];
   }];
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (section == 1)
	{
		if (self.totalNumberOfInboxMessages >= 0)
			return 1;
		
		return 0;
	}
	
	return self.messages.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	switch (indexPath.section)
	{
		case 0:
		{
			EmailCell *cell = [tableView dequeueReusableCellWithIdentifier:mailCellIdentifier forIndexPath:indexPath];
			MCOIMAPMessage *message = self.messages[indexPath.row];
			
			cell.textLabel.text = message.header.subject;
			
			NSString *uidKey = [NSString stringWithFormat:@"%d", message.uid];
			NSString *cachedPreview = self.messagePreviews[uidKey];
			
			if (cachedPreview)
			{
				cell.detailTextLabel.text = cachedPreview;
			}
			else
			{
				cell.messageRenderingOperation = [self.imapSession plainTextBodyRenderingOperationWithMessage:message
                                                                                               folder:@"INBOX"];
				
				[cell.messageRenderingOperation start:^(NSString * plainTextBodyString, NSError * error) {
					cell.detailTextLabel.text = plainTextBodyString;
					cell.messageRenderingOperation = nil;
					self.messagePreviews[uidKey] = plainTextBodyString;
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
			
			if (self.messages.count < self.totalNumberOfInboxMessages)
			{
				cell.textLabel.text =
				[NSString stringWithFormat:@"Load %lu more",
				 MIN(self.totalNumberOfInboxMessages - self.messages.count,
             NUMBER_OF_MESSAGES_TO_LOAD)];
			}
			else
			{
				cell.textLabel.text = nil;
			}
			
			cell.detailTextLabel.text =
			[NSString stringWithFormat:@"%ld message(s)",
			 (long)self.totalNumberOfInboxMessages];
			
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

/*- (void)showSettingsViewController:(id)sender {
 [self.imapMessagesFetchOp cancel];
 
 SettingsViewController *settingsViewController = [[SettingsViewController alloc] initWithNibName:nil bundle:nil];
 settingsViewController.delegate = self;
 UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:settingsViewController];
 [self presentViewController:nav animated:YES completion:nil];
 }
 */
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	switch (indexPath.section)
	{
		case 0:
		{
			MCOIMAPMessage *msg = self.messages[indexPath.row];
			MsgViewController *vc = [[MsgViewController alloc] init];
			vc.folder = @"INBOX";
			vc.message = msg;
			vc.session = self.imapSession;
			//[self.navigationController pushViewController:vc animated:YES];
			[self.mainVCdelegate pushViewController:vc];
      
			break;
		}
			
		case 1:
		{
			UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
			
			if (!self.isLoading &&
          self.messages.count < self.totalNumberOfInboxMessages)
			{
				[self loadLastNMessages:self.messages.count + NUMBER_OF_MESSAGES_TO_LOAD];
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

@end
