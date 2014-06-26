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
#import "FunnelModel.h"
#import <MailCore/MailCore.h>

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

-(BOOL) insertMessage:(MessageModel *)messageModel{
  __block NSMutableDictionary *paramDict = [[NSMutableDictionary alloc]init];
  
  __block BOOL success = NO;
  
  NSNumber *dateTimeInterval = [NSNumber numberWithDouble:[messageModel.date timeIntervalSince1970]];
  
  paramDict[@"messageID"] = messageModel.messageID;
  paramDict[@"messageJSON"] = messageModel.messageJSON;
  paramDict[@"read"] = [NSNumber numberWithBool:messageModel.read];
  paramDict[@"date"] = dateTimeInterval;
  paramDict[@"gmailthreadid"] = messageModel.gmailThreadID;
  
  [[SQLiteDatabase sharedInstance].databaseQueue inDatabase:^(FMDatabase *db) {
    success = [db executeUpdate:@"INSERT INTO messages (messageID,messageJSON,read,date,gmailthreadid) VALUES (:messageID,:messageJSON,:read,:date,:gmailthreadid)" withParameterDictionary:paramDict];
  }];
  
  return success;
}

-(BOOL) updateMessage:(MessageModel *)messageModel{
  __block NSMutableDictionary *paramDict = [[NSMutableDictionary alloc]init];
  
  __block BOOL success = NO;
  
  NSNumber *dateTimeInterval = [NSNumber numberWithDouble:[messageModel.date timeIntervalSince1970]];
  
  paramDict[@"messageID"] = messageModel.messageID;
  paramDict[@"messageJSON"] = messageModel.messageJSON;
  paramDict[@"read"] = [NSNumber numberWithBool:messageModel.read];
  paramDict[@"date"] = dateTimeInterval;
  
  [[SQLiteDatabase sharedInstance].databaseQueue inDatabase:^(FMDatabase *db) {
    success = [db executeUpdate:@"UPDATE messages SET messageJSON=:messageJSON,read=:read,date=:date WHERE messageID=:messageID" withParameterDictionary:paramDict];
    
  }];
  
  return success;
}

-(NSArray *) messagesAllTopMessages {
//    __block NSMutableDictionary *paramDict = [[NSMutableDictionary alloc]init];
    
//    paramDict[@"limit"] = [NSNumber numberWithInteger:top];
    
    __block NSMutableArray *array = [[NSMutableArray alloc] init];
    
    [[SQLiteDatabase sharedInstance].databaseQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *resultSet = [db executeQuery:@"SELECT messageID, messageJSON, read, date FROM messages order by messageID DESC" withParameterDictionary:nil];
        
        MessageModel *model;
        
        while ([resultSet next]) {
            model = [[MessageModel alloc]init];
            
            model.messageID = [resultSet stringForColumn:@"messageID"];
            model.messageJSON = [resultSet stringForColumn:@"messageJSON"];
            model.read = [resultSet intForColumn:@"read"];
            
            double dateTimeInterval = [resultSet doubleForColumn:@"date"];
            
            model.date = [NSDate dateWithTimeIntervalSince1970:dateTimeInterval];
            
            [array addObject:[MCOIMAPMessage importSerializable:model.messageJSON]];
        }
    }];
    
    return array;
}

-(NSArray *) messagesWithTop:(NSInteger)top{
  __block NSMutableDictionary *paramDict = [[NSMutableDictionary alloc]init];
  
  paramDict[@"limit"] = [NSNumber numberWithInteger:top];
  
  __block NSMutableArray *array = [[NSMutableArray alloc] init];
  
  [[SQLiteDatabase sharedInstance].databaseQueue inDatabase:^(FMDatabase *db) {
    FMResultSet *resultSet = [db executeQuery:@"SELECT messageID, messageJSON, read, date FROM messages order by messageID DESC limit :limit" withParameterDictionary:paramDict];
      
    MessageModel *model;
    
    while ([resultSet next]) {
      model = [[MessageModel alloc]init];
      
      model.messageID = [resultSet stringForColumn:@"messageID"];
      model.messageJSON = [resultSet stringForColumn:@"messageJSON"];
      model.read = [resultSet intForColumn:@"read"];
      
      double dateTimeInterval = [resultSet doubleForColumn:@"date"];
      
      model.date = [NSDate dateWithTimeIntervalSince1970:dateTimeInterval];
      
      [array addObject:[MCOIMAPMessage importSerializable:model.messageJSON]];
    }
  }];
  
  return array;
}

