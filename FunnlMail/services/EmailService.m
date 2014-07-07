//
//  EmailService.m
//  FunnlMail
//
//  Created by Michael Raber on 3/30/14.
//  Copyright (c) 2014 FunnlMail. All rights reserved.
//

#import "EmailService.h"
#import "FunnelModel.h"
#import "UIColor+HexString.h"
#import <mailcore/mailcore.h>
#import "KeychainItemWrapper.h"
#import "EMailsTableViewController.h"
#import "SQLiteDatabase.h"
#import "FMDatabase.h"
#import "EmailServersService.h"

static EmailService *instance;

static NSMutableArray *filterArray = nil;
static FunnelModel *defaultFilter;
static NSString *currentFolder;
@interface EmailService ()

@property (nonatomic) BOOL isLoading;
@property (nonatomic, strong) UIActivityIndicatorView *loadMoreActivityView;

@end

@implementation EmailService

@synthesize filterArray;

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
    self.sentMessages = [[NSMutableArray alloc] init];
    self.threadIdDictionary = [[NSMutableDictionary alloc] init];
	self.totalNumberOfInboxMessages = -1;
	self.isLoading = NO;
	self.messagePreviews = [NSMutableDictionary dictionary];
    self.filterMessagePreviews = [NSMutableDictionary dictionary];
    self.sentMessagePreviews = [NSMutableDictionary dictionary];
    [EmailService instance].filterMessages = (NSMutableArray*)[[MessageService instance] retrieveAllMessages];
    if ([EmailService instance].filterMessages.count == 0) {
        AppDelegate *tempAppDelegate = APPDELEGATE;
        if ([tempAppDelegate.currentFunnelString isEqualToString:@"all"]) {
            [fv.tableView reloadData];
        }
        else {
            self.filterMessages = (NSMutableArray*)[[MessageService instance] messagesWithFunnelId:tempAppDelegate.currentFunnelDS.funnelId top:2000];
            [fv.tableView reloadData];
        }
    }
	NSLog(@"checking account");
	self.imapCheckOp = [self.imapSession checkAccountOperation];
	[self.imapCheckOp start:^(NSError *error) {
		EmailService *strongSelf = weakSelf;
		NSLog(@"finished checking account.");
		if (error == nil) {
            //newly added by iauro001 on 13th June 2014
//            [EmailService instance].filterMessages = (NSMutableArray*)[[MessageService instance] retrieveAllMessages];
//            NSLog(@"[EmailService loadAccountWithUsername] -- [EmailService instance].filterMessages %d",[EmailService instance].filterMessages.count);
//            if ([EmailService instance].filterMessages.count == 0) {
//                //dowmloading from server
//                
//            }
//            else
//            {
////                [fv.tableView reloadData];
//            }
            [self performSelectorInBackground:@selector(sampleFunctionWithObject:) withObject:fv];
//            [strongSelf loadLastNMessages:_filterMessages.count + NUMBER_OF_MESSAGES_TO_LOAD withTableController:fv withFolder:@"INBOX"];
		} else {
			NSLog(@"error loading account: %@", error);
		}
		
		strongSelf.imapCheckOp = nil;
	}];
    MCOIMAPFetchFoldersOperation *op = [self.imapSession fetchAllFoldersOperation];
    [op start:^(NSError * error, NSArray *folders) {
//        for (MCOIMAPFolder *folder in folders) {
//            NSLog(folder.path);
//        }
    }];
    
}

//function to be called in background
- (void)sampleFunctionWithObject:(EmailsTableViewController*)fv
{
//    [[EmailService instance] loadLastNMessages:_filterMessages.count + NUMBER_OF_MESSAGES_TO_LOAD withTableController:fv withFolder:@"INBOX"];
    [[EmailService instance] loadLatestMail:1 withTableController:fv withFolder:INBOX];
}

