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
#import "FunnelService.h"
#import "MessageFilterXRefService.h"

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
  paramDict[@"skipFlag"] = [NSNumber numberWithBool:messageModel.skipFlag];
  
  [[SQLiteDatabase sharedInstance].databaseQueue inDatabase:^(FMDatabase *db) {
    success = [db executeUpdate:@"INSERT INTO messages (messageID,messageJSON,read,date,gmailthreadid,skipFlag) VALUES (:messageID,:messageJSON,:read,:date,:gmailthreadid,:skipFlag)" withParameterDictionary:paramDict];
  }];
  
  return success;
}

-(BOOL) updateMessageWithHTMLContent:(NSDictionary *)messageDict{
    __block NSMutableDictionary *paramDict = [[NSMutableDictionary alloc]init];
    
    __block BOOL success = NO;
    
    //    NSNumber *dateTimeInterval = [NSNumber numberWithDouble:[messageModel.date timeIntervalSince1970]];
    
    paramDict[@"messageID"] = [messageDict.allKeys objectAtIndex:0];
    paramDict[@"messageHTMLBody"] = [messageDict objectForKey:[messageDict.allKeys objectAtIndex:0]];
    
    [[SQLiteDatabase sharedInstance].databaseQueue inDatabase:^(FMDatabase *db) {
        success = [db executeUpdate:@"UPDATE messages SET messageHTMLBody=:messageHTMLBody WHERE messageID=:messageID" withParameterDictionary:paramDict];
        
    }];
    
    return success;
}

-(BOOL) updateMessageWithDictionary:(NSDictionary *)messageDict{
    __block NSMutableDictionary *paramDict = [[NSMutableDictionary alloc]init];
    
    __block BOOL success = NO;
    
//    NSNumber *dateTimeInterval = [NSNumber numberWithDouble:[messageModel.date timeIntervalSince1970]];
    
    paramDict[@"messageID"] = [messageDict.allKeys objectAtIndex:0];
    paramDict[@"messageBodyToBeRendered"] = [messageDict objectForKey:[messageDict.allKeys objectAtIndex:0]];
    
    [[SQLiteDatabase sharedInstance].databaseQueue inDatabase:^(FMDatabase *db) {
        success = [db executeUpdate:@"UPDATE messages SET messageBodyToBeRendered=:messageBodyToBeRendered WHERE messageID=:messageID" withParameterDictionary:paramDict];
        
    }];
    
    return success;
}

- (NSArray*)retrieveHTMLContentWithID:(NSString*)uid {
    __block NSMutableArray *array = [[NSMutableArray alloc] init];
    __block NSMutableDictionary *paramDict = [[NSMutableDictionary alloc]init];
    paramDict[@"messageID"] = uid;
    [[SQLiteDatabase sharedInstance].databaseQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *resultSet = [db executeQuery:@"select messageHTMLBody from messages where messageID=:messageID" withParameterDictionary:paramDict];
        
//        MessageModel *model;
        
        while ([resultSet next]) {
            if ([resultSet stringForColumn:@"messageHTMLBody"]) {
                [array addObject:[resultSet stringForColumn:@"messageHTMLBody"]];
            }
        }
    }];
    return array;
}

-(BOOL) updateMessage:(MessageModel *)messageModel{
  __block NSMutableDictionary *paramDict = [[NSMutableDictionary alloc]init];
  
  __block BOOL success = NO;
  
  NSNumber *dateTimeInterval = [NSNumber numberWithDouble:[messageModel.date timeIntervalSince1970]];
  
  paramDict[@"messageID"] = messageModel.messageID;
  paramDict[@"messageJSON"] = messageModel.messageJSON;
  paramDict[@"read"] = [NSNumber numberWithBool:messageModel.read];
  paramDict[@"date"] = dateTimeInterval;
  paramDict[@"skipFlag"] = [NSNumber numberWithBool:messageModel.skipFlag];
    if (messageModel.funnelJson) {
        paramDict[@"funnelJson"] = messageModel.funnelJson;
    }
    else
        paramDict[@"funnelJson"] = @"";
  
  
  [[SQLiteDatabase sharedInstance].databaseQueue inDatabase:^(FMDatabase *db) {
    success = [db executeUpdate:@"UPDATE messages SET messageJSON=:messageJSON,read=:read,date=:date,skipFlag=:skipFlag,funnelJson=:funnelJson WHERE messageID=:messageID" withParameterDictionary:paramDict];
    
  }];
  
  return success;
}

