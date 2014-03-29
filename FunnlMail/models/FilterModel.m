//
//  FilterModel.m
//  FunnlMail
//
//  Created by Michael Raber on 3/29/14.
//  Copyright (c) 2014 FunnlMail. All rights reserved.
//

#import "FilterModel.h"

@implementation FilterModel

- (id)initWithBarColor:(UIColor *)barColor filterTitle:(NSString *)filterTitle newMessageCount:(NSInteger)newMessageCount dateOfLastMessage:(NSDate *)dateOfLastMessage
{
  self = [super init];
  if (self) {
    // Custom initialization
    
    self.barColor = barColor;
    self.filterTitle = filterTitle;
    self.newMessageCount = newMessageCount;
    self.dateOfLastMessage = dateOfLastMessage;
  }
  return self;
}

@end