- (void)loadLastNMessages:(NSUInteger)nMessages  withTableController:(EmailsTableViewController *)fv withFolder:(NSString*)folderName
{
    __block EmailsTableViewController *emailTableViewController = fv;
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
         
//         __weak EmailService *weakSelf = self;
         [self.imapMessagesFetchOp start:
          ^(NSError *error, NSArray *messages, MCOIndexSet *vanishedMessages)
          {
              AppDelegate *tempAppDelegate = APPDELEGATE;
              [tempAppDelegate.progressHUD setHidden:YES];
              [tempAppDelegate.progressHUD show:NO];
              [fv.tablecontroller.refreshControl endRefreshing];
              //newly added by iauro001 on 12th June 2014
              [self insertMessage:messages];
              //retrieving the message from database
              NSArray *tempArray = [[MessageService instance] retrieveAllMessages];
              [self performSelector:@selector(applyingFilters:) withObject:tempArray];
              _filterMessages = (NSMutableArray*)tempArray;
              if ([tempAppDelegate.currentFunnelString isEqualToString:@"all"]) {
                  [emailTableViewController.tableView reloadData];
              }
              else {
                  self.filterMessages = (NSMutableArray*)[[MessageService instance] messagesWithFunnelId:tempAppDelegate.currentFunnelDS.funnelId top:2000];
                  [fv.tableView reloadData];
                  
              }
              [tempAppDelegate.progressHUD show:NO];
              [fv.activityIndicator stopAnimating];
              if (tempArray.count > kNUMBER_OF_MESSAGES_TO_DOWNLOAD_IN_BACKGROUND) {
            
              }
              else
              {
                  [self loadLastNMessages:self.filterMessages.count + NUMBER_OF_MESSAGES_TO_LOAD withTableController:fv withFolder:INBOX];
              }
          }];
     }];
}

//loading latest mail
#pragma mark -
#pragma mark loadLatestMail
- (void)loadLatestMail:(NSUInteger)nMessages  withTableController:(EmailsTableViewController *)fv withFolder:(NSString*)folderName
{
//	self.isLoading = YES;
	
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
//             self.isLoading = NO;
             return;
         }
         
         MCORange fetchRange;
         if (!totalNumberOfMessagesDidChange && self.messages.count)
         {
             numberOfMessagesToLoad -= self.messages.count;
             
             fetchRange =
             MCORangeMake(self.totalNumberOfInboxMessages - self.messages.count - (numberOfMessagesToLoad - 1),
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
         
         [self.imapMessagesFetchOp start:^(NSError *error, NSArray *messages, MCOIndexSet *vanishedMessages)
          {
              if (messages.count > 0) {
                  MCOIMAPMessage *tempVariable = [messages objectAtIndex:0];
                  NSArray *tempArray = [[MessageService instance] retrieveLatestMessages];
                  if (tempArray.count > 0) {
                      if ([[tempArray objectAtIndex:0] integerValue] < tempVariable.uid) {
                          [self loadLastNMessages:tempVariable.uid - [[tempArray objectAtIndex:0] integerValue]withTableController:fv withFolder:INBOX];
                      }
                      else
                      {
                          AppDelegate *tempAppDelegate = APPDELEGATE;
                          [tempAppDelegate.progressHUD show:NO];
                          [tempAppDelegate.progressHUD setHidden:YES];
                          [fv.tablecontroller.refreshControl endRefreshing];
                          if (self.filterMessages.count > kNUMBER_OF_MESSAGES_TO_DOWNLOAD_IN_BACKGROUND) {
                              AppDelegate*tempAppDelegate = APPDELEGATE;
                              [tempAppDelegate.progressHUD show:NO];
                              [fv.activityIndicator stopAnimating];
                          }
                          else{
                              [self loadLastNMessages:self.filterMessages.count + NUMBER_OF_MESSAGES_TO_LOAD withTableController:fv withFolder:INBOX];
                          }
                      }
                  }
                  else
                  {
                      [self loadLastNMessages:NUMBER_OF_MESSAGES_TO_LOAD withTableController:fv withFolder:INBOX];
                  }
              }
          }];
     }];
}

