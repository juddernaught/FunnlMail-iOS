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
#import "EMailsTableViewController.h"

static EmailService *instance;

static NSMutableArray *filterArray = nil;
static FilterModel *defaultFilter;
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
        filterArray = [[NSMutableArray alloc] init];
        [self addInitialFilter];
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
	//self.imapSession = [[MCOIMAPSession alloc] init];
	self.imapSession.hostname = hostname;
	self.imapSession.port = 993;
	//self.imapSession.username = username;
	//self.imapSession.password = password;
    //if (oauth2Token != nil) {
    //    self.imapSession.OAuth2Token = oauth2Token;
    //    self.imapSession.authType = MCOAuthTypeXOAuth2;
    //}*/
	
    // Dan asks: WHAT DOES THE BELOW LINE MEAN???
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
	self.messages = [[NSMutableArray alloc] init];
    self.filterMessages = [[NSMutableArray alloc] init];
    self.threadIdDictionary = [[NSMutableDictionary alloc] init];
	self.totalNumberOfInboxMessages = -1;
	self.isLoading = NO;
	self.messagePreviews = [NSMutableDictionary dictionary];
    self.filterMessagePreviews = [NSMutableDictionary dictionary];
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
	 MCOIMAPMessagesRequestKindInternalDate | MCOIMAPMessagesRequestKindHeaderSubject | MCOIMAPMessagesRequestKindGmailThreadID | MCOIMAPMessagesRequestKindGmailMessageID |	 MCOIMAPMessagesRequestKindFlags);
	
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
              NSArray *subjectFoundArray = [NSArray array];

              for (MCOIMAPMessage *m in messages) {
                  NSPredicate *predicate = [NSPredicate predicateWithFormat:@"gmailMessageID == %qx ", m.gmailThreadID,m.gmailMessageID];
                  NSArray *b = [self.messages filteredArrayUsingPredicate:predicate];
                  if(b.count){
                      //NSLog(@"%@",m.header.subject);
                  }else{
                      //NSLog(@"ThreadID: %qx, UID: %d mID: %qx",m.gmailThreadID, m.uid, m.gmailMessageID);
                      
                      NSString *gmailThreadIDStr = [NSString stringWithFormat:@"%qx",m.gmailThreadID];
                      NSMutableSet *threadMessagesArray = [self.threadIdDictionary objectForKey:gmailThreadIDStr];
                      if(threadMessagesArray == nil ){
                          threadMessagesArray = [[NSMutableSet alloc] init];
                          [threadMessagesArray addObject:m];
                          [self.messages addObject:m];
                          [self.threadIdDictionary setObject:threadMessagesArray forKey:gmailThreadIDStr];
                      }
                      else{
                          NSPredicate *predicate = [NSPredicate predicateWithFormat:@"gmailThreadID == %qx AND uid != %d ", m.gmailThreadID,m.uid];
                          NSArray *b = [self.messages filteredArrayUsingPredicate:predicate];
                          [self.messages removeObjectsInArray:b];
                          [self.messages addObject:m];
                          [threadMessagesArray addObject:m];
                          [self.threadIdDictionary setObject:threadMessagesArray forKey:gmailThreadIDStr];
                      }
                  }
//                  NSLog(@"%@: %@ : %d", m.header.sender.mailbox, m.header.subject, threadMessagesArray.count);
              }
              NSMutableArray *combinedMessages = [NSMutableArray arrayWithArray:self.messages];
              // TODO: remove the if statement. Primary is currently the same as the All Mail view.
              NSLog(@"Our funnl name: %@ ---> %d", fv.filterModel.filterTitle,self.messages.count);
              if (fv.filterModel && ![fv.filterModel.filterTitle isEqual:NULL] && ![fv.filterModel.filterTitle isEqualToString: @"All"] ) {
                NSMutableDictionary *dictionary = [fv.filterModel getEmailsForFunnl:fv.filterModel.filterTitle];
                NSSet *funnlEmailList = [dictionary objectForKey:@"senders"];
                NSMutableSet *funnlSubjectList =  [NSMutableSet setWithArray:[dictionary objectForKey:@"subjects"]];
                for (int i = 0; i < [combinedMessages count]; i++) {
                   MCOIMAPMessage *message = [combinedMessages objectAtIndex:i];
                   MCOMessageHeader *header = [message header];
                   NSString *emailAddress = [[[header sender] mailbox] lowercaseString];
                   NSString *subject = [[header subject] lowercaseString];
                    
                  if ([funnlEmailList containsObject:emailAddress] )
                   {
                     if(funnlSubjectList.count){
                       NSMutableSet *intersection = [NSMutableSet setWithArray:[subject componentsSeparatedByString:@" "]];
                       NSMutableSet *set = [NSMutableSet setWithSet:funnlSubjectList];
                       [set intersectSet:intersection];
                       subjectFoundArray =  [set allObjects];
                       //NSLog(@"%@ : %d %@",subject,subjectFoundArray.count,emailAddress);
                       if(subjectFoundArray.count == 0){
                         [combinedMessages removeObjectAtIndex:i];
                         i--;
                       }
                     }
                   }else{
                     [combinedMessages removeObjectAtIndex:i];
                     // since we removed an element, all elements get pushed upwards by 1
                     i --;
                   }
                }
                self.filterMessages = (NSMutableArray*)[combinedMessages sortedArrayUsingDescriptors:@[sort]];
               }
              else{
                self.filterMessages = (NSMutableArray*)[combinedMessages sortedArrayUsingDescriptors:@[sort]];;
              }
              [fv.tableView reloadData];
          }];
     }];
}

