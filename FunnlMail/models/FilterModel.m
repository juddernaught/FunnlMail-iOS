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

- (id)initWithBarColor:(UIColor *)barColor filterTitle:(NSString *)filterTitle newMessageCount:(NSInteger)newMessageCount dateOfLastMessage:(NSDate *)dateOfLastMessage sendersArray:(NSMutableArray*)sendersArray subjectsArray:(NSMutableArray*)subjectsArray;
{
  self = [super init];
  if (self) {
    // Custom initialization
    self.barColor = barColor;
    self.filterTitle = filterTitle;
    self.newMessageCount = newMessageCount;
    self.dateOfLastMessage = dateOfLastMessage;
    self.sendersArray = sendersArray;
    self.subjectsArray = subjectsArray;
  }
  return self;
}


- (NSMutableDictionary*) getEmailsForFunnl: (NSString *) funnlName {
    NSMutableDictionary *funnlDictionary = [[NSMutableDictionary alloc] init];
    if (self.sendersArray == nil)
      self.sendersArray = [NSMutableArray array];
      if (self.subjectsArray == nil)
        self.subjectsArray = [NSMutableArray array];
        
    [funnlDictionary setObject:self.sendersArray forKey:@"senders"];
    [funnlDictionary setObject:self.subjectsArray forKey:@"subjects"];
    return funnlDictionary;
}

@end