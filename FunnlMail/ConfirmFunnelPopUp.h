//
//  ConfirmFunnelPopUp.h
//  FunnlMail
//
//  Created by iauro001 on 6/23/14.
//  Copyright (c) 2014 FunnlMail. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MainVCDelegate.h"
#import <MailCore/MailCore.h>
#import "FunnelModel.h"

@interface ConfirmFunnelPopUp : UIView
{
    NSArray *filterArray;
    BOOL isNewCreatePopup;
    NSString *messageID;
    MCOIMAPMessage *message;
    id emailViewController;
    FunnelModel *tempDS;
}
@property (weak) id<MainVCDelegate> mainVCdelegate;
- (id)initWithFrame:(CGRect)frame withNewPopup:(BOOL)isNew withMessageId:(NSString*)mID withMessage:(MCOIMAPMessage*)m onViewController:(id)someViewController withFunnelModel:(FunnelModel*)funnelDS;
@end
