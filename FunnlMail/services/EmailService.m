
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
#import "LoginViewController.h"
#import "MainVC.h"
#import "RNBlurModalView.h"
#import "MTStatusBarOverlay.h"

static EmailService *instance;

static NSMutableArray *filterArray = nil;
static FunnelModel *defaultFilter;
static NSString *currentFolder;
@interface EmailService ()

@property (nonatomic) BOOL isLoading;
@property (nonatomic, strong) UIActivityIndicatorView *loadMoreActivityView;

@end

@implementation EmailService

@synthesize filterArray,emailsTableViewController;

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
    emailsTableViewController = fv;
    [self loadAccountWithUsername:username password:password hostname:hostname oauth2Token:nil filterview: fv withBackgroundActivity:NO];
}

- (void)loadAccountWithUsername:(NSString *)username
                       password:(NSString *)password
                       hostname:(NSString *)hostname
                    oauth2Token:(NSString *)oauth2Token
                     filterview:(EmailsTableViewController *) fv withBackgroundActivity:(BOOL)isBackground
{
    NSLog(@"***************** In loadAccountWithUsername ***************** ");

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
    self.primaryMessages = [[NSMutableArray alloc] init];
    
	self.totalNumberOfMessages = -1;
	self.isLoading = NO;
	self.messagePreviews = [NSMutableDictionary dictionary];
    self.filterMessagePreviews = [NSMutableDictionary dictionary];
    self.sentMessagePreviews = [NSMutableDictionary dictionary];
   
    [EmailService instance].filterMessages = (NSMutableArray*)[[MessageService instance] retrieveAllMessages];
    if ([EmailService instance].filterMessages.count > 0) {
        AppDelegate *tempAppDelegate = APPDELEGATE;
        if(tempAppDelegate.currentSelectedFunnlModel){
            if ([[tempAppDelegate.currentSelectedFunnlModel.funnelName.lowercaseString lowercaseString] isEqualToString:[ALL_FUNNL lowercaseString]]) {
                //self.filterMessages = (NSMutableArray*)[[MessageService instance] retrieveAllMessages];
            }
            else if ([[tempAppDelegate.currentSelectedFunnlModel.funnelName.lowercaseString lowercaseString] isEqualToString:[ALL_OTHER_FUNNL lowercaseString]]) {
                self.filterMessages = (NSMutableArray*)[[MessageService instance] retrieveOtherMessagesThanPrimary];
            }
            else{
                self.filterMessages = (NSMutableArray*)[[MessageService instance] messagesWithFunnelId:tempAppDelegate.currentSelectedFunnlModel.funnelId top:2000];
            }
            
        }
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [fv.tableView reloadData];
    });

	
    NSLog(@"checking account");
	self.imapCheckOp = [self.imapSession checkAccountOperation];
    [self.imapSession disconnectOperation];
	[self.imapCheckOp start:^(NSError *error) {
		EmailService *strongSelf = weakSelf;
		NSLog(@"finished checking account.");
		if (error == nil) {
            //[self performSelectorInBackground:@selector(checkMailsAtStart:) withObject:fv];
            [self performSelector:@selector(checkMailsAtStart:) withObject:fv afterDelay:0.3];
		} else {
			NSLog(@"error loading account: %@", error);
		}
		
		strongSelf.imapCheckOp = nil;
	}];
}

-(void)clearData{
    self.messages = [[NSMutableArray alloc] init];
    self.filterMessages = [[NSMutableArray alloc] init];
    self.sentMessages = [[NSMutableArray alloc] init];
    self.threadIdDictionary = [[NSMutableDictionary alloc] init];
    self.primaryMessages = [[NSMutableArray alloc] init];
    
	self.totalNumberOfMessages = -1;
	self.isLoading = NO;
	self.messagePreviews = [NSMutableDictionary dictionary];
    self.filterMessagePreviews = [NSMutableDictionary dictionary];
    self.sentMessagePreviews = [NSMutableDictionary dictionary];
    
//    [EmailService instance].filterMessages = (NSMutableArray*)[[MessageService instance] retrieveAllMessages];
//    [emailsTableViewController.tableView reloadData];
}

//function to be called in background
- (void)checkMailsAtStart:(EmailsTableViewController*)fv
{
    NSLog(@"-----checkMailsAtStart-----");
    [[EmailService instance] loadLatestMail:NUMBER_OF_NEW_MESSAGES_TO_CHECK withTableController:fv withFolder:INBOX];
}