//newly added function by iauro001 on 13th June 2014
-(NSArray *) retrieveAllMessages{
    __block NSMutableDictionary *paramDict = [[NSMutableDictionary alloc]init];
    
    paramDict[@"limit"] = @"20";
    
    __block NSMutableArray *array = [[NSMutableArray alloc] init];
    
    [[SQLiteDatabase sharedInstance].databaseQueue inDatabase:^(FMDatabase *db) {
        //retriving all messages
//        FMResultSet *resultSet = [db executeQuery:@"SELECT messageID, messageJSON, read, date FROM messages order by messageID DESC" withParameterDictionary:nil];
        //new query retrieving the recent mail of a particular thread.
        
        FMResultSet *resultSet = [db executeQuery:@"SELECT messageID, messageJSON, read, date, t_count FROM messages INNER JOIN (SELECT MAX(messageID) as t_msgID, COUNT(*) as t_count FROM messages GROUP BY gmailthreadid) t ON ( messages. messageID = t.t_msgID ) order by messageID DESC;" withParameterDictionary:nil];
        
//        FMResultSet *resultSet = [db executeQuery:@"select messageID, messageJSON, read, date, count(gmailthreadid) as threadmailcount from messages group by gmailthreadid having messageID in (select max(messageID) from messages group by gmailthreadid) order by messageID DESC;" withParameterDictionary:nil];
        
        MessageModel *model;
        while ([resultSet next]) {
            model = [[MessageModel alloc]init];
            
            model.messageID = [resultSet stringForColumn:@"messageID"];
            model.messageJSON = [resultSet stringForColumn:@"messageJSON"];
            model.read = [resultSet intForColumn:@"read"];
            model.numberOfEmailInThread = [resultSet intForColumn:@"t_count"];

            double dateTimeInterval = [resultSet doubleForColumn:@"date"];
            model.date = [NSDate dateWithTimeIntervalSince1970:dateTimeInterval];
            
            //updated on 17th June 2014
            [array addObject:model];
//            [array addObject:[MCOIMAPMessage importSerializable:model.messageJSON]];
        }
    }];
    
    return array;
}

-(NSArray *) retrieveAllMessagesWithSameGmailID:(NSString*)gmailID{
    __block NSMutableDictionary *paramDict = [[NSMutableDictionary alloc]init];
    
    paramDict[@"gmailthreadid"] = gmailID;
    
    __block NSMutableArray *array = [[NSMutableArray alloc] init];
    
    [[SQLiteDatabase sharedInstance].databaseQueue inDatabase:^(FMDatabase *db) {
        //retriving all messages
        //        FMResultSet *resultSet = [db executeQuery:@"SELECT messageID, messageJSON, read, date FROM messages order by messageID DESC" withParameterDictionary:nil];
        //new query retrieving the recent mail of a particular thread.
        FMResultSet *resultSet = [db executeQuery:@"select messageID, messageJSON, read, date from messages where gmailthreadid = :gmailthreadid and read = 0;" withParameterDictionary:paramDict];
        
        MessageModel *model;
        while ([resultSet next]) {
            model = [[MessageModel alloc]init];
            
            model.messageID = [resultSet stringForColumn:@"messageID"];
            model.messageJSON = [resultSet stringForColumn:@"messageJSON"];
            model.read = [resultSet intForColumn:@"read"];
//            model.numberOfEmailInThread = [resultSet intForColumn:@"threadmailcount"];
            
            double dateTimeInterval = [resultSet doubleForColumn:@"date"];
            model.date = [NSDate dateWithTimeIntervalSince1970:dateTimeInterval];
            
            //updated on 17th June 2014
            [array addObject:model];
            //            [array addObject:[MCOIMAPMessage importSerializable:model.messageJSON]];
        }
    }];
    
    return array;
}

- (NSArray *) retrieveLatestMessages{
    __block NSMutableDictionary *paramDict = [[NSMutableDictionary alloc]init];
    
    paramDict[@"limit"] = @"20";
    
    __block NSMutableArray *array = [[NSMutableArray alloc] init];
    
    [[SQLiteDatabase sharedInstance].databaseQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *resultSet = [db executeQuery:@"SELECT max(messageID) as maxID FROM messages" withParameterDictionary:nil];
        while ([resultSet next]) {
            NSString *tempString = [resultSet stringForColumn:@"maxID"];
            if (tempString) {
                [array addObject:tempString];
            }
            tempString = nil;
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
      
      [array addObject:[MCOIMAPMessage importSerializable:model.messageJSON]];
    }
  }];
  
  return array;
}