- (BOOL)checkForKey:(NSString *)key indict:(NSMutableDictionary*)dict {
    NSArray *keys = dict.allKeys;
    for (NSString *key1 in keys) {
        if ([key1 isEqualToString:key])
            return FALSE;
    }
    return TRUE;
}

#pragma mark insertIntoDictionary
- (NSMutableDictionary*)insertIntoDictionary:(NSMutableDictionary*)dict funnel:(FunnelModel*)funnel {
    if (!dict) {
        dict = [[NSMutableDictionary alloc] init];
    }
    NSMutableDictionary *temp = [[NSMutableDictionary alloc] initWithDictionary:dict];
    NSString *key = funnel.funnelName;
    if ([self checkForKey:key indict:dict]) {
        temp[key] = funnel.funnelColor;
    }
    dict = temp;
    temp = nil;
    return dict;
}

//storing messages according to funnels preasent.
#pragma mark -
#pragma mark applyingFilters
- (void)applyingFilters:(NSArray*)messages
{
    NSArray *funnels = [[FunnelService instance] allFunnels];
    if (funnels.count == 1) {
        return;
    }
    for (FunnelModel *tempFunnelModel in funnels) {
        for (int count = 0; count < messages.count; count++) {
            MCOIMAPMessage *message = [MCOIMAPMessage importSerializable:[(MessageModel*)[messages objectAtIndex:count] messageJSON]];
            if ([self checkForFunnel:tempFunnelModel forMessage:message]) {
                NSString *funnelID = tempFunnelModel.funnelId;
                NSString *messageID = [NSString stringWithFormat:@"%d",message.uid];
                NSString *funnelJsonString = [(MessageModel*)[messages objectAtIndex:count] funnelJson];
                NSError *error = nil;
                NSMutableDictionary *tempDict = (NSMutableDictionary*)[NSJSONSerialization JSONObjectWithData:[funnelJsonString dataUsingEncoding:NSUTF8StringEncoding]
                                                                                options: NSJSONReadingAllowFragments
                                                                                  error: &error];
                if (!error) {
                    tempDict = [self insertIntoDictionary:tempDict funnel:tempFunnelModel];
                }
                else {
                    tempDict = [[NSMutableDictionary alloc] init];
                    tempDict[tempFunnelModel.funnelName] = tempFunnelModel.funnelColor;
                }
                [(MessageModel*)[messages objectAtIndex:count] setFunnelJson:[self getJsonStringByDictionary:(NSDictionary*)tempDict]];
                [[MessageService instance] updateMessage:(MessageModel*)[messages objectAtIndex:count]];
                [[MessageFilterXRefService instance] insertMessageXRefMessageID:messageID funnelId:funnelID];
            }
        }
    }
    funnels = nil;
}

