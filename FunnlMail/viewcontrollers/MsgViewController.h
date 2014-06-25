//
//  MsgViewController.h
//  FunnlMail
//
//  Created by Daniel Judd on 4/4/14.
//  Copyright (c) 2014 FunnlMail. All rights reserved.
//

#import <UIKit/UIKit.h>
#include <MailCore/MailCore.h>
#import <MessageUI/MessageUI.h>
#import "UIColor+HexString.h"
#define TO_TAG_STARTING 20000
#define CC_TAG_STARTING 30000
@class MCOMessageView;
@class MCOIMAPAsyncSession;
@class MCOMAPMessage;

@interface MsgViewController :  UIViewController <MFMailComposeViewControllerDelegate,UITableViewDataSource,UITableViewDelegate>{
    IBOutlet MCOMessageView * _messageView;
    NSMutableDictionary * _storage;
    NSMutableSet * _pending;
    NSMutableArray * _ops;
    MCOIMAPSession * _session;
    MCOIMAPMessage * _message;
    NSMutableDictionary * _callbacks;
    NSString * _folder;
    UIView *headerView;
    UIView *subjectView;
    int subjectHeight;
    int headerHeight;
    UITableView *messageTableView;
}

@property (nonatomic, copy) NSString * folder;

@property (nonatomic, strong) MCOIMAPSession * session;
@property (nonatomic, strong) MCOIMAPMessage * message;
@property (nonatomic, strong) MCOAddress * address;
@end
