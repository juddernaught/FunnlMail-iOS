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

+ (NSSet*) getEmailsForFunnl: (NSString *) funnlName {
    NSMutableDictionary *funnlDictionary = [[NSMutableDictionary alloc] init];
    [funnlDictionary setObject: [NSSet setWithArray:@[@"juddernaught@gmail.com", @"djudd@wharton.upenn.edu", @"djudd@seas.upenn.edu", @"michael.raber@gmail.com", @"manpuria@wharton.upenn.edu", @"apoorvap@wharton.upenn.edu"]] forKey: @"FunnlMail"];
    NSArray *filterEmails = [funnlDictionary objectForKey:funnlName];
    if (filterEmails == nil) {
        return [NSSet setWithArray:@[]];
    }
    else {
        return [funnlDictionary objectForKey:funnlName];
    }
}

@end