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
#import "ServiceUtils.h"

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
  
  NSString *date = [ServiceUtils convertDateTOSQLiteString:messageModel.date];
  
  paramDict[@"messageID"] = messageModel.messageID;
  paramDict[@"messageJSON"] = messageModel.messageJSON;
  paramDict[@"read"] = [NSNumber numberWithBool:messageModel.read];
  paramDict[@"date"] = [NSString stringWithFormat:@"%@", date];
  
  [[SQLiteDatabase sharedInstance].databaseQueue inDatabase:^(FMDatabase *db) {
    success = [db executeUpdate:@"INSERT INTO messages (messageID,messageJSON,read,date) VALUES (:messageID,:messageJSON,:read,:date)" withParameterDictionary:paramDict];
  }];
  
  return success;
}

-(NSArray *) messagesWithTop:(NSInteger)top{
  __block NSMutableDictionary *paramDict = [[NSMutableDictionary alloc]init];
  
  paramDict[@"limit"] = [NSNumber numberWithInteger:top];
  
  __block NSMutableArray *array = [[NSMutableArray alloc] init];
  
  [[SQLiteDatabase sharedInstance].databaseQueue inDatabase:^(FMDatabase *db) {
    FMResultSet *resultSet = [db executeQuery:@"SELECT messageID,messageJSON,read,date FROM messages limit :limit"];
    
    MessageModel *model;
    
    while ([resultSet next]) {
      model = [[MessageModel alloc]init];
      
      model.messageID = [resultSet stringForColumn:@"messageID"];
      model.messageJSON = [resultSet stringForColumn:@"messageJSON"];
      model.read = [resultSet intForColumn:@"read"];
      model.date = [resultSet dateForColumn:@"date"];
      
      [array addObject:model];
    }
  }];
  
  return array;
}

-(NSArray *) messagesWithStart:(NSInteger)start count:(NSInteger)count{
  __block NSMutableDictionary *paramDict = [[NSMutableDictionary alloc]init];
  
  paramDict[@"start"] = [NSNumber numberWithInteger:start];
  paramDict[@"count"] = [NSNumber numberWithInteger:count];
  
  __block NSMutableArray *array = [[NSMutableArray alloc] init];
  
  [[SQLiteDatabase sharedInstance].databaseQueue inDatabase:^(FMDatabase *db) {
    FMResultSet *resultSet = [db executeQuery:@"SELECT messageID,messageJSON,read,date FROM messages limit :start, :count"];
    
    MessageModel *model;
    
    while ([resultSet next]) {
      model = [[MessageModel alloc]init];
      
      model.messageID = [resultSet stringForColumn:@"messageID"];
      model.messageJSON = [resultSet stringForColumn:@"messageJSON"];
      model.read = [resultSet intForColumn:@"read"];
      model.date = [resultSet dateForColumn:@"date"];
      
      [array addObject:model];
    }
  }];
  
  return array;
}

-(BOOL) deleteMessage:(NSString *)messageID{
  __block NSMutableDictionary *paramDict = [[NSMutableDictionary alloc]init];
  
  __block BOOL success = NO;
  
  paramDict[@"messageID"] = messageID;
  
  [[SQLiteDatabase sharedInstance].databaseQueue inDatabase:^(FMDatabase *db) {
    success = [db executeUpdate:@"DELETE FROM messages WHERE messageID=:messageID" withParameterDictionary:paramDict];
  }];
  
  return success;
}

@end
