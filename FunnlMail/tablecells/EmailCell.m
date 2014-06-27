//
//  EmailCell.m
//  FunnlMail
//
//  Created by Daniel Judd on 4/4/14.
//  Copyright (c) 2014 FunnlMail. All rights reserved.
//

#import "EmailCell.h"
#import <QuartzCore/QuartzCore.h>
#import "UIColor+HexString.h"

@implementation EmailCell
@synthesize dateLabel,senderLabel,subjectLabel,bodyLabel,readLabel,threadLabel,detailDiscloser,inclusiveFunnels;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    inclusiveFunnels = [[UILabel alloc] init];
    dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(320-80-10, 7, 80, 20)];
    senderLabel = [[UILabel alloc] initWithFrame:CGRectMake(32, 7, 320-105-6-60, 20)];
    subjectLabel = [[UILabel alloc] initWithFrame:CGRectMake(32, 27, 320-50-32, 20)];
    bodyLabel = [[UILabel alloc] initWithFrame:CGRectMake(32, 47, 320-50-32, 90-47-7)];
    readLabel = [[UILabel alloc] initWithFrame:CGRectMake(10-1, 10, 14, 14)];
    threadLabel = [[UILabel alloc] initWithFrame:CGRectMake(320-20-10-43, 35, 48-5, 20)];
    detailDiscloser = [[UIImageView alloc] initWithFrame:CGRectMake(320-20-10, 35, 20, 20)];
    [detailDiscloser setImage:[UIImage imageNamed:@"arrow.png"]];
    [threadLabel setTextAlignment:NSTextAlignmentRight];
    readLabel.clipsToBounds = YES;
    readLabel.layer.cornerRadius = 7;
    readLabel.layer.borderWidth = 0.5;
    readLabel.layer.borderColor = [[UIColor blackColor] CGColor];
    bodyLabel.numberOfLines = 2;
    
    dateLabel.font = [UIFont systemFontOfSize:13];
    senderLabel.font = [UIFont boldSystemFontOfSize:16];
    subjectLabel.font = [UIFont systemFontOfSize:14];
    bodyLabel.font = [UIFont systemFontOfSize:14];
    readLabel.font = [UIFont systemFontOfSize:13];
    threadLabel.font = [UIFont systemFontOfSize:13];
    
    dateLabel.textColor = [UIColor blackColor];
    senderLabel.textColor = [UIColor blackColor];
    [senderLabel setBackgroundColor:[UIColor clearColor]];
    subjectLabel.textColor = [UIColor blackColor];
    bodyLabel.textColor = [UIColor lightGrayColor];
    readLabel.backgroundColor = [UIColor clearColor];
    
    dateLabel.textAlignment = NSTextAlignmentRight;
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
//    [self.contentView addSubview:inclusiveFunnels];
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