-(void)syncMessages{
    u_int64_t modSeqValue = UINT64_MAX;

    NSString *modSeqString = [[NSUserDefaults standardUserDefaults] objectForKey:@"MODSEQ"];
    if(modSeqString.length <= 0){
        NSArray *dataArray = [[MessageService instance] messagesWithTop:1];
        if(dataArray.count){
            MCOIMAPMessage *tempMessage = [dataArray objectAtIndex:0];
            modSeqValue = tempMessage.modSeqValue;
            NSLog(@"******* From DB: Highest modSeqValue: %llu ",modSeqValue);
        }
    }
    else{
        modSeqValue=[modSeqString longLongValue];
        NSLog(@"------ ******* From Defaults: Highest modSeqValue: %llu ",modSeqValue);

    }
    
    MCOIndexSet* mcoIndexSet = [MCOIndexSet indexSetWithRange:MCORangeMake(1, UINT64_MAX - 2)];
    MCOIMAPMessagesRequestKind requestKind = (MCOIMAPMessagesRequestKind)
	(MCOIMAPMessagesRequestKindUid | MCOIMAPMessagesRequestKindHeaders | MCOIMAPMessagesRequestKindStructure |
	 MCOIMAPMessagesRequestKindInternalDate | MCOIMAPMessagesRequestKindHeaderSubject | MCOIMAPMessagesRequestKindGmailThreadID | MCOIMAPMessagesRequestKindGmailMessageID |	 MCOIMAPMessagesRequestKindFlags);

    MCOIMAPFetchMessagesOperation *syncMessagesFetchOperation =  [[EmailService instance].imapSession syncMessagesByUIDWithFolder:INBOX requestKind:requestKind uids:mcoIndexSet modSeq:modSeqValue];
    [syncMessagesFetchOperation setProgress:^(unsigned int progress) {
        NSLog(@"Sync INBOX ---- Progress: %u ", progress);
    }];
    
    //         __weak EmailService *weakSelf = self;
    NSLog(@"--- start Sync - INBOX fetch operation for mail download");
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [syncMessagesFetchOperation start:^(NSError *error, NSArray *messages, MCOIndexSet *vanishedMessages)
         {
             NSInteger count = 0;
             for (MCOIMAPMessage *m in messages) {
                 MessageModel *tempMessageModel = [[MessageModel alloc] init];
                 tempMessageModel.read = m.flags;
                 tempMessageModel.date = m.header.date;
                 tempMessageModel.messageID = [NSString stringWithFormat:@"%d",m.uid];
                 tempMessageModel.messageJSON = [m serializable];
                 tempMessageModel.gmailThreadID = [NSString stringWithFormat:@"%llu",m.gmailThreadID];
                 BOOL success = [[MessageService instance] updateMessageMetaInfo:tempMessageModel];
                 if(messages.count == count){
                     [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%llu",m.modSeqValue] forKey:@"MODSEQ"];
                     [[NSUserDefaults standardUserDefaults] synchronize];
                 }
                 count++;
             }
             if(count){
                 NSLog(@"INBOX --- added or modified messages: %@", messages);
                 NSLog(@"INBOX --- deleted messages: %@", vanishedMessages);
                 [self refreshMessages];
             }
         }];
    });
    
    
    MCOIMAPFetchMessagesOperation *trashSyncMessagesFetchOperation =  [[EmailService instance].imapSession syncMessagesByUIDWithFolder:TRASH requestKind:requestKind uids:mcoIndexSet modSeq:modSeqValue];
    [trashSyncMessagesFetchOperation setProgress:^(unsigned int progress) {
        NSLog(@"Sync Trash --- Progress: %u ", progress);
    }];
    
    //         __weak EmailService *weakSelf = self;
    NSLog(@"--- start Sync - DELETE fetch operation for mail download");
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [trashSyncMessagesFetchOperation start:^(NSError *error, NSArray *messages, MCOIndexSet *vanishedMessages)
         {
             NSInteger count = 0;
             for (MCOIMAPMessage *m in messages) {
                 NSString *gmailMessageID = [NSString stringWithFormat:@"%llu",m.gmailMessageID];
                 BOOL success = [[MessageService instance] deleteMessageWithGmailMessageID:gmailMessageID];
                 if(messages.count == count){
                     [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%llu",m.modSeqValue] forKey:@"MODSEQ"];
                     [[NSUserDefaults standardUserDefaults] synchronize];
                 }
                 count++;
             }
             if(count){
                 NSLog(@"TRASH ----- added or modified messages: %@", messages);
                 NSLog(@"TRASH ----- deleted messages: %@", vanishedMessages);
                 [self refreshMessages];
             }
         }];
    });
}

-(void)refreshMessages{
    
    NSArray *tempArray;
    AppDelegate *tempAppDelegate = APPDELEGATE;
    if ([[tempAppDelegate.currentFunnelString.lowercaseString lowercaseString] isEqualToString:[ALL_FUNNL lowercaseString]]) {
        tempArray = [[MessageService instance] retrieveAllMessages];
    }
    else if ([[tempAppDelegate.currentFunnelString.lowercaseString lowercaseString] isEqualToString:[ALL_OTHER_FUNNL lowercaseString]]) {
        tempArray = [[MessageService instance] retrieveOtherMessagesThanPrimary];
    }
    else{
        tempArray = [[MessageService instance] retrieveAllMessages];
    }
    self.filterMessages = (NSMutableArray*)tempArray;
//    dispatch_async(dispatch_get_main_queue(), ^(void){
        [self.emailsTableViewController.tableView reloadData];
//    });
}

-(void)getDatabaseMessages:(NSString*)folderName withTableController:(EmailsTableViewController *)emailsTableViewController{
    __block EmailsTableViewController *emailTableViewController = emailsTableViewController;
    emailTableViewController->searchMessages = (NSMutableArray*)[[MessageService instance] retrieveMessages:folderName];
    emailTableViewController.emailFolder = folderName;
    emailTableViewController.isSearching = YES;
    if(emailTableViewController->searchMessages.count)[emailsTableViewController.tableView reloadData];
    
}


