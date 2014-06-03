//
//  EmailServersService.m
//  FunnlMail
//
//  Created by Michael Raber on 6/2/14.
//  Copyright (c) 2014 FunnlMail. All rights reserved.
//

#import "EmailServersService.h"
#import "EmailServerModel.h"
#import "SQLiteDatabase.h"
#import "FMDatabase.h"
#import "FMResultSet.h"

@implementation EmailServersService

-(BOOL) insertEmailServer:(EmailServerModel *)emailServerModel{
  __block NSMutableDictionary *paramDict = [[NSMutableDictionary alloc]init];
  
  __block BOOL success = NO;
  
  paramDict[@"emailAddress"] = emailServerModel.emailAddress;
  paramDict[@"accessToken"] = emailServerModel.accessToken;
  paramDict[@"refreshToken"] = emailServerModel.refreshToken;
  
  [[SQLiteDatabase sharedInstance].databaseQueue inDatabase:^(FMDatabase *db) {
    success = [db executeUpdate:@"INSERT INTO emailServers (emailAddress,accessToken,refreshToken) VALUES (:emailAddress,:accessToken,:refreshToken)" withParameterDictionary:paramDict];
  }];
  
  return success;
}

-(NSArray *) allEmailServers{
  __block NSMutableArray *array = [[NSMutableArray alloc] init];
  
  [[SQLiteDatabase sharedInstance].databaseQueue inDatabase:^(FMDatabase *db) {
    FMResultSet *resultSet = [db executeQuery:@"SELECT emailAddress,accessToken,refreshToken FROM emailServers"];
  
    EmailServerModel *model;
    
    while ([resultSet next]) {
      model = [[EmailServerModel alloc]init];
      
      model.emailAddress = [resultSet stringForColumn:@"emailAddress"];
      model.accessToken = [resultSet stringForColumn:@"accessToken"];
      model.refreshToken = [resultSet stringForColumn:@"refreshToken"];
      
      [array addObject:model];
    }
  }];
  
  return array;
}

@end
