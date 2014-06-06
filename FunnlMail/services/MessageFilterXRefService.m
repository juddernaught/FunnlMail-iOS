//
//  MessageFilterXRefService.m
//  FunnlMail
//
//  Created by Michael Raber on 6/3/14.
//  Copyright (c) 2014 FunnlMail. All rights reserved.
//

#import "MessageFilterXRefService.h"
#import "SQLiteDatabase.h"
#import "FMDatabase.h"
#import "FMResultSet.h"

static MessageFilterXRefService *instance;

@implementation MessageFilterXRefService

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
    instance = [[MessageFilterXRefService alloc] init];
  }
}

+(MessageFilterXRefService *)instance{
  return instance;
}

-(BOOL) insertMessageXRefMessageID:(NSString *)messageID funnelId:(NSString *)funnelId{
  __block NSMutableDictionary *paramDict = [[NSMutableDictionary alloc]init];
  
  __block BOOL success = NO;
  
  paramDict[@"messageID"] = messageID;
  paramDict[@"funnelId"] = funnelId;
  
  [[SQLiteDatabase sharedInstance].databaseQueue inDatabase:^(FMDatabase *db) {
    success = [db executeUpdate:@"INSERT INTO messageFilterXRef (messageID,funnelId) VALUES (:messageID,:funnelId)" withParameterDictionary:paramDict];
  }];
  
  return success;
}

-(BOOL) deleteXRefWithMessageID:(NSString *)messageID funnelId:(NSString *)funnelId{
  __block NSMutableDictionary *paramDict = [[NSMutableDictionary alloc]init];
  
  __block BOOL success = NO;
  
  paramDict[@"messageID"] = messageID;
  paramDict[@"funnelId"] = funnelId;
  
  [[SQLiteDatabase sharedInstance].databaseQueue inDatabase:^(FMDatabase *db) {
    success = [db executeUpdate:@"DELETE FROM messageFilterXRef WHERE messageID=:messageID AND funnelId=:funnelId" withParameterDictionary:paramDict];
  }];
  
  return success;
}

-(BOOL) deleteXRefWithMessageID:(NSString *)messageID{
  __block NSMutableDictionary *paramDict = [[NSMutableDictionary alloc]init];
  
  __block BOOL success = NO;
  
  paramDict[@"messageID"] = messageID;
  
  [[SQLiteDatabase sharedInstance].databaseQueue inDatabase:^(FMDatabase *db) {
    success = [db executeUpdate:@"DELETE FROM messageFilterXRef WHERE messageID=:messageID" withParameterDictionary:paramDict];
  }];
  
  return success;
}

-(BOOL) deleteXRefWithFunnelId:(NSString *)funnelId{
  __block NSMutableDictionary *paramDict = [[NSMutableDictionary alloc]init];
  
  __block BOOL success = NO;
  
  paramDict[@"funnelId"] = funnelId;
  
  [[SQLiteDatabase sharedInstance].databaseQueue inDatabase:^(FMDatabase *db) {
    success = [db executeUpdate:@"DELETE FROM messageFilterXRef WHERE funnelId=:funnelId" withParameterDictionary:paramDict];
  }];
  
  return success;
}

-(NSArray *) xrefWithMessageID:(NSString *)messageID{
  __block NSMutableDictionary *paramDict = [[NSMutableDictionary alloc]init];
  
  paramDict[@"messageID"] = messageID;
  
  __block NSMutableArray *array = [[NSMutableArray alloc] init];
  
  [[SQLiteDatabase sharedInstance].databaseQueue inDatabase:^(FMDatabase *db) {
    FMResultSet *resultSet = [db executeQuery:@"SELECT messageID,funnelId FROM messageFilterXRef WHERE messageID=:messageID" withParameterDictionary:paramDict];
    
    NSMutableDictionary *model;
    
    while ([resultSet next]) {
      model = [[NSMutableDictionary alloc]init];
      model[@"messageID"] = [resultSet stringForColumn:@"messageID"];
      model[@"funnelId"] = [resultSet stringForColumn:@"funnelId"];
      
      [array addObject:model];
    }
  }];
  
  return array;
}

-(NSArray *) xrefWithFunnelId:(NSString *)funnelId{
  __block NSMutableDictionary *paramDict = [[NSMutableDictionary alloc]init];
  
  paramDict[@"funnelId"] = funnelId;
  
  __block NSMutableArray *array = [[NSMutableArray alloc] init];
  
  [[SQLiteDatabase sharedInstance].databaseQueue inDatabase:^(FMDatabase *db) {
    FMResultSet *resultSet = [db executeQuery:@"SELECT messageID,funnelId FROM messageFilterXRef WHERE funnelId=:funnelId" withParameterDictionary:paramDict];
    
    NSMutableDictionary *model;
    
    while ([resultSet next]) {
      model = [[NSMutableDictionary alloc]init];
      model[@"messageID"] = [resultSet stringForColumn:@"messageID"];
      model[@"funnelId"] = [resultSet stringForColumn:@"funnelId"];
      
      [array addObject:model];
    }
  }];
  
  return array;
}


@end
