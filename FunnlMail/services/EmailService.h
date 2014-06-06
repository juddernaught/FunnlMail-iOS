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

@interface EmailService : NSObject{
    NSMutableArray *filterArray;
}
@property (nonatomic, strong) MCOIMAPOperation *imapCheckOp;
@property (nonatomic, strong) MCOIMAPSession *imapSession;
@property (nonatomic, strong) MCOIMAPFetchMessagesOperation *imapMessagesFetchOp;
@property (nonatomic) NSInteger totalNumberOfInboxMessages;
@property (nonatomic, strong) NSMutableDictionary *threadIdDictionary;
@property (nonatomic, strong) NSMutableArray *messages;
@property (nonatomic, strong) NSMutableDictionary *messagePreviews;
@property (nonatomic, strong) NSMutableArray *filterMessages;
@property (nonatomic, strong) NSMutableDictionary *filterMessagePreviews;
@property (nonatomic, strong) NSMutableArray *sentMessages;
@property (nonatomic, strong) NSMutableDictionary *sentMessagePreviews;
+(EmailService *)instance;
+(NSArray *) getCurrentFilters;
+(void)setNewFilterModel:(FilterModel*)model;
+(void)editFilter:(FilterModel*)model withOldFilter:(FilterModel*)oldFilter;
+(void)deleteFilter:(FilterModel*)oldFilter;
+(FilterModel*)getDefaultFilter;
- (void) startLogin :(EmailsTableViewController *) fv;
- (void)loadLastNMessages:(NSUInteger)nMessages  withTableController:(EmailsTableViewController *)fv withFolder:(NSString*)folderName;
@end