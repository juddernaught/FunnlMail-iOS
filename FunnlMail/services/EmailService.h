//
//  EmailService.h
//  FunnlMail
//
//  Created by Michael Raber on 3/30/14.
//  Copyright (c) 2014 FunnlMail. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EmailsTableViewController.h"
#import "SentEmailsTableViewController.h"
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
@property (nonatomic) NSInteger totalNumberOfInboxMessages;
@property (nonatomic) NSInteger totalNumberOfSentMessages;
@property (nonatomic, strong) NSMutableDictionary *threadIdDictionary;
@property (nonatomic, strong) NSMutableArray *messages;
@property (nonatomic, strong) NSMutableArray *sentMessages;
@property (nonatomic, strong) NSMutableDictionary *messagePreviews;
@property (nonatomic, strong) NSMutableArray *filterMessages;
@property (nonatomic, strong) NSMutableDictionary *filterMessagePreviews;
@property (nonatomic, strong) NSMutableDictionary *sentMessagePreviews;
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
- (void)loadLastNMessages:(NSUInteger)nMessages  withTableController:(EmailsTableViewController *)fv withFolder:(NSString*)folderName;
- (void)loadLatestMail:(NSUInteger)nMessages  withTableController:(EmailsTableViewController *)fv withFolder:(NSString*)folderName;
- (void)loadLastNSentMessages:(NSUInteger)nMessages  withTableController:(SentEmailsTableViewController *)fv withFolder:(NSString*)folderName;
- (void)loadLatestSentMail:(NSUInteger)nMessages  withTableController:(SentEmailsTableViewController *)fv withFolder:(NSString*)folderName;
@end