- (void)loadLastNMessages:(NSUInteger)nMessages withTableController:(EmailsTableViewController *)fv withFolder:(NSString*)folderName withFetchRange:(MCORange)newFetchRange
{
     emailsTableViewController = fv;
    AppDelegate *appDelegate = APPDELEGATE;
//    if(fv == nil){
//        emailsTableViewController = tempAppDelegate.loginViewController.mainViewController.emailsTableViewController;
//    }else{
//        emailsTableViewController  = fv;
//    }
    
	self.isLoading = YES;
    
	MCOIMAPMessagesRequestKind requestKind = (MCOIMAPMessagesRequestKind)
	(MCOIMAPMessagesRequestKindUid | MCOIMAPMessagesRequestKindHeaders | MCOIMAPMessagesRequestKindStructure |
	 MCOIMAPMessagesRequestKindInternalDate | MCOIMAPMessagesRequestKindHeaderSubject | MCOIMAPMessagesRequestKindGmailThreadID | MCOIMAPMessagesRequestKindGmailMessageID |	 MCOIMAPMessagesRequestKindFlags | MCOIMAPMessagesRequestKindGmailLabels);
	
    MCOIMAPFolderInfoOperation *FolderInfo;
    NSArray *dbBoolArray = [[NSArray alloc]initWithObjects:@"-1",nil];
    if([folderName isEqualToString:INBOX]){
        FolderInfo = [self.imapSession folderInfoOperation:INBOX];
        emailsTableViewController.navigationItem.title = ALL_FUNNL;
        [MBProgressHUD hideAllHUDsForView:appDelegate.window animated:YES];
    }
    else if([folderName isEqualToString:SENT]){
        FolderInfo = [self.imapSession folderInfoOperation:SENT];
        dbBoolArray = [[MessageService instance] retrieveNewestMessage:SENT];
    }
    else if([folderName isEqualToString:TRASH]){
        FolderInfo = [self.imapSession folderInfoOperation:TRASH];
        dbBoolArray = [[MessageService instance] retrieveNewestMessage:TRASH];
    }
    else if ([folderName isEqualToString:DRAFTS]){
        FolderInfo = [self.imapSession folderInfoOperation:DRAFTS];
        dbBoolArray = [[MessageService instance] retrieveNewestMessage:DRAFTS];
    }
    else if([folderName isEqualToString:ARCHIVE]){
        FolderInfo = [self.imapSession folderInfoOperation:ARCHIVE];
        dbBoolArray = [[MessageService instance] retrieveNewestMessage:ARCHIVE];
    }
    
    NSInteger newestID;
    if(dbBoolArray.count) newestID = [[dbBoolArray objectAtIndex:0] integerValue];
    else newestID = 0;
    [FolderInfo start:^(NSError *error, MCOIMAPFolderInfo *info)
     {
         isfetchingOperationActive = YES;
//         BOOL totalNumberOfMessagesDidChange = self.totalNumberOfMessages != info.uidNext;        
         
         BOOL isNewMessage = NO;
         __block u_int64_t oldestMessageID = 0;
         MCORange fetchRange;
         int64_t startRange, endRange;
         int64_t numberOfMessagesToLoad;
         if(nMessages == -1){
             fetchRange = newFetchRange;
             numberOfMessagesToLoad = fetchRange.length - fetchRange.location ;
             if(numberOfMessagesToLoad < 0){
                 numberOfMessagesToLoad = -numberOfMessagesToLoad;
             }
             NSLog(@"New Messages to fetch: %qu - %qu = %qu",fetchRange.location, fetchRange.length, numberOfMessagesToLoad);
             isNewMessage = YES;
         }
         else{
             isNewMessage = NO;
             NSArray *tempArray = [[MessageService instance] retrieveOldestMessages];
             if(tempArray.count){
                 oldestMessageID = [[tempArray objectAtIndex:0] integerValue];
             }
             
             self.totalNumberOfMessages = info.uidNext;
             if(oldestMessageID){
                 if(oldestMessageID < nMessages){
                     startRange = 1;
                     endRange = oldestMessageID;
                 }
                 else{
                     startRange = oldestMessageID-nMessages;
                     endRange = oldestMessageID;
                 }
             }
             else{
                 if(self.totalNumberOfMessages < nMessages){
                     startRange = 1;
                     endRange = self.totalNumberOfMessages;
                 }
                 else{
                     startRange = self.totalNumberOfMessages - nMessages;
                     endRange = self.totalNumberOfMessages;
                 }
             }
             fetchRange = MCORangeMake(startRange,endRange);
             numberOfMessagesToLoad = fetchRange.length - fetchRange.location ;
             if(numberOfMessagesToLoad < 0){
                 numberOfMessagesToLoad = -numberOfMessagesToLoad;
             }
             NSLog(@"Old messages to fetch: %qu - %qu = %qu",fetchRange.location, fetchRange.length, numberOfMessagesToLoad);
         }
         
         if(nMessages == -1){
             fetchRange = newFetchRange;
         }
         
         //u_int64_t numberOfMessagesToLoad = fetchRange.length - fetchRange.location ;
         if (numberOfMessagesToLoad == 0)
         {
             self.isLoading = NO;
             if(nMessages == -1){
                 NSLog(@"------ Failed loading NEW messages (numberOfMessagesToLoad == 0) ------ ");
             }
             else{
                 NSLog(@"------ Failed loading OLD messages (numberOfMessagesToLoad == 0) ------ ");
             }
             //return;
         }
         MCOIndexSet *uids = [MCOIndexSet indexSetWithRange:fetchRange];

         
         
         int numberOfMessages = 40;
         MCOIndexSet *numbers = [MCOIndexSet indexSetWithRange:MCORangeMake(1, info.uidNext)];
         
         if(![folderName isEqualToString:INBOX] && ![folderName isEqualToString:ARCHIVE]){
             self.imapMessagesFetchOp = [self.imapSession fetchMessagesByUIDOperationWithFolder:folderName requestKind:requestKind uids:numbers];
             NSLog(@"detected other mailbox");
         }
         else if([folderName isEqualToString:ARCHIVE])
             self.imapMessagesFetchOp = [self.imapSession fetchMessagesByNumberOperationWithFolder:folderName requestKind:requestKind numbers:[MCOIndexSet indexSetWithRange:MCORangeMake(1,40)]];
         else{
             self.imapMessagesFetchOp = [self.imapSession fetchMessagesByUIDOperationWithFolder:folderName requestKind:requestKind uids:uids];
             NSLog(@"inbox detected");
         }
         
//         uint64_t location = info.uidNext;
//         uint64_t size = fetchRange.location;
//         MCOIndexSet *numbers = [MCOIndexSet indexSetWithRange:MCORangeMake(location, size)];
//         self.imapMessagesFetchOp = [self.imapSession fetchMessagesByNumberOperationWithFolder:folderName requestKind:requestKind numbers:numbers];
         

         [self.imapMessagesFetchOp setProgress:^(unsigned int progress) {
             NSLog(@"Main -- Progress: %u of %lu", progress, (unsigned long)numberOfMessagesToLoad);
         }];
         
         //         __weak EmailService *weakSelf = self;
         NSLog(@"--- start asyc fetch operation for mail download");
         //dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
             [self.imapMessagesFetchOp start:^(NSError *error, NSArray *messages, MCOIndexSet *vanishedMessages)
             {
                  NSLog(@"-- received %lu message in fetch opreation",(unsigned long)messages.count);
                  
                  
                  dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                      
                      NSArray *funnels = [[FunnelService instance] getFunnelsExceptAllFunnel];
                      NSMutableArray *messageModelArray = [[NSMutableArray alloc] init];
                      for (MCOIMAPMessage *m in messages) {
                          MessageModel *tempMessageModel = [[MessageModel alloc] init];
                          tempMessageModel.read = m.flags;
                          tempMessageModel.date = m.header.date;
                          tempMessageModel.messageID = [NSString stringWithFormat:@"%d",m.uid];
                          tempMessageModel.messageJSON = [m serializable];
                          tempMessageModel.gmailMessageID = [NSString stringWithFormat:@"%llu",m.gmailMessageID];
                          tempMessageModel.gmailThreadID = [NSString stringWithFormat:@"%llu",m.gmailThreadID];
                          tempMessageModel.skipFlag = 0;
                          if([folderName isEqualToString:SENT]) tempMessageModel.categoryName = SENT;
                          else if([folderName isEqualToString:TRASH]) tempMessageModel.categoryName = TRASH;
                          else if([folderName isEqualToString:DRAFTS]) tempMessageModel.categoryName = DRAFTS;
                          else tempMessageModel.categoryName = @"";
                          //NSLog(@"uid: %u modseqValue: %llu ",m.uid,m.modSeqValue);
                          //NSLog(@"gmailLabels: %@",m.gmailLabels.description);
                          
                          
                          for (FunnelModel *tempFunnelModel in funnels)
                          {
                              
                              if(oldestMessageID == 0){
                                  
                              }
                              else if(isNewMessage == NO && [tempMessageModel.messageID intValue] < oldestMessageID){
                                    //OLD - run below funnling logic
                              }
                              else if (isNewMessage == YES && [tempMessageModel.messageID intValue] > oldestMessageID){
                                  //NEW - run below funnling logic
                              }
                              else{
                                  continue;
                              }
                              
                              
                              MCOIMAPMessage *message = [MCOIMAPMessage importSerializable:[tempMessageModel messageJSON]];
                              if([message.header.subject isEqual:NULL] || [message.header.subject isEqualToString:@""] || [message.header.subject isEqualToString:@"(no subject)"]){
                                  NSLog(@"Empty subject in --> Applying Filters");
                              }
                              if ([self checkForFunnel:tempFunnelModel forMessage:message]) {
                                  NSString *funnelID = tempFunnelModel.funnelId;
                                  NSString *messageID = [NSString stringWithFormat:@"%d",message.uid];
                                  if (tempFunnelModel.skipFlag) {
                                      tempMessageModel.skipFlag = tempMessageModel.skipFlag + 1;
                                  }
                                  NSString *funnelJsonString = [tempMessageModel funnelJson];
                                  NSMutableDictionary *tempDict;
                                  if(funnelJsonString){
                                      NSError *error = nil;
                                      tempDict = (NSMutableDictionary*)[NSJSONSerialization JSONObjectWithData:[funnelJsonString dataUsingEncoding:NSUTF8StringEncoding] options: NSJSONReadingAllowFragments error: &error];
                                      if (!error) {
                                          tempDict = [self insertIntoDictionary:tempDict funnel:tempFunnelModel];
                                      }
                                      else {
                                          tempDict = [[NSMutableDictionary alloc] init];
                                          tempDict[tempFunnelModel.funnelName] = tempFunnelModel.funnelColor;
                                      }
                                      NSString *jsonString = [self getJsonStringByDictionary:(NSDictionary*)tempDict];
                                      [tempMessageModel setFunnelJson:jsonString];
                                  }
                                  else{
                                      tempDict = [[NSMutableDictionary alloc] init];
                                      tempDict[tempFunnelModel.funnelName] = tempFunnelModel.funnelColor;
                                      NSString *jsonString = [self getJsonStringByDictionary:(NSDictionary*)tempDict];
                                      [tempMessageModel setFunnelJson:jsonString];
                                  }
                                  [[MessageFilterXRefService instance] insertMessageXRefMessageID:messageID funnelId:funnelID];
                              }
                        }
                          
                          /// Getting Only primary messages over here.
                          if(SHOW_PRIMARY_INBOX){
                              NSString *gmailMessageID =  [NSString stringWithFormat:@"%qx", m.gmailMessageID];
                              //NSLog(@"%@",gmailMessageID);
                              NSMutableArray *primaryArray = [[EmailService instance] primaryMessages];
                              NSPredicate *p = [NSPredicate predicateWithFormat:@"SELF matches[c] %@", gmailMessageID];
                              NSArray *b = [primaryArray filteredArrayUsingPredicate:p];
                              
                              if(b.count){
                                  tempMessageModel.categoryName = PRIMARY_CATEGORY_NAME;
                              }
                              else if([folderName isEqualToString:SENT])tempMessageModel.categoryName = SENT;
                              else if([folderName isEqualToString:TRASH]) tempMessageModel.categoryName = TRASH;
                              else if([folderName isEqualToString:DRAFTS]) tempMessageModel.categoryName = DRAFTS;
                              else tempMessageModel.categoryName = @"";

                          }
                          
                          if(oldestMessageID == 0){
                              [messageModelArray addObject:tempMessageModel];
                          }
                          else if(isNewMessage == NO && [tempMessageModel.messageID intValue] < oldestMessageID){
                              //Old messages insert logic
                              //NSLog(@"OLD --- %@",tempMessageModel.messageID);
                              [messageModelArray addObject:tempMessageModel];
                              //[[MessageService instance] insertMessage:tempMessageModel];
                          }
                          else if (isNewMessage == YES  && [tempMessageModel.messageID intValue] > oldestMessageID){
                              //New messages insert logic
                              //NSLog(@"NEW --- %@",tempMessageModel.messageID);
                              [messageModelArray addObject:tempMessageModel];
                              //[[MessageService instance] insertMessage:tempMessageModel];
                          }
                          
                          tempMessageModel = nil;
                      }
                      [[MessageService instance] insertBulkMessages:messageModelArray];

                      NSLog(@"***** insert %lu message to db",(unsigned long)messages.count);
        
                      

                      
                      //retrieving the message from database
                      NSArray *tempArray;
                      AppDelegate *tempAppDelegate = APPDELEGATE;
                      if ([[tempAppDelegate.currentFunnelString.lowercaseString lowercaseString] isEqualToString:[ALL_FUNNL lowercaseString]]) {
                          tempArray = [[MessageService instance] retrieveAllMessages];
                      }
                      else if ([[tempAppDelegate.currentFunnelString.lowercaseString lowercaseString] isEqualToString:[ALL_OTHER_FUNNL lowercaseString]]) {
                          tempArray = [[MessageService instance] retrieveOtherMessagesThanPrimary];
                      }
                      else{
                          //tempArray = [[MessageService instance] retrieveAllMessages];
                      }

                      
                      //[self performSelector:@selector(applyingFilters:) withObject:tempArray];
                      [self applyingFilters:tempArray];
                      self.filterMessages = (NSMutableArray*)tempArray;
                      if(![folderName isEqualToString:SENT] && ![folderName isEqualToString:TRASH])
                          emailsTableViewController.navigationItem.title = ALL_FUNNL;
                      if ([folderName isEqualToString:SENT])
                      {
                          
                          if (tempArray.count) {
                              emailsTableViewController -> searchMessages = (NSMutableArray*)tempArray;
                          }
                          else{
                              [self setMessages:messages withTableController:emailsTableViewController];
                          
                              //not sure if this my (Pranav) email alone but sent messages were intially backwards
                              //my inbox still shows up out of order with no pattern noticeable
                              //might be just me
                              emailsTableViewController->searchMessages = [NSMutableArray arrayWithArray:[[emailsTableViewController->searchMessages reverseObjectEnumerator] allObjects]];
                          }
                          
                          
                          emailsTableViewController.emailFolder = SENT;
                          emailsTableViewController.isSearching = YES;
                          NSLog(@"does it crash here?");
                          emailsTableViewController.navigationItem.title = @"Sent";
                      }
                      else if ([folderName isEqualToString:TRASH])
                      {
                          [self setMessages:messages withTableController:emailsTableViewController];
                          //not sure if this my (Pranav) email alone but sent messages were intially backwards
                          //my inbox still shows up out of order with no pattern noticeable
                          //might be just me
                         emailsTableViewController->searchMessages = [NSMutableArray arrayWithArray:[[emailsTableViewController->searchMessages reverseObjectEnumerator] allObjects]];
                          emailsTableViewController.emailFolder = TRASH;
                          emailsTableViewController.isSearching = YES;
                          NSLog(@"does it crash here?");
                          emailsTableViewController.navigationItem.title = @"Trash";
                          
                      }
                      else if ([folderName isEqualToString:DRAFTS])
                      {
                          [self setMessages:messages withTableController:emailsTableViewController];
                          //not sure if this my (Pranav) email alone but sent messages were intially backwards
                          //my inbox still shows up out of order with no pattern noticeable
                          //might be just me
                          emailsTableViewController->searchMessages = [NSMutableArray arrayWithArray:[[emailsTableViewController->searchMessages reverseObjectEnumerator] allObjects]];
                          emailsTableViewController.emailFolder = DRAFTS;
                          emailsTableViewController.isSearching = YES;
                          NSLog(@"does it crash here?");
                          emailsTableViewController.navigationItem.title = @"DRAFTS";
                          
                      }
                      else if ([folderName isEqualToString:ARCHIVE])
                      {
                          [self setMessages:messages withTableController:emailsTableViewController];
                          //not sure if this my (Pranav) email alone but sent messages were intially backwards
                          //my inbox still shows up out of order with no pattern noticeable
                          //might be just me
                          emailsTableViewController->searchMessages = [NSMutableArray arrayWithArray:[[emailsTableViewController->searchMessages reverseObjectEnumerator] allObjects]];
                          emailsTableViewController.emailFolder = ARCHIVE;
                          emailsTableViewController.isSearching = YES;
                          NSLog(@"does it crash here?");
                      }
                      else if ([[tempAppDelegate.currentFunnelString lowercaseString] isEqualToString:[ALL_FUNNL lowercaseString]] || [[tempAppDelegate.currentFunnelString lowercaseString] isEqualToString:[ALL_OTHER_FUNNL lowercaseString]]) {
                          //NSLog(@"when does this happen");
                          //                          emailTableViewController.emailFolder = INBOX;
//                          [emailTableViewController.tableView reloadData];
                      }
                      else {
                          if(tempAppDelegate.currentFunnelDS)
                              self.filterMessages = (NSMutableArray*)[[MessageService instance] messagesWithFunnelId:tempAppDelegate.currentFunnelDS.funnelId top:2000];
                          else
                              NSLog(@"app crash fixed");
                      }
                      [tempAppDelegate.progressHUD setHidden:YES];
                      [tempAppDelegate.progressHUD show:NO];
                      [fv.tablecontroller.refreshControl endRefreshing];
                      dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
                          if (tempArray.count < kNUMBER_OF_MESSAGES_TO_DOWNLOAD_IN_BACKGROUND) {
                              
                          }
                      });
                      
                      dispatch_async(dispatch_get_main_queue(), ^(void){
                          isfetchingOperationActive = NO;
                          AppDelegate *tempAppDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
                          [tempAppDelegate hideWelcomeOverlay:nil];
                          [fv.tableView reloadData];
                          [fv.tablecontroller.refreshControl endRefreshing];
                          [tempAppDelegate.progressHUD setHidden:YES];
                          [tempAppDelegate.progressHUD show:NO];
                          [fv.activityIndicator stopAnimating];

                          if([folderName isEqualToString:SENT]  || [folderName isEqualToString:TRASH] || [folderName isEqualToString:DRAFTS] || [folderName isEqualToString:ARCHIVE]){
                              [MBProgressHUD hideAllHUDsForView:appDelegate.window animated:YES];
                          }
                      });
                  });
              }];
         //});
     }];
}

