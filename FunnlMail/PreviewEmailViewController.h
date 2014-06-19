//
//  PreviewEmailViewController.h
//  FunnlMail
//
//  Created by Pranav Herur on 6/15/14.
//  Copyright (c) 2014 FunnlMail. All rights reserved.
//

#import <UIKit/UIKit.h>
#include <MailCore/MailCore.h>
#import <MessageUI/MessageUI.h>


@interface PreviewEmailViewController : UIViewController
@property (nonatomic, strong) MCOAddress * address;
@property (nonatomic, strong) MCOIMAPMessage * message;
@property (nonatomic, strong) NSString * folder;
@property (nonatomic, strong) MCOIMAPSession * imapSession;
@end