-(NSString*)getJsonStringByDictionary:(NSDictionary*)dictionary{
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

- (void)applyingFunnel:(FunnelModel*)funnel toMessages:(NSArray*)messages
{
    for (int count = 0; count < messages.count; count++) {
        MCOIMAPMessage *message = [MCOIMAPMessage importSerializable:[(MessageModel*)[messages objectAtIndex:count] messageJSON]];
//        NSLog(@"MessageID : %d",message.uid);
        if ([self checkForFunnel:funnel forMessage:message]) {
            NSString *funnelID = funnel.funnelId;
            NSString *messageID = [NSString stringWithFormat:@"%d",message.uid];
            if (funnel.skipFlag) {
                MessageModel *temp = (MessageModel*)[messages objectAtIndex:count];
                temp.skipFlag = temp.skipFlag + 1;
            }
            NSString *funnelJsonString = [(MessageModel*)[messages objectAtIndex:count] funnelJson];
            NSError *error = nil;
            NSMutableDictionary *tempDict = [NSJSONSerialization JSONObjectWithData:[funnelJsonString dataUsingEncoding:NSUTF8StringEncoding]
                                                                            options: NSJSONReadingAllowFragments
                                                                              error: &error];
            if (!error) {
                tempDict = [self insertIntoDictionary:tempDict funnel:funnel];
            } else {
                tempDict = [[NSMutableDictionary alloc] init];
                tempDict[funnel.funnelName] = funnel.funnelColor;
            }
//            NSLog(@"----%@",[self getJsonStringByDictionary:(NSDictionary*)tempDict]);
            [(MessageModel*)[messages objectAtIndex:count] setFunnelJson:[self getJsonStringByDictionary:(NSDictionary*)tempDict]];
            [[MessageService instance] updateMessage:(MessageModel*)[messages objectAtIndex:count]];
            [[MessageFilterXRefService instance] insertMessageXRefMessageID:messageID funnelId:funnelID];
        }
    }
}

#pragma mark -
#pragma mark checkForFilter
- (BOOL)checkForFunnel:(FunnelModel*)funnel forMessage:(MCOIMAPMessage*)message
{
    MCOMessageHeader *header = [message header];
    for (NSString *senderEmailID in funnel.sendersArray) {
        if ([senderEmailID.lowercaseString isEqualToString:[[[header sender] mailbox] lowercaseString]]) {
            return TRUE;
        }
    }
    if ([funnel.funnelName.lowercaseString isEqualToString:@"all"]) {
        
    }
    else {
        for (NSString *phrase in funnel.subjectsArray) {
            if ([[[header subject] lowercaseString] rangeOfString:phrase.lowercaseString].location == NSNotFound) {
                
            } else {
                return TRUE;
            }
        }
    }
    return FALSE;
}

//insert's message in to the database
#pragma mark -
#pragma mark insertMessage
- (void)insertMessage:(NSArray*)messages
{
    for (MCOIMAPMessage *m in messages) {
        MessageModel *tempMessageModel = [[MessageModel alloc] init];
        tempMessageModel.read = m.flags;
        tempMessageModel.date = m.header.date;
        tempMessageModel.messageID = [NSString stringWithFormat:@"%d",m.uid];
        tempMessageModel.messageJSON = [m serializable];
        tempMessageModel.gmailThreadID = [NSString stringWithFormat:@"%llu",m.gmailThreadID];
        tempMessageModel.skipFlag = 0;
        [[MessageService instance] insertMessage:tempMessageModel];
        tempMessageModel = nil;
    }
}

#pragma mark -
#pragma mark filterAlgotithm:
//currently not in use
- (void)filterAlgotithm:(NSArray*)messages withTableController:(EmailsTableViewController *)fv
{
    self.isLoading = NO;
    NSSortDescriptor *sort =
    [NSSortDescriptor sortDescriptorWithKey:@"header.date" ascending:NO];
    NSArray *subjectFoundArray = [NSArray array];
    
    [self.messages removeAllObjects];
    
    for (MCOIMAPMessage *m in messages) {
        //
        // add mail to internal array
        //
        
        [self.messages addObject:m];
        
        //
        // store message in database
        //
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"gmailMessageID == %qx ", m.gmailThreadID,m.gmailMessageID];
        NSArray *b = [self.messages filteredArrayUsingPredicate:predicate];
        if(b.count){
            
        }else{
            NSString *gmailThreadIDStr = [NSString stringWithFormat:@"%qx",m.gmailThreadID];
            NSMutableSet *threadMessagesArray = [self.threadIdDictionary objectForKey:gmailThreadIDStr];
            if(threadMessagesArray == nil ){
                threadMessagesArray = [[NSMutableSet alloc] init];
                [threadMessagesArray addObject:m];
                [self.threadIdDictionary setObject:threadMessagesArray forKey:gmailThreadIDStr];
            }
            else{
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"gmailThreadID == %qx AND uid != %d ", m.gmailThreadID,m.uid];
                NSArray *b = [self.messages filteredArrayUsingPredicate:predicate];
                [self.messages removeObjectsInArray:b];
                [threadMessagesArray addObject:m];
                [self.threadIdDictionary setObject:threadMessagesArray forKey:gmailThreadIDStr];
            }
        }
    }
    NSMutableArray *combinedMessages = [NSMutableArray arrayWithArray:self.messages];
    // TODO: remove the if statement. Primary is currently the same as the All Mail view.
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
                }
            }else{
                [combinedMessages removeObjectAtIndex:i];
                // since we removed an element, all elements get pushed upwards by 1
                i --;
            }
        }
        self.filterMessages = [[NSMutableArray alloc] initWithArray:[combinedMessages sortedArrayUsingDescriptors:@[sort]]];
    }
    else{
        self.filterMessages = [[NSMutableArray alloc] initWithArray:[combinedMessages sortedArrayUsingDescriptors:@[sort]]];
    }
    AppDelegate *tempAppDelegate = APPDELEGATE;
    if ([tempAppDelegate.currentFunnelString isEqualToString:@"all"]) {
        [fv.tableView reloadData];
    }
    {
        self.filterMessages = (NSMutableArray*)[[MessageService instance] messagesWithFunnelId:tempAppDelegate.currentFunnelDS.funnelId top:2000];
        [fv.tableView reloadData];
    }
}