-(void) setMessages:(NSArray *)messages withTableController:(EmailsTableViewController *)fv{
    fv->searchMessages = [[NSMutableArray alloc]init];
    for (MCOIMAPMessage *m in messages) {
        MessageModel *tempMessageModel = [[MessageModel alloc] init];
        tempMessageModel.read = m.flags;
        tempMessageModel.date = m.header.date;
        tempMessageModel.messageID = [NSString stringWithFormat:@"%d",m.uid];
        tempMessageModel.messageJSON = [m serializable];
        tempMessageModel.gmailThreadID = [NSString stringWithFormat:@"%llu",m.gmailThreadID];
        [fv->searchMessages addObject:tempMessageModel];
        tempMessageModel = nil;
    }
}

-(void)getNewMessages:(NSString*)emailStr nextPageToken:(NSString*)nextPage numberOfMaxResult:(NSInteger)maxResult withFolder:(NSString*)folderName withFetchRange:(MCORange)newFetchRange{
    NSString *newAPIStr = @"";
    
    if(nextPage.length){
        newAPIStr = [NSString stringWithFormat:@"https://www.googleapis.com/gmail/v1/users/%@/messages?pageToken=%@&labelIds=CATEGORY_PERSONAL&maxResults=%d",emailStr,nextPage,maxResult];
    }
    else{
        newAPIStr = [NSString stringWithFormat:@"https://www.googleapis.com/gmail/v1/users/%@/messages?fields=messages(id,labelIds,threadId),nextPageToken&labelIds=CATEGORY_PERSONAL&maxResults=%d",emailStr,maxResult];
    }
    
    NSURL *url = [NSURL URLWithString:newAPIStr];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPMethod:@"GET"];
    
    GTMOAuth2Authentication *currentAuth = [GTMOAuth2ViewControllerTouch authForGoogleFromKeychainForName:kKeychainItemName clientID:kMyClientID clientSecret:kMyClientSecret];
    GTMHTTPFetcher* myFetcher = [GTMHTTPFetcher fetcherWithRequest:request];
    [myFetcher setAuthorizer:currentAuth];
    [myFetcher beginFetchWithCompletionHandler:^(NSData *retrievedData, NSError *error) {
        if (error != nil) {
            // status code or network error
            //NSLog(@"--Message info error %@: ", [error description]);
        } else {
            // succeeded
            //            NSString* newStr = [[NSString alloc] initWithData:retrievedData encoding:NSUTF8StringEncoding];
            //            NSLog(@"Message Info: %@",newStr);
            NSDictionary* json = [NSJSONSerialization JSONObjectWithData:retrievedData options:kNilOptions error:&error];
            NSArray* messageArray =[json objectForKey:@"messages"];
            NSString *nextPageToken = [json objectForKey:@"nextPageToken"];
            for (NSDictionary *dictionary in messageArray) {
                [[EmailService instance].primaryMessages addObject:[dictionary objectForKey:@"id"]];
            }
            [self loadLastNMessages:-1 withTableController:emailsTableViewController withFolder:folderName withFetchRange:newFetchRange];

            NSMutableArray *pArray = [[EmailService instance] primaryMessages];
            [[NSUserDefaults standardUserDefaults] setObject:pArray forKey: ALL_FUNNL];
//            [[NSUserDefaults standardUserDefaults] setObject:nextPageToken forKey:@"PRIMARY_PAGE_TOKEN"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
        }
    }];
}


