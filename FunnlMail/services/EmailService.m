//
//  EmailService.m
//  FunnlMail
//
//  Created by Michael Raber on 3/30/14.
//  Copyright (c) 2014 FunnlMail. All rights reserved.
//

#import "EmailService.h"
#import "FilterModel.h"
#import "UIColor+HexString.h"

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
  [filterArray addObject:[[FilterModel alloc]initWithBarColor:[UIColor colorWithHexString:@"#2EB82E"] filterTitle:@"Primary" newMessageCount:16 dateOfLastMessage:[NSDate new]]];
  [filterArray addObject:[[FilterModel alloc]initWithBarColor:[UIColor colorWithHexString:@"#FF85FF"] filterTitle:@"Meetings" newMessageCount:5 dateOfLastMessage:[NSDate new]]];
  [filterArray addObject:[[FilterModel alloc]initWithBarColor:[UIColor colorWithHexString:@"#FFB84D"] filterTitle:@"Files" newMessageCount:24 dateOfLastMessage:[NSDate new]]];
  [filterArray addObject:[[FilterModel alloc]initWithBarColor:[UIColor colorWithHexString:@"#AD5CFF"] filterTitle:@"Payments" newMessageCount:6 dateOfLastMessage:[NSDate new]]];
  [filterArray addObject:[[FilterModel alloc]initWithBarColor:[UIColor colorWithHexString:@"#33ADFF"] filterTitle:@"Travel" newMessageCount:24 dateOfLastMessage:[NSDate new]]];
  [filterArray addObject:[[FilterModel alloc]initWithBarColor:[UIColor colorWithHexString:@"#85E085"] filterTitle:@"News" newMessageCount:12 dateOfLastMessage:[NSDate new]]];
  [filterArray addObject:[[FilterModel alloc]initWithBarColor:[UIColor colorWithHexString:@"#B84D70"] filterTitle:@"Forums" newMessageCount:5 dateOfLastMessage:[NSDate new]]];
  
  return filterArray;
}

@end