+(void)setNewFilterModel:(FilterModel*)model{
    [filterArray addObject:model];
}

+(void)editFilter:(FilterModel*)model withOldFilter:(FilterModel*)oldFilter{
  NSInteger index = [filterArray indexOfObject:oldFilter];
  [filterArray replaceObjectAtIndex:index withObject:model];
}

+(void)deleteFilter:(FilterModel*)oldFilter{
  NSInteger index = [filterArray indexOfObject:oldFilter];
  [filterArray removeObjectAtIndex:index];
}

+(FilterModel*)getDefaultFilter{
  return defaultFilter;
}


+(void)addInitialFilter{
  defaultFilter = [[FilterModel alloc]initWithBarColor:[UIColor colorWithHexString:@"#2EB82E"] filterTitle:@"All" newMessageCount:16 dateOfLastMessage:[NSDate new]];
  [filterArray addObject:defaultFilter];
  
//    [filterArray addObject:[[FilterModel alloc]initWithBarColor:[UIColor colorWithHexString:@"#FF85FF"] filterTitle:@"Meetings" newMessageCount:5 dateOfLastMessage:[NSDate new]]];
//    [filterArray addObject:[[FilterModel alloc]initWithBarColor:[UIColor colorWithHexString:@"#FFB84D"] filterTitle:@"Files" newMessageCount:24 dateOfLastMessage:[NSDate new]]];
//    [filterArray addObject:[[FilterModel alloc]initWithBarColor:[UIColor colorWithHexString:@"#AD5CFF"] filterTitle:@"Payments" newMessageCount:6 dateOfLastMessage:[NSDate new]]];
//    [filterArray addObject:[[FilterModel alloc]initWithBarColor:[UIColor colorWithHexString:@"#33ADFF"] filterTitle:@"FunnlMail" newMessageCount:24 dateOfLastMessage:[NSDate new]]];
//    //[filterArray addObject:[[FilterModel alloc]initWithBarColor:[UIColor colorWithHexString:@"#33ADFF"] filterTitle:@"Travel" newMessageCount:24 dateOfLastMessage:[NSDate new]]];
//    [filterArray addObject:[[FilterModel alloc]initWithBarColor:[UIColor colorWithHexString:@"#85E085"] filterTitle:@"News" newMessageCount:12 dateOfLastMessage:[NSDate new]]];
//    [filterArray addObject:[[FilterModel alloc]initWithBarColor:[UIColor colorWithHexString:@"#B84D70"] filterTitle:@"Forums" newMessageCount:5 dateOfLastMessage:[NSDate new]]];
}

+(NSArray *) getCurrentFilters{
    //
    // Hardcoded, should come from the data store (i.e. sqlite)
    //
    
    //
    // created inital hardcoded list of filters
    //
    return filterArray;
}

@end
