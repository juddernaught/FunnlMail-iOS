//
//  EmailService.m
//  FunnlMail
//
//  Created by Michael Raber on 3/30/14.
//  Copyright (c) 2014 FunnlMail. All rights reserved.
//

#import "EmailService.h"
#import "FilterModel.h"

static EmailService *instance;

@interface EmailService ()

@end

@implementation EmailService

- (id)init
{
  self = [super init];
  if (self) {
    // Initialization code
  }
  return self;
}

+ (void)initialize
{
  static BOOL initialized = NO;
  if(!initialized)
  {
    initialized = YES;
    instance = [[EmailService alloc] init];
  }
}

+(EmailService *)instance{
  return instance;
}

+(NSArray *) currentFilters{
  NSMutableArray *filterArray = [[NSMutableArray alloc]init];
  
  //
  // Hardcoded, should come from the data store (i.e. sqlite)
  //
  
  //
  // created inital hardcoded list of filters
  //
  [filterArray addObject:[[FilterModel alloc]initWithBarColor:[UIColor greenColor] filterTitle:@"Primary" newMessageCount:16 dateOfLastMessage:[NSDate new]]];
  [filterArray addObject:[[FilterModel alloc]initWithBarColor:[UIColor purpleColor] filterTitle:@"Meetings" newMessageCount:5 dateOfLastMessage:[NSDate new]]];
  [filterArray addObject:[[FilterModel alloc]initWithBarColor:[UIColor orangeColor] filterTitle:@"Files" newMessageCount:24 dateOfLastMessage:[NSDate new]]];
  [filterArray addObject:[[FilterModel alloc]initWithBarColor:[UIColor purpleColor] filterTitle:@"Payments" newMessageCount:6 dateOfLastMessage:[NSDate new]]];
  [filterArray addObject:[[FilterModel alloc]initWithBarColor:[UIColor blueColor] filterTitle:@"Travel" newMessageCount:24 dateOfLastMessage:[NSDate new]]];
  [filterArray addObject:[[FilterModel alloc]initWithBarColor:[UIColor greenColor] filterTitle:@"News" newMessageCount:12 dateOfLastMessage:[NSDate new]]];
  [filterArray addObject:[[FilterModel alloc]initWithBarColor:[UIColor redColor] filterTitle:@"Forums" newMessageCount:5 dateOfLastMessage:[NSDate new]]];
  
  return filterArray;
}

@end
