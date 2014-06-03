//
//  EmailCell.h
//  FunnlMail
//
//  Created by Daniel Judd on 4/4/14.
//  Copyright (c) 2014 FunnlMail. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MailCore/MailCore.h>

@interface EmailCell : UITableViewCell
{
    
}
@property (nonatomic, strong) UILabel *senderLabel,*dateLabel,*subjectLabel,*readLabel,*bodyLabel,*threadLabel;
@property (nonatomic, strong) MCOIMAPMessageRenderingOperation * messageRenderingOperation;

@end
