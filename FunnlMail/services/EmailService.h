//
//  EmailService.h
//  FunnlMail
//
//  Created by Michael Raber on 3/30/14.
//  Copyright (c) 2014 FunnlMail. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EmailsTableViewController.h"
#import <mailcore/mailcore.h>
#import "MessageService.h"
#import "MessageModel.h"
#import "FunnelService.h"
#import "MessageFilterXRefService.h"

@interface EmailService : NSObject{
//    NSMutableArray *filterArray;
}
@property (nonatomic, strong) NSMutableArray *filterArray;
@property (nonatomic, strong) MCOIMAPOperation *imapCheckOp;
@property (nonatomic, strong) MCOIMAPSession *imapSession;
@property (nonatomic, strong) MCOSMTPSession *smtpSession;
@property (nonatomic, strong) MCOIMAPFetchMessagesOperation *imapMessagesFetchOp;
@property (nonatomic) NSInteger totalNumberOfMessages;
@property (nonatomic, strong) NSMutableDictionary *threadIdDictionary;
@property (nonatomic, strong) NSMutableArray *messages;
@property (nonatomic, strong) NSMutableDictionary *messagePreviews;
@property (nonatomic, strong) NSMutableArray *filterMessages;
@property (nonatomic, strong) NSMutableDictionary *filterMessagePreviews;
@property (nonatomic, strong) NSMutableArray *sentMessages;
@property (nonatomic, strong) NSMutableDictionary *sentMessagePreviews;
@property (nonatomic, strong) NSMutableArray *primaryMessages;
@property (nonatomic, strong) NSString *userEmailID,*userImageURL;
@property (nonatomic, strong) EmailsTableViewController *emailsTableViewController;
+(EmailService *)instance;
+(NSArray *) getCurrentFilters;
+(void)setNewFilterModel:(FunnelModel*)model;
+(void)editFilter:(FunnelModel*)model withOldFilter:(FunnelModel*)oldFilter;
+(void)deleteFilter:(FunnelModel*)oldFilter;
+(void)editFilterWith:(FunnelModel*)model withOldFilter:(int)oldFilter;
+(FunnelModel*)getDefaultFilter;
- (void)applyingFunnel:(FunnelModel*)funnel toMessages:(NSArray*)messages;
- (void)applyingFilters:(NSArray*)messages;
- (void) startLogin :(EmailsTableViewController *) fv;
- (void)loadLastNMessages:(NSUInteger)nMessages withTableController:(EmailsTableViewController *)fv withFolder:(NSString*)folderName withFetchRange:(MCORange)newFetchRange;
- (void)loadLatestMail:(NSUInteger)nMessages  withTableController:(EmailsTableViewController *)fv withFolder:(NSString*)folderName;
- (void)checkMailsAtStart:(EmailsTableViewController*)fv;
-(void)syncMessages;
-(void)getDatabaseMessages:(NSString*)folderName withTableController:(EmailsTableViewController *)emailsTableViewController;
@end