//loading latest mail
#pragma mark -
#pragma mark loadLatestMail
- (void)loadLatestMail:(NSUInteger)nMessages withTableController:(EmailsTableViewController *)fv withFolder:(NSString*)folderName
{
    if(isfetchingOperationActive){
        NSLog(@"=== øøøøøøøøøøø ==");
        if(IS_AUTO_REFRESH_ENABLE){
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(startAutoRefresh) object:nil];
            [self performSelector:@selector(startAutoRefresh) withObject:nil afterDelay:AUTOREFRESH_DELAY];
        }
        return;
    }
    else{
        NSLog(@"√√√√√ sync");
    }
    
    //	self.isLoading = YES;
    if(self.imapSession == nil)
        return;
    
    [self.imapSession cancelAllOperations];
    NSString *inboxFolder = folderName;
    if(self.imapSession == nil){
        NSLog(@"********** session expired ********** ");
    }
    MCOIMAPFolderInfoOperation *inboxFolderInfo = [self.imapSession folderInfoOperation:inboxFolder];
    if(inboxFolderInfo == nil ){
        NSLog(@"********** inboxFolderInfo not found ********** ");
    }
    
	[inboxFolderInfo start:^(NSError *error, MCOIMAPFolderInfo *info)
     {
         MTStatusBarOverlay *overlay = [MTStatusBarOverlay sharedInstance];
         if(error != nil){
             
             NSLog(@"******* ERROR: %@ for folderinfo: %@ ********",error.description,inboxFolder);
         }
         self.totalNumberOfMessages = info.uidNext-1;
         if(self.totalNumberOfMessages == 4294967295){
                NSLog(@"..........Here its freezing for new messages.......");
             self.totalNumberOfMessages = 1;
         }
         NSLog(@"---- Last Info: %llu",self.totalNumberOfMessages);
         NSArray *tempArray = [[MessageService instance] retrieveLatestMessages];
         if(tempArray.count <=0)
         {
             NSLog(@"Call to loadLastNMessages from loadLatestMail function");
             [self loadLastNMessages:NUMBER_OF_MESSAGES_TO_LOAD_AT_START withTableController:fv withFolder:inboxFolder  withFetchRange:MCORangeEmpty];
         }
         else{
             [self syncMessages];
             u_int64_t inDatabaseMessageID = [[tempArray objectAtIndex:0] integerValue];
             if(inDatabaseMessageID){
                 inDatabaseMessageID = inDatabaseMessageID ;
             }
             
             NSInteger numberOfMessagesToLoad = (NSInteger)((self.totalNumberOfMessages) - inDatabaseMessageID);
             
             if(numberOfMessagesToLoad <= 0){
             }
             
             MCORange fetchRange;
             fetchRange = MCORangeMake(inDatabaseMessageID,self.totalNumberOfMessages);
             if(numberOfMessagesToLoad){
                 overlay.progress = 0.5;
                 NSLog(@"checking new messages:  Range: %qu - %qu",fetchRange.location, fetchRange.length);
                 [self getNewMessages:[EmailService instance].userEmailID nextPageToken:0 numberOfMaxResult:numberOfMessagesToLoad + 10 withFolder:inboxFolder withFetchRange:fetchRange];
                 if(overlay.tag == 1){
                     overlay.progress = 1;
                     [overlay postImmediateFinishMessage:@"Finished Downloading" duration:2.0 animated:YES];
                     overlay.tag = 0;
                 }
             }
             else{
                 if(overlay.tag == 1){
                     overlay.progress = 1;
                     [overlay postImmediateFinishMessage:@"No new emails" duration:2.0 animated:YES];
                     overlay.tag = 0;
                 }
                 NSLog(@"No New Message Found:  LastMessageIDSynced: %llu",self.totalNumberOfMessages);
                 AppDelegate *tempAppDelegate = APPDELEGATE;
                 [tempAppDelegate.progressHUD show:NO];
                 [tempAppDelegate.progressHUD setHidden:YES];
                 [fv.tablecontroller.refreshControl endRefreshing];
             }
         }
       
         
         if(IS_AUTO_REFRESH_ENABLE){
             [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(startAutoRefresh) object:nil];
             [self performSelector:@selector(startAutoRefresh) withObject:nil afterDelay:AUTOREFRESH_DELAY];
         }
      }];

}