-(NSArray *) messagesAllTopMessages {
//    __block NSMutableDictionary *paramDict = [[NSMutableDictionary alloc]init];
    
//    paramDict[@"limit"] = [NSNumber numberWithInteger:top];
    
    __block NSMutableArray *array = [[NSMutableArray alloc] init];
    
    [[SQLiteDatabase sharedInstance].databaseQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *resultSet = [db executeQuery:@"SELECT messageID, messageJSON, read, date, skipFlag, funnelJson FROM messages order by messageID DESC" withParameterDictionary:nil];
        
        MessageModel *model;
        
        while ([resultSet next]) {
            model = [[MessageModel alloc]init];
            
            model.messageID = [resultSet stringForColumn:@"messageID"];
            model.messageJSON = [resultSet stringForColumn:@"messageJSON"];
            model.read = [resultSet intForColumn:@"read"];
            model.skipFlag = [resultSet intForColumn:@"skipFlag"];
            double dateTimeInterval = [resultSet doubleForColumn:@"date"];
            if ([resultSet stringForColumn:@"funnelJson"]) {
                model.funnelJson = [resultSet stringForColumn:@"funnelJson"];
            }
            else
                model.funnelJson = @"";
            model.date = [NSDate dateWithTimeIntervalSince1970:dateTimeInterval];
            [array addObject:model];
//            [array addObject:[MCOIMAPMessage importSerializable:model.messageJSON]];
        }
    }];
    
    return array;
}


