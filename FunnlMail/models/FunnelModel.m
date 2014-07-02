//
//  FilterModel.m
//  FunnlMail
//
//  Created by Michael Raber on 3/29/14.
//  Copyright (c) 2014 FunnlMail. All rights reserved.
//

#import "FunnelModel.h"

@implementation FunnelModel

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
    self.funnelName = filterTitle;
    self.newMessageCount = newMessageCount;
    self.dateOfLastMessage = dateOfLastMessage;
    self.sendersArray = sendersArray;
    NSMutableString *senderString = [[NSMutableString alloc] init];
    for (int counter = 0; counter < sendersArray.count; counter++) {
        [senderString appendString:[sendersArray objectAtIndex:counter]];
        [senderString appendString:@","];
    }
    if (senderString.length > 1) {
        senderString = (NSMutableString *)[senderString substringWithRange:NSMakeRange(0, senderString.length-1)];
    }
    else
        [senderString appendString:@""];
    self.emailAddresses = senderString;
    senderString = nil;
      
    self.subjectsArray = subjectsArray;
    senderString = [[NSMutableString alloc] init];
    for (int counter = 0; counter < subjectsArray.count; counter++) {
        [senderString appendString:[subjectsArray objectAtIndex:counter]];
        [senderString appendString:@","];
    }
    if (senderString.length > 1) {
        senderString = (NSMutableString *)[senderString substringWithRange:NSMakeRange(0, senderString.length-1)];
    }
    else
        [senderString appendString:@""];
    self.phrases = senderString;
    senderString = nil;
  }
  return self;
}

- (id)initWithBarColor:(UIColor *)barColor filterTitle:(NSString *)filterTitle newMessageCount:(NSInteger)newMessageCount dateOfLastMessage:(NSDate *)dateOfLastMessage sendersArray:(NSMutableArray*)sendersArray subjectsArray:(NSMutableArray*)subjectsArray skipAllFlag:(BOOL)flag
{
    self = [super init];
    if (self) {
        // Custom initialization
        self.skipFlag = flag;
        self.barColor = barColor;
        self.filterTitle = filterTitle;
        self.funnelName = filterTitle;
        self.newMessageCount = newMessageCount;
        self.dateOfLastMessage = dateOfLastMessage;
        self.sendersArray = sendersArray;
        NSMutableString *senderString = [[NSMutableString alloc] init];
        for (int counter = 0; counter < sendersArray.count; counter++) {
            [senderString appendString:[sendersArray objectAtIndex:counter]];
            [senderString appendString:@","];
        }
        if (senderString.length > 1) {
            senderString = (NSMutableString *)[senderString substringWithRange:NSMakeRange(0, senderString.length-1)];
        }
        else
            [senderString appendString:@""];
        self.emailAddresses = senderString;
        senderString = nil;
        
        self.subjectsArray = subjectsArray;
        senderString = [[NSMutableString alloc] init];
        for (int counter = 0; counter < subjectsArray.count; counter++) {
            [senderString appendString:[subjectsArray objectAtIndex:counter]];
            [senderString appendString:@","];
        }
        if (senderString.length > 1) {
            senderString = (NSMutableString *)[senderString substringWithRange:NSMakeRange(0, senderString.length-1)];
        }
        else
            [senderString appendString:@""];
        self.phrases = senderString;
        senderString = nil;
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

//changed by iaruo001 on 11th June 2014
-(NSString *) description{
    return [NSString stringWithFormat:@"{funnelId:%@, funnelName:%@, emailAddresses:%@, phrases:%@}", self.funnelId, self.funnelName, self.emailAddresses, self.phrases];
}
@end