//newly added on 17th June 2014
-(NSArray *) retrieveAllMessagesForThread:(NSString*)gmailthreadID{
    __block NSMutableDictionary *paramDict = [[NSMutableDictionary alloc]init];
    
    paramDict[@"gmailthreadid"] = gmailthreadID;
    
    __block NSMutableArray *array = [[NSMutableArray alloc] init];
    
    [[SQLiteDatabase sharedInstance].databaseQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *resultSet = [db executeQuery:@"select messageID, messageJSON, read, date from messages where gmailthreadid = :gmailthreadid order by messageID DESC;" withParameterDictionary:paramDict];
        
        MessageModel *model;
        while ([resultSet next]) {
            model = [[MessageModel alloc]init];
            
            model.messageID = [resultSet stringForColumn:@"messageID"];
            model.messageJSON = [resultSet stringForColumn:@"messageJSON"];
            model.read = [resultSet intForColumn:@"read"];
//            model.numberOfEmailInThread = [resultSet intForColumn:@"threadmailcount"];
            
            double dateTimeInterval = [resultSet doubleForColumn:@"date"];
            model.date = [NSDate dateWithTimeIntervalSince1970:dateTimeInterval];
            
            //updated on 17th June 2014
            [array addObject:model];
            //            [array addObject:[MCOIMAPMessage importSerializable:model.messageJSON]];
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

-(NSArray *) messagesWithFunnelId:(NSString *)funnelId top:(NSInteger)top{
  __block NSMutableDictionary *paramDict = [[NSMutableDictionary alloc]init];
  
  paramDict[@"funnelId"] = funnelId;
  paramDict[@"limit"] = [NSNumber numberWithInteger:top];
  
  __block NSMutableArray *array = [[NSMutableArray alloc] init];
  
  [[SQLiteDatabase sharedInstance].databaseQueue inDatabase:^(FMDatabase *db) {
    FMResultSet *resultSet = [db executeQuery:@"SELECT DISTINCT * FROM messageFilterXRef,messages WHERE messages.messageID==messageFilterXRef.messageID and messageFilterXRef.funnelId=:funnelId order by messageID DESC limit :limit" withParameterDictionary:paramDict];
    
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

-(NSArray *) messagesWithFunnelId:(NSString *)funnelId top:(NSInteger)top count:(NSInteger)count{
  __block NSMutableDictionary *paramDict = [[NSMutableDictionary alloc]init];
  
  paramDict[@"funnelId"] = funnelId;
  paramDict[@"limit"] = [NSNumber numberWithInteger:top];
  paramDict[@"count"] = [NSNumber numberWithInteger:count];
  
  __block NSMutableArray *array = [[NSMutableArray alloc] init];
  
  [[SQLiteDatabase sharedInstance].databaseQueue inDatabase:^(FMDatabase *db) {
    FMResultSet *resultSet = [db executeQuery:@"SELECT * FROM messageFilterXRef,messages WHERE messages.messageID==messageFilterXRef.messageID and messageFilterXRef.funnelId=:funnelId limit :limit, :count" withParameterDictionary:paramDict];
    
    MessageModel *model;
    
    while ([resultSet next]) {
      model = [[MessageModel alloc]init];
      
      model.messageID = [resultSet stringForColumn:@"messageID"];
      model.messageJSON = [resultSet stringForColumn:@"messageJSON"];
      model.read = [resultSet intForColumn:@"read"];
      
      double dateTimeInterval = [resultSet doubleForColumn:@"date"];
      
      model.date = [NSDate dateWithTimeIntervalSince1970:dateTimeInterval];
      
      [array addObject:model];
    }
  }];
  
  return array;
}

-(NSArray *) funnelsWithMessageID:(NSString *)messageID{
  __block NSMutableDictionary *paramDict = [[NSMutableDictionary alloc]init];
  
  paramDict[@"messageID"] = messageID;
  
  __block NSMutableArray *array = [[NSMutableArray alloc] init];
  
  [[SQLiteDatabase sharedInstance].databaseQueue inDatabase:^(FMDatabase *db) {
    FMResultSet *resultSet = [db executeQuery:@"SELECT * FROM messageFilterXRef, funnels WHERE messageFilterXRef.messageID==:messageID and messageFilterXRef.funnelId=funnels.funnelId" withParameterDictionary:paramDict];
    
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

@end