+(void)setNewFilterModel:(FunnelModel*)model{
    [filterArray addObject:model];
}

+(void)editFilter:(FunnelModel*)model withOldFilter:(FunnelModel*)oldFilter{
  NSInteger index = [filterArray indexOfObject:oldFilter];
  [filterArray replaceObjectAtIndex:index withObject:model];
}

+(void)editFilterWith:(FunnelModel*)model withOldFilter:(int)oldFilter{
//    NSInteger index = [filterArray indexOfObject:oldFilter];
    [filterArray replaceObjectAtIndex:oldFilter withObject:model];
}

+(void)deleteFilter:(FunnelModel*)oldFilter{
  NSInteger index = [filterArray indexOfObject:oldFilter];
  [filterArray removeObjectAtIndex:index];
}

+(FunnelModel*)getDefaultFilter{
  return defaultFilter;
}


+(void)addInitialFilter{
    
  defaultFilter = [[FunnelModel alloc]initWithBarColor:[UIColor colorWithHexString:@"#2EB82E"] filterTitle:@"All" newMessageCount:16 dateOfLastMessage:[NSDate new]];
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

-(void) saveMessageInDatabase:(MCOIMAPMessage *)message{
//  __block NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
  
  /*
   
  dict[@"messageID"] = message.header.messageID;
  dict[@"date"] = message.header.date;
  dict[@"receivedDate"] = message.header.receivedDate;
  dict[@"sender"] = message.header.sender;
  dict[@"from"] = message.header.from;
  dict[@"to"] = message.header.to;
  dict[@"cc"] = message.header.cc==nil ? @"" : message.header.cc;
  dict[@"bcc"] = message.header.bcc ==nil ? @"" : message.header.bcc;
  dict[@"replyTo"] = message.header.replyTo ==nil ? @"" : message.header.replyTo;
  dict[@"subject"] = message.header.subject ==nil ? @"" : message.header.subject;
  
  NSLog(@"dict: %@", dict);

  [[SQLiteDatabase sharedInstance].databaseQueue inDatabase:^(FMDatabase *db) {
    [db executeUpdate:@"INSERT INTO boxlyCell (messageID,date,receivedDate,sender,from,to,cc,bcc,replyTo,subject) VALUES (:messageID,:date,:receivedDate,:sender,:from,:to,:cc,:bcc,:replyTo,:subject)" withParameterDictionary:dict];
  }];
   
   */
  
  //[[[SQLiteDatabase sharedInstance] databaseQueue] inDatabase:^(FMDatabase *dbInstance) {
  //  [db executeUpdate:@"INSERT INTO boxlyCell (messageID,date,receivedDate,sender,from,to,cc,bcc,replyTo,subject) VALUES (:messageID,:date,:receivedDate,:sender,:from,:to,:cc,:bcc,:replyTo,:subject)" withParameterDictionary:dict];
  //}
}

@end
