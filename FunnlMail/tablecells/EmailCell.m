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
@synthesize dateLabel,senderLabel,subjectLabel,bodyLabel,readLabel;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    
    dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(320-85, 2, 80, 20)];
    senderLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 2, 320-105, 20)];
    subjectLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 24, 320-25, 20)];
    bodyLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 44, 320-25, 40)];
    readLabel = [[UILabel alloc] initWithFrame:CGRectMake(4, 10, 12, 12)];
    readLabel.layer.cornerRadius = 6;
    bodyLabel.numberOfLines = 2;
    
    dateLabel.font = [UIFont systemFontOfSize:13];
    senderLabel.font = [UIFont boldSystemFontOfSize:14];
    subjectLabel.font = [UIFont systemFontOfSize:13];
    bodyLabel.font = [UIFont systemFontOfSize:13];
    readLabel.font = [UIFont systemFontOfSize:13];
    
    dateLabel.textColor = [UIColor lightGrayColor];
    senderLabel.textColor = [UIColor blackColor];
    subjectLabel.textColor = [UIColor blackColor];
    bodyLabel.textColor = [UIColor lightGrayColor];
    readLabel.backgroundColor = [UIColor clearColor];
    
//    dateLabel.backgroundColor = [UIColor redColor];
//    senderLabel.backgroundColor = [UIColor greenColor];
//    subjectLabel.backgroundColor = [UIColor blueColor];
//    bodyLabel.backgroundColor = [UIColor orangeColor];
//    readLabel.backgroundColor = [UIColor redColor];
    
    [self.contentView addSubview:dateLabel];
    [self.contentView addSubview:senderLabel];
    [self.contentView addSubview:subjectLabel];
    [self.contentView addSubview:bodyLabel];
    [self.contentView addSubview:readLabel];
    
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
    self.detailTextLabel.text = @" ";
    self.bodyLabel.text = @" ";
    self.dateLabel.text = @" ";
    self.senderLabel.text = @" ";
    self.subjectLabel.text = @" ";
}

@end
