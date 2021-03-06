//
//  EmailCell.h
//  FunnlMail
//
//  Created by Daniel Judd on 4/4/14.
//  Copyright (c) 2014 FunnlMail. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MailCore/MailCore.h>
#import "MCSwipeTableViewCell.h"
//#import "RDSwipeableTableViewCell.h"
#import "UIColor+HexString.h"
@interface EmailCell : MCSwipeTableViewCell
{
    
}
@property (nonatomic, strong) UIImageView *backgroundImageView;
@property (nonatomic, strong) UILabel *senderLabel,*dateLabel,*subjectLabel,*readLabel,*bodyLabel,*threadLabel;
@property (nonatomic, strong) MCOIMAPMessageRenderingOperation * messageRenderingOperation;
@property (nonatomic, strong) UIImageView *detailDiscloser;
@property (nonatomic, strong) UILabel *labelNameText;
@property (nonatomic, strong) UILabel *funnlLabel1,*funnlLabel2,*funnlLabel3;
@end
