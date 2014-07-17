//
//  ShareView.h
//  FunnlMail
//
//  Created by Macbook on 7/17/14.
//  Copyright (c) 2014 FunnlMail. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MainVCDelegate.h"
#include <MailCore/MailCore.h>
#import <MessageUI/MessageUI.h>
#import "TITokenField.h"
@class MCOMessageView;
@class MCOIMAPAsyncSession;
@class MCOMAPMessage;

@interface ShareView : UIView <UIGestureRecognizerDelegate,TITokenFieldDelegate>
{
    TITokenFieldView * toFieldView;
    FunnelModel *funnelModel;
    CGFloat _keyboardHeight;
    UITextView *_messageView;

}
@property (weak) id<MainVCDelegate> mainVCdelegate;

@property (nonatomic, strong) MCOAddress * address;
@property (nonatomic, strong) MCOIMAPMessage * message;
@property (nonatomic, strong) NSString * folder;
@property (nonatomic, strong) MCOIMAPSession * imapSession;
- (id)initWithFrame:(CGRect)frame withFunnlModel:(FunnelModel*)fm;
@end
