//
//  EmailService.m
//  FunnlMail
//
//  Created by Michael Raber on 3/30/14.
//  Copyright (c) 2014 FunnlMail. All rights reserved.
//

#import "EmailService.h"
#import "FilterModel.h"
#import "UIColor+HexString.h"
#import <mailcore/mailcore.h>
#import "KeychainItemWrapper.h"
#import "FilterView.h"


static EmailService *instance;

#define CLIENT_ID @"the-client-id"
#define CLIENT_SECRET @"the-client-secret"
#define KEYCHAIN_ITEM_NAME @"MailCore OAuth 2.0 Token"
#define NUMBER_OF_MESSAGES_TO_LOAD		10


@interface EmailService ()

@property (nonatomic) BOOL isLoading;
@property (nonatomic, strong) UIActivityIndicatorView *loadMoreActivityView;

@end

@implementation EmailService

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code
    }
    return self;
}

+ (void)initialize
{
    static BOOL initialized = NO;
    if(!initialized)
    {
        initialized = YES;
        instance = [[EmailService alloc] init];
    }
}

+(EmailService *)instance{
    return instance;
}

- (void) startLogin : (EmailsTableViewController *) fv
{
    KeychainItemWrapper *keychainItem = [[KeychainItemWrapper alloc] initWithIdentifier:@"UserLoginInfo" accessGroup:nil];
    
    NSString *username = [keychainItem objectForKey:(__bridge id)(kSecAttrAccount)];
	NSString *password = [keychainItem objectForKey:(__bridge id)(kSecAttrService)];
	NSString *hostname = @"imap.gmail.com";
    
    /* if (!username.length || !password.length) {
     [self performSelector:@selector(showSettingsViewController:) withObject:nil afterDelay:0.5];
     return;
     }*/
    
	[self loadAccountWithUsername:username password:password hostname:hostname oauth2Token:nil filterview: fv];
}

- (void)loadAccountWithUsername:(NSString *)username
                       password:(NSString *)password
                       hostname:(NSString *)hostname
                    oauth2Token:(NSString *)oauth2Token
                     filterview:(EmailsTableViewController *) fv
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
    EmailService * __weak weakSelf = self;
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
	[fv.tableView reloadData];
    
	NSLog(@"checking account");
	self.imapCheckOp = [self.imapSession checkAccountOperation];
	[self.imapCheckOp start:^(NSError *error) {
		EmailService *strongSelf = weakSelf;
		NSLog(@"finished checking account.");
		if (error == nil) {
			[strongSelf loadLastNMessages:NUMBER_OF_MESSAGES_TO_LOAD : fv];
		} else {
			NSLog(@"error loading account: %@", error);
		}
		
		strongSelf.imapCheckOp = nil;
	}];
    MCOIMAPFetchFoldersOperation *op = [self.imapSession fetchAllFoldersOperation];
    [op start:^(NSError * error, NSArray *folders) {
        for (MCOIMAPFolder *folder in folders) {
            NSLog(folder.path);
        }
    }];
    
}

- (void)loadLastNMessages:(NSUInteger)nMessages : (EmailsTableViewController *) fv
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
         
         __weak EmailService *weakSelf = self;
         [self.imapMessagesFetchOp start:
          ^(NSError *error, NSArray *messages, MCOIndexSet *vanishedMessages)
          {
              EmailService *strongSelf = weakSelf;
              NSLog(@"fetched all messages.");
              
              self.isLoading = NO;
              
              NSSortDescriptor *sort =
              [NSSortDescriptor sortDescriptorWithKey:@"header.date" ascending:NO];
              
              NSMutableArray *combinedMessages =
              [NSMutableArray arrayWithArray:messages];
              [combinedMessages addObjectsFromArray:self.messages];
              
              // TODO: remove the if statement. Primary is currently the same as the All Mail view.
              //NSLog(@"Our funnl name: %@", _filterModel.filterTitle);
              /*if (![_filterModel.filterTitle isEqualToString: @"Primary"]) {
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
               }*/
              
              /*for (int i = 0; i < [combinedMessages count]; i++) {
               MCOIMAPMessage *message = [combinedMessages objectAtIndex:i];
               NSLog(@"here2");
               NSLog([[message.gmailLabels objectAtIndex:0] class]);
               for (NSString *label in message.gmailLabels) {
               NSLog(label);
               }
               }*/
              self.messages =
              [combinedMessages sortedArrayUsingDescriptors:@[sort]];
              [fv.tableView reloadData];
              
              // TODO: figure out how to return the messages back to the FunnlMail view
          }];
     }];
}


+(NSArray *) currentFilters{
    NSMutableArray *filterArray = [[NSMutableArray alloc]init];
    
    //
    // Hardcoded, should come from the data store (i.e. sqlite)
    //
    
    //
    // created inital hardcoded list of filters
    //
    [filterArray addObject:[[FilterModel alloc]initWithBarColor:[UIColor colorWithHexString:@"#2EB82E"] filterTitle:@"Primary" newMessageCount:16 dateOfLastMessage:[NSDate new]]];
    [filterArray addObject:[[FilterModel alloc]initWithBarColor:[UIColor colorWithHexString:@"#FF85FF"] filterTitle:@"Meetings" newMessageCount:5 dateOfLastMessage:[NSDate new]]];
    [filterArray addObject:[[FilterModel alloc]initWithBarColor:[UIColor colorWithHexString:@"#FFB84D"] filterTitle:@"Files" newMessageCount:24 dateOfLastMessage:[NSDate new]]];
    [filterArray addObject:[[FilterModel alloc]initWithBarColor:[UIColor colorWithHexString:@"#AD5CFF"] filterTitle:@"Payments" newMessageCount:6 dateOfLastMessage:[NSDate new]]];
    [filterArray addObject:[[FilterModel alloc]initWithBarColor:[UIColor colorWithHexString:@"#33ADFF"] filterTitle:@"FunnlMail" newMessageCount:24 dateOfLastMessage:[NSDate new]]];
    //[filterArray addObject:[[FilterModel alloc]initWithBarColor:[UIColor colorWithHexString:@"#33ADFF"] filterTitle:@"Travel" newMessageCount:24 dateOfLastMessage:[NSDate new]]];
    [filterArray addObject:[[FilterModel alloc]initWithBarColor:[UIColor colorWithHexString:@"#85E085"] filterTitle:@"News" newMessageCount:12 dateOfLastMessage:[NSDate new]]];
    [filterArray addObject:[[FilterModel alloc]initWithBarColor:[UIColor colorWithHexString:@"#B84D70"] filterTitle:@"Forums" newMessageCount:5 dateOfLastMessage:[NSDate new]]];
    
    return filterArray;
}

@end
