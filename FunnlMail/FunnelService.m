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

@implementation FunnelService

-(BOOL) insertEmailServer:(FunnelModel *)funnelModel{
  __block NSMutableDictionary *paramDict = [[NSMutableDictionary alloc]init];
  
  __block BOOL success = NO;
  
  paramDict[@"funnelName"] = funnelModel.funnelName;
  paramDict[@"emailAddresses"] = funnelModel.emailAddresses;
  paramDict[@"phrases"] = funnelModel.phrases;
  
  [[SQLiteDatabase sharedInstance].databaseQueue inDatabase:^(FMDatabase *db) {
    success = [db executeUpdate:@"INSERT INTO funnels (funnelName,emailAddresses,phrases) VALUES (:funnelName,:emailAddresses,:phrases)" withParameterDictionary:paramDict];
  }];
  
  return success;
}

-(NSArray *) allFunnels{
  __block NSMutableArray *array = [[NSMutableArray alloc] init];
  
  [[SQLiteDatabase sharedInstance].databaseQueue inDatabase:^(FMDatabase *db) {
    FMResultSet *resultSet = [db executeQuery:@"SELECT funnelName,emailAddresses,phrases FROM funnels"];
    
    FunnelModel *model;
    
    while ([resultSet next]) {
      model = [[FunnelModel alloc]init];
      
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
    FMResultSet *resultSet = [db executeQuery:@"SELECT funnelName,emailAddresses,phrases FROM funnels WHERE funnelName=:funnelName" withParameterDictionary:paramDict];
    
    while ([resultSet next]) {
      model = [[FunnelModel alloc]init];
      
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

-(BOOL) deleteFunnel:(NSString *)funnelName{
  __block NSMutableDictionary *paramDict = [[NSMutableDictionary alloc]init];
  
  __block BOOL success = NO;
  
  paramDict[@"funnelName"] = funnelName;
  
  [[SQLiteDatabase sharedInstance].databaseQueue inDatabase:^(FMDatabase *db) {
    success = [db executeUpdate:@"DELETE FROM funnels WHERE funnelName=:funnelName" withParameterDictionary:paramDict];
  }];
  
  return success;
}

@end
