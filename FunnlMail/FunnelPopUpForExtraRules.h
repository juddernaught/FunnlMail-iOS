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
#import "ContactService.h"
#import "GTMOAuth2ViewControllerTouch.h"

@interface FunnelPopUpForExtraRules : UIView<UITableViewDataSource,UITableViewDelegate>
{
    MCOIMAPMessage *message;
    FunnelModel *tempFunnelModel;
    UITableView *contactsTableView;
    NSMutableArray *contactInCC;
    NSMutableArray *dataSourceArray;
    NSMutableArray *flagArray;
    id viewController;
    UILabel *alsoAddLabel;
    UIImageView *userImage;
    UIButton *userButton;
    NSMutableArray *buttonArray;
}
@property (nonatomic, strong)UIImageView *backgroundImageView;
- (id)initWithFrame:(CGRect)frame withMessage:(MCOIMAPMessage*)messages withFunnel:(FunnelModel*)funnelDS onViewController:(id)someViewController;
@end
