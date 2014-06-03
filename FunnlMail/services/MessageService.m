//
//  MessageService.m
//  FunnlMail
//
//  Created by Michael Raber on 6/3/14.
//  Copyright (c) 2014 FunnlMail. All rights reserved.
//

#import "MessageService.h"
#import "SQLiteDatabase.h"
#import "FMDatabase.h"
#import "FMResultSet.h"

static MessageService *instance;

@implementation MessageService

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
    instance = [[MessageService alloc] init];
  }
}

+(MessageService *)instance{
  return instance;
}

-(BOOL) insertEmailServer:(MessageModel *)messageModel{
  __block NSMutableDictionary *paramDict = [[NSMutableDictionary alloc]init];
  
  __block BOOL success = NO;
  
  paramDict[@"messageID"] = messageModel.messageID;
  paramDict[@"messageJSON"] = messageModel.messageJSON;
  paramDict[@"read"] = [NSNumber numberWithBool:messageModel.read];
  paramDict[@"date"] = [NSString stringWithFormat:@"%@", messageModel.date];
  
  [[SQLiteDatabase sharedInstance].databaseQueue inDatabase:^(FMDatabase *db) {
    success = [db executeUpdate:@"INSERT INTO emailServers (messageID,messageJSON,read,date) VALUES (:messageID,:messageJSON,:read,:date)" withParameterDictionary:paramDict];
  }];
  
  return success;
}

@end
