//
//  MCTMsgViewController.h
//  testUI
//
//  Created by DINH Viêt Hoà on 1/20/13.
//  Copyright (c) 2013 MailCore. All rights reserved.
//

#include <MailCore/MailCore.h>

#import <MessageUI/MessageUI.h>
#import "UIColor+HexString.h"
#import "MessageModel.h"
#import "AppDelegate.h"

@class MCOMessageView;
@class MCOIMAPAsyncSession;
@class MCOMAPMessage;

@interface MCTMsgViewController : UIViewController <MFMailComposeViewControllerDelegate,UIScrollViewDelegate,UIWebViewDelegate>{
    IBOutlet MCOMessageView * _messageView;
    NSMutableDictionary * _storage;
    NSMutableSet * _pending;
    NSMutableArray * _ops;
    MCOIMAPSession * _session;
    MCOIMAPMessage * _message;
    NSMutableDictionary * _callbacks;
    NSString * _folder;
    
    //--new changes
    UIView *headerView;
    UIView *subjectView;
    int subjectHeight;
    int headerHeight;
    int webViewHeight;
    AppDelegate *appDelegate;
}

@property (nonatomic, copy) NSString * folder;
@property (nonatomic, strong) MCOIMAPSession * session;
@property (nonatomic, strong) MCOIMAPMessage * message;

//--new changes
@property (nonatomic, retain)NSIndexPath *selectedIndexPath;
@property (nonatomic, strong) MessageModel *messageModel;
@property (nonatomic, strong) MCOAddress * address;
@end
