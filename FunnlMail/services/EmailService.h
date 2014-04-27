//
//  EmailService.h
//  FunnlMail
//
//  Created by Michael Raber on 3/30/14.
//  Copyright (c) 2014 FunnlMail. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FilterView.h"
#import <mailcore/mailcore.h>

@interface EmailService : NSObject

+(EmailService *)instance;
+(NSArray *) currentFilters;
- (void)loadLastNMessages:(NSUInteger)nMessages : (FilterView *) fv;
- (void) startLogin :(FilterView *) fv;


@property (nonatomic, strong) MCOIMAPOperation *imapCheckOp;
@property (nonatomic, strong) MCOIMAPSession *imapSession;
@property (nonatomic, strong) MCOIMAPFetchMessagesOperation *imapMessagesFetchOp;

@end