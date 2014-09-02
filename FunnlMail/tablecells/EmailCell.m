//
//  EmailCell.m
//  FunnlMail
//
//  Created by Daniel Judd on 4/4/14.
//  Copyright (c) 2014 FunnlMail. All rights reserved.
//

#import "EmailCell.h"
#import <QuartzCore/QuartzCore.h>


@implementation EmailCell
@synthesize dateLabel,senderLabel,subjectLabel,bodyLabel,readLabel,threadLabel,detailDiscloser,labelNameText;
@synthesize funnlLabel1,funnlLabel2,funnlLabel3;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    labelNameText = [[UILabel alloc] initWithFrame:CGRectMake(32, 96, 320 - 42, 20)];
    [labelNameText setBackgroundColor:[UIColor clearColor]];
    [labelNameText setTextAlignment:NSTextAlignmentRight];
    NSArray *labelArray = [[NSArray alloc] init];
    NSMutableAttributedString *tempAttributedString = [[NSMutableAttributedString alloc] init];
    NSArray *colorArray = GRADIENT_ARRAY;
    for (int count = 0; count < labelArray.count ; count++) {
        UIColor * color = [UIColor colorWithHexString:[colorArray objectAtIndex:count]];
        NSDictionary * attributes = [NSDictionary dictionaryWithObject:color forKey:NSForegroundColorAttributeName];
        NSAttributedString * subString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"  %@",[labelArray objectAtIndex:count]] attributes:attributes];
        [tempAttributedString appendAttributedString:subString];
        subString = nil;
    }
//    [labelNameText setAttributedText:tempAttributedString];
    labelArray = nil;
    tempAttributedString = nil;
    colorArray = nil;

    senderLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, 13, 320-108, 20)];
    [senderLabel setFont:MAIL_HEADER_FONT];
    [senderLabel setTextColor:MAIL_HEADER_TEXT_COLOR];
    senderLabel.backgroundColor = [UIColor clearColor];
    
    subjectLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, 33 + 2.25, 320-108, 17)];
    subjectLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    [subjectLabel setFont:MAIL_SUBJECT_FONT];
    subjectLabel.backgroundColor = [UIColor clearColor];
    subjectLabel.textColor = MAIL_SUBJECT_TEXT_COLOR;
    
    bodyLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, 33 + 2.25 + 17 + 2, 320-108, 35)];
    [bodyLabel setFont:MAIL_BODY_FONT];
    bodyLabel.backgroundColor = [UIColor clearColor];
    bodyLabel.numberOfLines = 2;
    bodyLabel.textColor = MAIL_BODY_TEXT_COLOR;
    
    readLabel = [[UILabel alloc] initWithFrame:CGRectMake(13, 23 - 6, 12, 12)];
    readLabel.clipsToBounds = YES;
    readLabel.layer.cornerRadius = 6;
    readLabel.layer.borderWidth = 0.5;
    readLabel.layer.borderColor = [[UIColor blackColor] CGColor];
    readLabel.backgroundColor = [UIColor clearColor];
    
    threadLabel = [[UILabel alloc] initWithFrame:CGRectMake(30 + 320-108, 33 + 2.25, 48-5, 17)];
    [threadLabel setFont:MAIL_SUBJECT_FONT];
    [threadLabel setTextColor:MAIL_SUBJECT_TEXT_COLOR];
    [threadLabel setTextAlignment:NSTextAlignmentLeft];
    
    detailDiscloser = [[UIImageView alloc] initWithFrame:CGRectMake(320-20, 35, 20, 20)];
    
    dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(320-65-13, 13, 65, 20)];
    [dateLabel setFont:MAIL_TIME_FONT];
    [dateLabel setTextColor:MAIL_TIME_COLOR];
    dateLabel.textAlignment = NSTextAlignmentRight;
    dateLabel.backgroundColor = [UIColor clearColor];
    
    funnlLabel1 = [[UILabel alloc] initWithFrame:CGRectMake(320 - 62 - 13, 33 + 2.25 + 15 + 2 + (35.0/2.0), 70 - 8, 20)];
    funnlLabel1.lineBreakMode = NSLineBreakByTruncatingMiddle;
    funnlLabel1.backgroundColor = [UIColor clearColor];
    [funnlLabel1 setFont:MAIL_FUNNEL_FONT];
    funnlLabel1.textColor = [UIColor whiteColor];
    funnlLabel1.textAlignment = NSTextAlignmentCenter;
    
//    funnlLabel2 = [[UILabel alloc] initWithFrame:CGRectMake(320-70-5, 72, 70, 20)];
//    funnlLabel2.backgroundColor = [UIColor clearColor];
//    [funnlLabel2 setFont:MAIL_FUNNEL_FONT];
//    funnlLabel2.textColor = [UIColor whiteColor];
//    funnlLabel2.textAlignment = NSTextAlignmentCenter;
    
    [detailDiscloser setImage:[UIImage imageNamed:@"arrow.png"]];
    
    [self.contentView addSubview:dateLabel];
    [self.contentView addSubview:threadLabel];
    [self.contentView addSubview:senderLabel];
    [self.contentView addSubview:subjectLabel];
    [self.contentView addSubview:bodyLabel];
    [self.contentView addSubview:readLabel];
//    [self.contentView addSubview:detailDiscloser];
    [self.contentView addSubview:labelNameText];
    [self.contentView addSubview:funnlLabel1];
//    [self.contentView addSubview:funnlLabel2];
    [self.contentView addSubview:funnlLabel3];
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)prepareForReuse
{
    [self.messageRenderingOperation cancel];
    self.detailTextLabel.text = @"";
    self.bodyLabel.text = @"";
//    self.dateLabel.text = @" ";
//    self.senderLabel.text = @" ";
//    self.subjectLabel.text = @" ";
}

@end
