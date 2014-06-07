//
//  FunnelService.m
//  FunnlMail
//
//  Created by Michael Raber on 6/3/14.
//  Copyright (c) 2014 FunnlMail. All rights reserved.
//

#import "FunnelService.h"
#import "FunnelModel.h"
#import "SQLiteDatabase.h"
#import "FMDatabase.h"
#import "FMResultSet.h"

static FunnelService *instance;

@implementation FunnelService

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
    instance = [[FunnelService alloc] init];
  }
}

+(FunnelService *)instance{
  return instance;
}

-(BOOL) insertFunnel:(FunnelModel *)funnelModel{
  __block NSMutableDictionary *paramDict = [[NSMutableDictionary alloc]init];
  
  __block BOOL success = NO;
  
  paramDict[@"funnelId"] = [[NSUUID UUID] UUIDString];
  paramDict[@"funnelName"] = funnelModel.funnelName;
  paramDict[@"emailAddresses"] = funnelModel.emailAddresses;
  paramDict[@"phrases"] = funnelModel.phrases;
  
  [[SQLiteDatabase sharedInstance].databaseQueue inDatabase:^(FMDatabase *db) {
    success = [db executeUpdate:@"INSERT INTO funnels (funnelId,funnelName,emailAddresses,phrases) VALUES (:funnelId,:funnelName,:emailAddresses,:phrases)" withParameterDictionary:paramDict];
  }];
  
  if(success){
    funnelModel.funnelId = paramDict[@"funnelId"];
  }
  
  return success;
}

-(BOOL) updateFunnel:(FunnelModel *)funnelModel{
  __block NSMutableDictionary *paramDict = [[NSMutableDictionary alloc]init];
  
  __block BOOL success = NO;
  
  paramDict[@"funnelId"] = funnelModel.funnelId;
  paramDict[@"funnelName"] = funnelModel.funnelName;
  paramDict[@"emailAddresses"] = funnelModel.emailAddresses;
  paramDict[@"phrases"] = funnelModel.phrases;
  
  [[SQLiteDatabase sharedInstance].databaseQueue inDatabase:^(FMDatabase *db) {
    success = [db executeUpdate:@"UPDATE funnels SET funnelName=:funnelName,emailAddresses=:emailAddresses,phrases=:phrases WHERE funnelId=:funnelId" withParameterDictionary:paramDict];
    
  }];
  
  return success;
}

-(NSArray *) allFunnels{
  __block NSMutableArray *array = [[NSMutableArray alloc] init];
  
  [[SQLiteDatabase sharedInstance].databaseQueue inDatabase:^(FMDatabase *db) {
    FMResultSet *resultSet = [db executeQuery:@"SELECT funnelId,funnelName,emailAddresses,phrases FROM funnels"];
    
    FunnelModel *model;
    
    while ([resultSet next]) {
      model = [[FunnelModel alloc]init];
      
      model.funnelId = [resultSet stringForColumn:@"funnelId"];
      model.funnelName = [resultSet stringForColumn:@"funnelName"];
      model.emailAddresses = [resultSet stringForColumn:@"emailAddresses"];
      model.phrases = [resultSet stringForColumn:@"phrases"];
      
      [array addObject:model];
    }
  }];
  
  return array;
}

-(FunnelModel *) emailServersWithFunnelName:(NSString *)funnelName{
  __block NSMutableDictionary *paramDict = [[NSMutableDictionary alloc]init];
  
  __block FunnelModel *model;
  
  paramDict[@"funnelName"] = funnelName;
  
  [[SQLiteDatabase sharedInstance].databaseQueue inDatabase:^(FMDatabase *db) {
    FMResultSet *resultSet = [db executeQuery:@"SELECT funnelId,funnelName,emailAddresses,phrases FROM funnels WHERE funnelName=:funnelName" withParameterDictionary:paramDict];
    
    while ([resultSet next]) {
      model = [[FunnelModel alloc]init];
      
      model.funnelId = [resultSet stringForColumn:@"funnelId"];
      model.funnelName = [resultSet stringForColumn:@"funnelName"];
      model.emailAddresses = [resultSet stringForColumn:@"emailAddresses"];
      model.phrases = [resultSet stringForColumn:@"phrases"];
      
      //
      // we are expecting to only find one match
      //
      break;
    }
  }];
  
  return model;
}

-(BOOL) deleteFunnel:(NSString *)funnelId{
  __block NSMutableDictionary *paramDict = [[NSMutableDictionary alloc]init];
  
  __block BOOL success = NO;
  
  paramDict[@"funnelId"] = funnelId;
  
  [[SQLiteDatabase sharedInstance].databaseQueue inDatabase:^(FMDatabase *db) {
    success = [db executeUpdate:@"DELETE FROM funnels WHERE funnelId=:funnelId" withParameterDictionary:paramDict];
  }];
  
  return success;
}

@end
