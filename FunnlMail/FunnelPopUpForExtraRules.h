//
//  FunnelPopUpForExtraRules.h
//  FunnlMail
//
//  Created by iauro001 on 6/23/14.
//  Copyright (c) 2014 FunnlMail. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MailCore/MailCore.h>
#import "FunnelModel.h"
#import "FunnelService.h"
#import "UIColor+HexString.h"
#import "ContactTableViewCell.h"
#import "EmailService.h"

@interface FunnelPopUpForExtraRules : UIView<UITableViewDataSource,UITableViewDelegate>
{
    MCOIMAPMessage *message;
    FunnelModel *tempFunnelModel;
    UITableView *contactsTableView;
    NSMutableArray *contactInCC;
    NSMutableArray *flagArray;
}
- (id)initWithFrame:(CGRect)frame withMessage:(MCOIMAPMessage*)messages withFunnel:(FunnelModel*)funnelDS;
@end
