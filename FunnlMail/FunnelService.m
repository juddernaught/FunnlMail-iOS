//
//  FunnelService.m
//  FunnlMail
//
//  Created by Michael Raber on 6/3/14.
//  Copyright (c) 2014 FunnlMail. All rights reserved.
//

#import "FunnelService.h"
#import "FunnelModel.h"
//#import "FilterModel.h"
#import "SQLiteDatabase.h"
#import "FMDatabase.h"
#import "FMResultSet.h"
#import "UIColor+HexString.h"
#import <Mixpanel/Mixpanel.h>

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
    if ([funnelModel.funnelId isEqualToString:@"0"] || [funnelModel.funnelId isEqualToString:@"1"]) {
        paramDict[@"funnelId"] = funnelModel.funnelId;
    }
    else
        paramDict[@"funnelId"] = [[NSUUID UUID] UUIDString];
    
    paramDict[@"funnelName"] = funnelModel.funnelName;
    paramDict[@"emailAddresses"] = funnelModel.emailAddresses;
    paramDict[@"webhookIds"] = funnelModel.webhookIds;
    paramDict[@"phrases"] = funnelModel.phrases;
    paramDict[@"skipFlag"] = [NSNumber numberWithBool:funnelModel.skipFlag];
    paramDict[@"notificationsFlag"] = [NSNumber numberWithBool:funnelModel.notificationsFlag];
    if (funnelModel.funnelColor) {
        paramDict[@"funnelColor"] = funnelModel.funnelColor;
    }
    else
        paramDict[@"funnelColor"] = @"#000000";
  
  
  [[SQLiteDatabase sharedInstance].databaseQueue inDatabase:^(FMDatabase *db) {
    success = [db executeUpdate:@"INSERT INTO funnels (funnelId,funnelName,emailAddresses,webhookIds,phrases,skipFlag,notificationsFlag,funnelColor) VALUES (:funnelId,:funnelName,:emailAddresses,:webhookIds,:phrases,:skipFlag,:notificationsFlag,:funnelColor)" withParameterDictionary:paramDict];
  }];
  
  if(success){
    funnelModel.funnelId = paramDict[@"funnelId"];
  }
  
  return success;
}

-(BOOL) updateFunnel:(FunnelModel *)funnelModel{
#ifdef TRACK_MIXPANEL
    [[Mixpanel sharedInstance] track:@"Updated funnl"];
#endif
  __block NSMutableDictionary *paramDict = [[NSMutableDictionary alloc]init];
  
  __block BOOL success = NO;
  
  paramDict[@"funnelId"] = funnelModel.funnelId;
  paramDict[@"funnelName"] = funnelModel.funnelName;
  paramDict[@"emailAddresses"] = funnelModel.emailAddresses;
  paramDict[@"webhookIds"] = funnelModel.webhookIds;
  paramDict[@"phrases"] = funnelModel.phrases;
  paramDict[@"skipFlag"] = [NSNumber numberWithBool:funnelModel.skipFlag];
  paramDict[@"notificationsFlag"] = [NSNumber numberWithBool:funnelModel.notificationsFlag];

  
  [[SQLiteDatabase sharedInstance].databaseQueue inDatabase:^(FMDatabase *db) {
    success = [db executeUpdate:@"UPDATE funnels SET funnelName=:funnelName,emailAddresses=:emailAddresses,webhookIds=:webhookIds,phrases=:phrases,notificationsFlag=:notificationsFlag,skipFlag=:skipFlag WHERE funnelId=:funnelId" withParameterDictionary:paramDict];
  }];
  
  return success;
}

-(NSArray *) getFunnelsExceptAllFunnel{
    __block NSMutableArray *array = [[NSMutableArray alloc] init];
    __block NSMutableDictionary *paramDict = [[NSMutableDictionary alloc]init];
    paramDict[@"funnelName"] = ALL_FUNNL;
    
    [[SQLiteDatabase sharedInstance].databaseQueue inDatabase:^(FMDatabase *db) {
//        FMResultSet *resultSet = [db executeQuery:@"SELECT funnelId,funnelName,emailAddresses,phrases,skipFlag,funnelColor FROM funnels WHERE funnelName !=:funnelName" withParameterDictionary:paramDict];
        
        NSString *query = [NSString stringWithFormat:@"SELECT funnelId,funnelName,emailAddresses,webhookIds,phrases,skipFlag,notificationsFlag,funnelColor FROM funnels WHERE funnelName NOT IN ('%@','%@');",ALL_FUNNL,ALL_OTHER_FUNNL];
        FMResultSet *resultSet = [db executeQuery:query];
        
        
        FunnelModel *model;
        int counter = 1;
        while ([resultSet next]) {
            model = [[FunnelModel alloc]init];
            model.funnelId = [resultSet stringForColumn:@"funnelId"];
            model.skipFlag = [resultSet intForColumn:@"skipFlag"];
            model.notificationsFlag = [resultSet intForColumn:@"notificationsFlag"];
            model.funnelName = [resultSet stringForColumn:@"funnelName"];
            model.filterTitle = [resultSet stringForColumn:@"funnelName"];
            model.emailAddresses = [resultSet stringForColumn:@"emailAddresses"];
            model.webhookIds = [resultSet stringForColumn:@"webhookIds"];
            model.sendersArray = (NSMutableArray *)[[resultSet stringForColumn:@"emailAddresses"] componentsSeparatedByString:@","];
            model.phrases = [resultSet stringForColumn:@"phrases"];
            model.subjectsArray = (NSMutableArray *)[[resultSet stringForColumn:@"phrases"] componentsSeparatedByString:@","];
            NSArray *tempArray = GRADIENT_ARRAY;
            model.barColor = [UIColor colorWithHexString:[tempArray objectAtIndex:counter%5]];
            model.dateOfLastMessage = [NSDate date];
            if ([resultSet stringForColumn:@"funnelColor"]) {
                model.funnelColor = [resultSet stringForColumn:@"funnelColor"];
            }
            else
                model.funnelColor = @"";
            [array addObject:model];
            model = nil;
            counter ++;
        }
    }];
    
    return array;
}

