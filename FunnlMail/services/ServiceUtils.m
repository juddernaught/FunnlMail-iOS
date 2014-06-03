//
//  ServiceUtils.m
//  FunnlMail
//
//  Created by Michael Raber on 6/3/14.
//  Copyright (c) 2014 FunnlMail. All rights reserved.
//

#import "ServiceUtils.h"

@implementation ServiceUtils

+(NSString *) convertDateTOSQLiteString:(NSDate *)date{
  NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
  
  [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"]; //this is the sqlite's format
  
  return [formatter stringFromDate:date];
}

@end
