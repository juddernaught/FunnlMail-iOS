//
//  ComposeViewController.h
//  FunnlMail
//
//  Created by Macbook on 7/14/14.
//  Copyright (c) 2014 FunnlMail. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TITokenField.h"
#include <MailCore/MailCore.h>
#import <MessageUI/MessageUI.h>
@class MCOMessageView;
@class MCOIMAPAsyncSession;
@class MCOMAPMessage;

@interface ComposeViewController : UIViewController <TITokenFieldDelegate, UITextViewDelegate>
{
    UIScrollView *scrollView;
    CGRect previousRect;

}
@property (nonatomic, strong) MCOAddress * address;
@property (nonatomic, strong) MCOIMAPMessage * message;
@property (nonatomic, strong) NSString * folder;
@property (nonatomic, strong) MCOIMAPSession * imapSession;
@property (nonatomic) NSNumber * compose;
@property (nonatomic) NSNumber * reply;
@property (nonatomic) NSNumber * forward;
@property (nonatomic) NSNumber * replyAll;
@property (nonatomic) NSNumber * sendFeedback;
@property (nonatomic) UITextView * body;
@property (nonatomic) NSArray * addressArray;

@end