//currently not in use
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
    __block NSMutableArray *array = [[NSMutableArray alloc] init];
    
    [[SQLiteDatabase sharedInstance].databaseQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *resultSet = [db executeQuery:@"SELECT messageID, messageJSON, read, messageBodyToBeRendered, date, t_count,skipFlag,funnelJson FROM messages INNER JOIN (SELECT MAX(messageID) as t_msgID, COUNT(*) as t_count FROM messages where skipFlag = 0 GROUP BY gmailthreadid) t ON ( messages. messageID = t.t_msgID ) order by messageID DESC;" withParameterDictionary:nil];
        
        MessageModel *model;
        while ([resultSet next]) {
            model = [[MessageModel alloc]init];
            
            model.messageID = [resultSet stringForColumn:@"messageID"];
            model.messageJSON = [resultSet stringForColumn:@"messageJSON"];
            model.read = [resultSet intForColumn:@"read"];
            model.numberOfEmailInThread = [resultSet intForColumn:@"t_count"];

            double dateTimeInterval = [resultSet doubleForColumn:@"date"];
            model.date = [NSDate dateWithTimeIntervalSince1970:dateTimeInterval];
            if ([resultSet stringForColumn:@"messageBodyToBeRendered"]) {
                model.messageBodyToBeRendered = [resultSet stringForColumn:@"messageBodyToBeRendered"];
            }
            else
                model.messageBodyToBeRendered = EMPTY_DELIMITER;
            if ([resultSet stringForColumn:@"funnelJson"]) {
                model.funnelJson = [resultSet stringForColumn:@"funnelJson"];
            }
            else
                model.funnelJson = @"";
//            if ([resultSet stringForColumn:@"messageHTMLBody"]) {
//                model.messageHTMLBody = [resultSet stringForColumn:@"messageHTMLBody"];
//            }
//            else
//                model.messageHTMLBody = EMPTY_DELIMITER;
            
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
        FMResultSet *resultSet = [db executeQuery:@"select messageID, messageJSON, read, messageBodyToBeRendered, messageHTMLBody, date from messages where gmailthreadid = :gmailthreadid and skipFlag=0 order by messageID DESC;" withParameterDictionary:paramDict];
        
        MessageModel *model;
        while ([resultSet next]) {
            model = [[MessageModel alloc]init];
            
            model.messageID = [resultSet stringForColumn:@"messageID"];
            model.messageJSON = [resultSet stringForColumn:@"messageJSON"];
            model.read = [resultSet intForColumn:@"read"];
//            model.numberOfEmailInThread = [resultSet intForColumn:@"threadmailcount"];
            
            double dateTimeInterval = [resultSet doubleForColumn:@"date"];
            model.date = [NSDate dateWithTimeIntervalSince1970:dateTimeInterval];
            if ([resultSet stringForColumn:@"messageBodyToBeRendered"]) {
                model.messageBodyToBeRendered = [resultSet stringForColumn:@"messageBodyToBeRendered"];
            }
            else
                model.messageBodyToBeRendered = EMPTY_DELIMITER;
            
            if ([resultSet stringForColumn:@"messageHTMLBody"]) {
                model.messageHTMLBody = [resultSet stringForColumn:@"messageHTMLBody"];
            }
            else
                model.messageHTMLBody = EMPTY_DELIMITER;
            
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
//    FMResultSet *resultSet = [db executeQuery:@"SELECT DISTINCT * FROM messageFilterXRef,messages WHERE messages.messageID=messageFilterXRef.messageID and messageFilterXRef.funnelId=:funnelId order by messageID DESC limit :limit" withParameterDictionary:paramDict];
      FMResultSet *resultSet = [db executeQuery:@"SELECT messages.messageID, messages.messageJSON, messages.read, messages.messageBodyToBeRendered, messages.messageHTMLBody, messages.date, t.t_count, messages.funnelJson FROM messages INNER JOIN (SELECT MAX(messages.messageID) as t_msgID, COUNT(*) as t_count FROM messages INNER JOIN messageFilterXRef ON ( messages.messageID = messageFilterXRef.messageID ) WHERE messageFilterXRef.funnelId =:funnelId  GROUP BY gmailthreadid) t ON ( messages. messageID = t.t_msgID ) order by messages.messageID DESC limit :limit;" withParameterDictionary:paramDict];
      
    
    MessageModel *model;
    
    while ([resultSet next]) {
        model = [[MessageModel alloc]init];
        model.messageID = [resultSet stringForColumn:@"messageID"];
        model.messageJSON = [resultSet stringForColumn:@"messageJSON"];
        model.read = [resultSet intForColumn:@"read"];
        model.date = [resultSet dateForColumn:@"date"];
        model.numberOfEmailInThread = [resultSet intForColumn:@"t_count"];

        if ([resultSet stringForColumn:@"messageBodyToBeRendered"]) {
            model.messageBodyToBeRendered = [resultSet stringForColumn:@"messageBodyToBeRendered"];
        }
        else
            model.messageBodyToBeRendered = EMPTY_DELIMITER;
        
        if ([resultSet stringForColumn:@"messageHTMLBody"]) {
            model.messageHTMLBody = [resultSet stringForColumn:@"messageHTMLBody"];
        }
        else
            model.messageHTMLBody = EMPTY_DELIMITER;
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

#pragma mark -
#pragma funnelLabelOperations

- (void)removeFunnelJson {
    NSArray *messageArray = [self messagesAllTopMessages];
    for (MessageModel *temp in messageArray) {
        temp.funnelJson = @"";
        [[MessageService instance] updateMessage:temp];
    }
}

- (void)insertFunnelJsonForMessages {
    [self removeFunnelJson];
//    NSArray *messageArray = [self messagesAllTopMessages];
    NSArray *funnelArray = [[FunnelService instance] allFunnels];
    for (FunnelModel *tempModel in funnelArray) {
        NSArray *referenceArray = [[MessageFilterXRefService instance] messagesWithFunnelId:tempModel.funnelId];
        for (MessageModel *tempMessage in referenceArray) {
            NSString *funnelID = tempModel.funnelId;
            NSString *messageID = tempMessage.messageID;
            NSString *funnelJsonString = [tempMessage funnelJson];
            NSError *error = nil;
            NSMutableDictionary *tempDict = (NSMutableDictionary*)[NSJSONSerialization JSONObjectWithData:[funnelJsonString dataUsingEncoding:NSUTF8StringEncoding]
                                                                                                  options: NSJSONReadingAllowFragments
                                                                                                    error: &error];
            if (!error) {
                tempDict = [self insertIntoDictionary:tempDict funnel:tempModel];
            }
            if (tempDict) {
                [tempMessage setFunnelJson:[self getJsonStringByDictionary:(NSDictionary*)tempDict]];
            }
            else {
                tempDict = [[NSMutableDictionary alloc] init];
                tempDict[tempModel.funnelName] = tempModel.funnelColor;
                [tempMessage setFunnelJson:[self getJsonStringByDictionary:(NSDictionary*)tempDict]];
            }
            [[MessageService instance] updateMessage:tempMessage];
            [[MessageFilterXRefService instance] insertMessageXRefMessageID:messageID funnelId:funnelID];
        }
    }
}

-(NSString*)getJsonStringByDictionary:(NSDictionary*)dictionary{
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

- (BOOL)checkForKey:(NSString *)key indict:(NSMutableDictionary*)dict {
    NSArray *keys = dict.allKeys;
    for (NSString *key1 in keys) {
        if ([key1 isEqualToString:key])
            return FALSE;
    }
    return TRUE;
}

#pragma mark insertIntoDictionary
- (NSMutableDictionary*)insertIntoDictionary:(NSMutableDictionary*)dict funnel:(FunnelModel*)funnel {
    if (!dict) {
        dict = [[NSMutableDictionary alloc] init];
    }
    NSMutableDictionary *temp = [[NSMutableDictionary alloc] initWithDictionary:dict];
    NSString *key = funnel.funnelName;
    if ([self checkForKey:key indict:dict]) {
        temp[key] = funnel.funnelColor;
    }
    dict = temp;
    temp = nil;
    return dict;
}

@end
