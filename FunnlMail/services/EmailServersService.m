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

static EmailServersService *instance;

@implementation EmailServersService

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
    instance = [[EmailServersService alloc] init];
  }
}

+(EmailServersService *)instance{
  return instance;
}

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

-(BOOL) updateEmailServer:(EmailServerModel *)emailServerModel{
  __block NSMutableDictionary *paramDict = [[NSMutableDictionary alloc]init];
  
  __block BOOL success = NO;
  
  paramDict[@"emailAddress"] = emailServerModel.emailAddress;
  paramDict[@"accessToken"] = emailServerModel.accessToken;
  paramDict[@"refreshToken"] = emailServerModel.refreshToken;
  
  [[SQLiteDatabase sharedInstance].databaseQueue inDatabase:^(FMDatabase *db) {
    success = [db executeUpdate:@"UPDATE emailServers SET accessToken=:accessToken,refreshToken=:refreshToken WHERE emailAddress=:emailAddress" withParameterDictionary:paramDict];
    
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

-(EmailServerModel *) emailServersWithEmailAddress:(NSString *)emailAddress{
  __block NSMutableDictionary *paramDict = [[NSMutableDictionary alloc]init];
  
  __block EmailServerModel *model;
  
  paramDict[@"emailAddress"] = emailAddress;
  
  [[SQLiteDatabase sharedInstance].databaseQueue inDatabase:^(FMDatabase *db) {
    FMResultSet *resultSet = [db executeQuery:@"SELECT emailAddress,accessToken,refreshToken FROM emailServers WHERE emailAddress=:emailAddress" withParameterDictionary:paramDict];
    
    while ([resultSet next]) {
      model = [[EmailServerModel alloc]init];
      
      model.emailAddress = [resultSet stringForColumn:@"emailAddress"];
      model.accessToken = [resultSet stringForColumn:@"accessToken"];
      model.refreshToken = [resultSet stringForColumn:@"refreshToken"];
      
      //
      // we are expecting to only find one match
      //
      break;
    }
  }];
  
  return model;
}

-(BOOL) deleteEmailServer:(NSString *)emailAddress{
  __block NSMutableDictionary *paramDict = [[NSMutableDictionary alloc]init];
  
  __block BOOL success = NO;
  
  paramDict[@"emailAddress"] = emailAddress;
  
  [[SQLiteDatabase sharedInstance].databaseQueue inDatabase:^(FMDatabase *db) {
    success = [db executeUpdate:@"DELETE FROM emailServers WHERE emailAddress=:emailAddress" withParameterDictionary:paramDict];
  }];
  
  return success;
}

@end
