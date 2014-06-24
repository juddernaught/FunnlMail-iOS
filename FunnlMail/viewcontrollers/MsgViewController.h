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

@class MCOMessageView;
@class MCOIMAPAsyncSession;
@class MCOMAPMessage;

@interface MsgViewController :  UIViewController <MFMailComposeViewControllerDelegate>{
    IBOutlet MCOMessageView * _messageView;
    NSMutableDictionary * _storage;
    NSMutableSet * _pending;
    NSMutableArray * _ops;
    MCOIMAPSession * _session;
    MCOIMAPMessage * _message;
    NSMutableDictionary * _callbacks;
    NSString * _folder;
}

@property (nonatomic, copy) NSString * folder;

@property (nonatomic, strong) MCOIMAPSession * session;
@property (nonatomic, strong) MCOIMAPMessage * message;
@property (nonatomic, strong) MCOAddress * address;
@end