-(void)startAutoRefresh{
    [self loadLatestMail:NUMBER_OF_NEW_MESSAGES_TO_CHECK withTableController:emailsTableViewController withFolder:INBOX];
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
            if([message.header.subject isEqual:NULL] || [message.header.subject isEqualToString:@""] || [message.header.subject isEqualToString:@"(no subject)"]){
                NSLog(@"Empty subject in --> Applying Filters");
            }
            if ([self checkForFunnel:tempFunnelModel forMessage:message]) {
                NSString *funnelID = tempFunnelModel.funnelId;
                NSString *messageID = [NSString stringWithFormat:@"%d",message.uid];
                if (tempFunnelModel.skipFlag) {
                    MessageModel *temp = (MessageModel*)[messages objectAtIndex:count];
                    temp.skipFlag = temp.skipFlag + 1;
                }
                NSString *funnelJsonString = [(MessageModel*)[messages objectAtIndex:count] funnelJson];
                NSError *error = nil;
                NSMutableDictionary *tempDict = (NSMutableDictionary*)[NSJSONSerialization JSONObjectWithData:[funnelJsonString dataUsingEncoding:NSUTF8StringEncoding] options: NSJSONReadingAllowFragments error: &error];
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
            NSMutableDictionary *tempDict;
            if(funnelJsonString){
                NSError *error = nil;
                
                tempDict = [NSJSONSerialization JSONObjectWithData:[funnelJsonString dataUsingEncoding:NSUTF8StringEncoding]
                                                                                options: NSJSONReadingAllowFragments
                                                                                  error: &error];
                if (!error) {
                    tempDict = [self insertIntoDictionary:tempDict funnel:funnel];
                } else {
                    tempDict = [[NSMutableDictionary alloc] init];
                    tempDict[funnel.funnelName] = funnel.funnelColor;
                }
            }
            else{
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
        MCOAddress *emailAddress = message.header.from;
        NSString *messageSenderID = [[emailAddress mailbox] lowercaseString];
        if ([senderEmailID.lowercaseString isEqualToString:messageSenderID]) {
            return TRUE;
        }
    }
    if ([[funnel.funnelName lowercaseString] isEqualToString:[ALL_FUNNL lowercaseString]] || [[funnel.funnelName lowercaseString] isEqualToString:[ALL_OTHER_FUNNL lowercaseString]]) {
        
    }
    else {
        for (NSString *phrase in funnel.subjectsArray) {
            if(header.subject.length){
                if ([[[header subject] lowercaseString] rangeOfString:phrase.lowercaseString].location == NSNotFound) {
                    
                } else {
                    return TRUE;
                }
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
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSMutableArray *messageModelArray = [[NSMutableArray alloc] init];
        for (MCOIMAPMessage *m in messages) {
            MessageModel *tempMessageModel = [[MessageModel alloc] init];
            tempMessageModel.read = m.flags;
            tempMessageModel.date = m.header.date;
            tempMessageModel.messageID = [NSString stringWithFormat:@"%d",m.uid];
            tempMessageModel.gmailMessageID = [NSString stringWithFormat:@"%llu",m.gmailMessageID];
            tempMessageModel.messageJSON = [m serializable];
            tempMessageModel.gmailThreadID = [NSString stringWithFormat:@"%llu",m.gmailThreadID];
            tempMessageModel.skipFlag = 0;
            [messageModelArray addObject:tempMessageModel];
            //        [[MessageService instance] insertMessage:tempMessageModel];
            tempMessageModel = nil;
        }
        [[MessageService instance] insertBulkMessages:messageModelArray];
    });
    
}

#pragma mark -
#pragma mark filterAlgotithm:


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
    defaultFilter = [[FunnelModel alloc]initWithBarColor:[UIColor colorWithHexString:@"#F9F9F9"] filterTitle:ALL_FUNNL newMessageCount:16 dateOfLastMessage:[NSDate new]];
    [filterArray addObject:defaultFilter];
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
