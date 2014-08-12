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

    senderLabel = [[UILabel alloc] initWithFrame:CGRectMake(32, 10, 320-108, 20)];
    subjectLabel = [[UILabel alloc] initWithFrame:CGRectMake(32, 30, 320-108, 20)];
    bodyLabel = [[UILabel alloc] initWithFrame:CGRectMake(32, 50, 320-108, 90-47-7+10)];

//    senderLabel = [[UILabel alloc] initWithFrame:CGRectMake(32, 7, 320-105-6-60, 20)];
    readLabel = [[UILabel alloc] initWithFrame:CGRectMake(10-1, 20, 14, 14)];
    threadLabel = [[UILabel alloc] initWithFrame:CGRectMake(320-20-43, 35, 48-5, 20)];
    detailDiscloser = [[UIImageView alloc] initWithFrame:CGRectMake(320-20, 35, 20, 20)];
    
    dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(320-70-5, 12, 70, 20)];
    funnlLabel1 = [[UILabel alloc] initWithFrame:CGRectMake(320-70-5, 52, 70, 20)];
    funnlLabel2 = [[UILabel alloc] initWithFrame:CGRectMake(320-70-5, 72, 70, 20)];
//    funnlLabel3 = [[UILabel alloc] initWithFrame:CGRectMake(320-70, 70, 70, 20)];
    
    senderLabel.backgroundColor = [UIColor clearColor];
    subjectLabel.backgroundColor = [UIColor clearColor];
    bodyLabel.backgroundColor = [UIColor clearColor];
    funnlLabel1.backgroundColor = [UIColor clearColor];
    funnlLabel2.backgroundColor = [UIColor clearColor];
    funnlLabel3.backgroundColor = [UIColor clearColor];

    
    [detailDiscloser setImage:[UIImage imageNamed:@"arrow.png"]];
    [threadLabel setTextAlignment:NSTextAlignmentRight];
    readLabel.clipsToBounds = YES;
    readLabel.layer.cornerRadius = 7;
    readLabel.layer.borderWidth = 0.5;
    readLabel.layer.borderColor = [[UIColor blackColor] CGColor];
    bodyLabel.numberOfLines = 3;
    
    dateLabel.font = [UIFont systemFontOfSize:13];
    funnlLabel1.font = [UIFont systemFontOfSize:13];
    funnlLabel2.font = [UIFont systemFontOfSize:13];
    funnlLabel3.font = [UIFont systemFontOfSize:13];
    senderLabel.font = [UIFont boldSystemFontOfSize:16];
    subjectLabel.font = [UIFont systemFontOfSize:14];
    bodyLabel.font = [UIFont systemFontOfSize:14];
    readLabel.font = [UIFont systemFontOfSize:13];
    threadLabel.font = [UIFont systemFontOfSize:13];
    labelNameText.font = [UIFont systemFontOfSize:13];
    
    dateLabel.textColor = [UIColor blackColor];
    funnlLabel1.textColor = [UIColor blackColor];
    funnlLabel2.textColor = [UIColor blackColor];
    funnlLabel3.textColor = [UIColor blackColor];
    senderLabel.textColor = [UIColor blackColor];
    subjectLabel.textColor = [UIColor blackColor];
    bodyLabel.textColor = [UIColor lightGrayColor];
    readLabel.backgroundColor = [UIColor clearColor];
    
    dateLabel.textAlignment = NSTextAlignmentRight;
    funnlLabel1.textAlignment = NSTextAlignmentCenter;
    funnlLabel2.textAlignment = NSTextAlignmentCenter;
    funnlLabel3.textAlignment = NSTextAlignmentCenter;
//    dateLabel.backgroundColor = [UIColor redColor];
//    senderLabel.backgroundColor = [UIColor greenColor];
//    subjectLabel.backgroundColor = [UIColor blueColor];
//    bodyLabel.backgroundColor = [UIColor orangeColor];
//    readLabel.backgroundColor = [UIColor redColor];
    
    [self.contentView addSubview:dateLabel];
    [self.contentView addSubview:threadLabel];
    [self.contentView addSubview:senderLabel];
    [self.contentView addSubview:subjectLabel];
    [self.contentView addSubview:bodyLabel];
    [self.contentView addSubview:readLabel];
    [self.contentView addSubview:detailDiscloser];
    [self.contentView addSubview:labelNameText];
    [self.contentView addSubview:funnlLabel1];
    [self.contentView addSubview:funnlLabel2];
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
