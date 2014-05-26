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

@interface EmailService : NSObject

+(EmailService *)instance;
+(NSArray *) currentFilters;
- (void)loadLastNMessages:(NSUInteger)nMessages : (EmailsTableViewController *) fv;
- (void) startLogin :(EmailsTableViewController *) fv;


@property (nonatomic, strong) MCOIMAPOperation *imapCheckOp;
@property (nonatomic, strong) MCOIMAPSession *imapSession;
@property (nonatomic, strong) MCOIMAPFetchMessagesOperation *imapMessagesFetchOp;
@property (nonatomic) NSInteger totalNumberOfInboxMessages;
@property (nonatomic, strong) NSMutableDictionary *messagePreviews;



@property (nonatomic, strong) NSArray *messages;


@end