-(NSArray *) allFunnels{
  __block NSMutableArray *array = [[NSMutableArray alloc] init];
    
  [[SQLiteDatabase sharedInstance].databaseQueue inDatabase:^(FMDatabase *db) {
      
    NSString *query = [NSString stringWithFormat:@"\
                       SELECT funnels.funnelId as funnelId, funnels.funnelName as funnelName, funnels.emailAddresses as emailAddresses, funnels.webhookIds as webhookIds, funnels.phrases as phrases, funnels.skipFlag as skipFlag, funnels.notificationsFlag as notificationsFlag, funnels.funnelColor as funnelColor, (COUNT(read) - SUM (read )) as readCount FROM funnels LEFT OUTER JOIN messageFilterXRef ON (messageFilterXRef.funnelId = funnels.funnelId) LEFT OUTER JOIN  messages ON (messageFilterXRef.messageId = messages.messageId) GROUP BY 1, 2, 3, 4, 5, 6 HAVING funnels.funnelName <> '%@' AND funnels.funnelName <> '%@'\
        UNION\
                       SELECT 0 as funnelId, '%@' as funnelName, '' as emailAddresses, '' as webhookIds, '', 0 as skipFlag, 0 as notificationsFlag, '#000000' as funnelColor, COUNT(read) as readCount FROM messages where messages.read = 0\
        UNION\
                       SELECT 1 as funnelId, '%@' as funnelName, '' as emailAddresses, '' as webhookIds, '', 0 as skipFlag, 0 as notificationsFlag, '#000000' as funnelColor, COUNT(read) as readCount FROM messages where messages.read = 0 AND messages.categoryName <> '%@';",ALL_FUNNL,ALL_OTHER_FUNNL,ALL_FUNNL,ALL_OTHER_FUNNL,PRIMARY_CATEGORY_NAME];
    FMResultSet *resultSet = [db executeQuery:query];
    FunnelModel *model;
//      FilterModel *modelForFilter;
      int counter = 1;
    while ([resultSet next]) {
      model = [[FunnelModel alloc]init];
//        modelForFilter = [[FilterModel alloc] init];
      
        
      model.funnelId = [resultSet stringForColumn:@"funnelId"];
      model.funnelName = [resultSet stringForColumn:@"funnelName"];
      model.filterTitle = [resultSet stringForColumn:@"funnelName"];
      model.skipFlag = [resultSet intForColumn:@"skipFlag"];
      model.notificationsFlag = [resultSet intForColumn:@"notificationsFlag"];
      model.newMessageCount = [resultSet intForColumn:@"readCount"];

//        modelForFilter.filterTitle = [resultSet stringForColumn:@"funnelName"];
      model.emailAddresses = [resultSet stringForColumn:@"emailAddresses"];
      model.webhookIds = [resultSet stringForColumn:@"webhookIds"];
      model.sendersArray = (NSMutableArray *)[[resultSet stringForColumn:@"emailAddresses"] componentsSeparatedByString:@","];
      model.phrases = [resultSet stringForColumn:@"phrases"];
      model.subjectsArray = (NSMutableArray *)[[resultSet stringForColumn:@"phrases"] componentsSeparatedByString:@","];
      NSArray *tempArray = GRADIENT_ARRAY;
//      NSInteger gradientInt = arc4random_uniform(tempArray.count);
      model.barColor = [UIColor colorWithHexString:[tempArray objectAtIndex:counter%5]];
        if ([resultSet stringForColumn:@"funnelColor"]) {
            model.funnelColor = [resultSet stringForColumn:@"funnelColor"];
        }
        else
            model.funnelColor = @"";
      model.dateOfLastMessage = [NSDate date];
      [array addObject:model];
      model = nil;
        counter ++;
    }
  }];
  
  return array;
}

-(FunnelModel *) emailServersWithFunnelName:(NSString *)funnelName{
  __block NSMutableDictionary *paramDict = [[NSMutableDictionary alloc]init];
  
  __block FunnelModel *model;
  
  paramDict[@"funnelName"] = funnelName;
  
  [[SQLiteDatabase sharedInstance].databaseQueue inDatabase:^(FMDatabase *db) {
    FMResultSet *resultSet = [db executeQuery:@"SELECT funnelId,funnelName,emailAddresses,webhookIds,phrases FROM funnels WHERE funnelName=:funnelName" withParameterDictionary:paramDict];
    
    while ([resultSet next]) {
      model = [[FunnelModel alloc]init];
      
      model.funnelId = [resultSet stringForColumn:@"funnelId"];
      model.funnelName = [resultSet stringForColumn:@"funnelName"];
      model.emailAddresses = [resultSet stringForColumn:@"emailAddresses"];
      model.webhookIds = [resultSet stringForColumn:@"webhookIds"];
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
