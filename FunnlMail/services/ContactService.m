//
//  ContactService.m
//  FunnlMail
//
//  Created by Macbook on 8/7/14.
//  Copyright (c) 2014 FunnlMail. All rights reserved.
//

#import "ContactService.h"
#import "SQLiteDatabase.h"
#import "FMDatabase.h"
#import "FMResultSet.h"
#import "ServiceUtils.h"
static ContactService *instance;

@implementation ContactService
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
        instance = [[ContactService alloc] init];
    }
}

+(ContactService *)instance{
    return instance;
}

-(BOOL) insertBulkContacts:(NSArray *)ContactModelArray{
    
    __block BOOL success = NO;
    for (ContactModel *ContactModel in ContactModelArray) {
        __block NSMutableDictionary *paramDict = [[NSMutableDictionary alloc]init];
        
        
        paramDict[@"name"] = ContactModel.name;
        paramDict[@"email"] = ContactModel.email;
        paramDict[@"thumbnail"] = ContactModel.thumbnail;
        paramDict[@"count"] = [NSNumber numberWithInt:ContactModel.count];
        paramDict[@"received_count"] = [NSNumber numberWithInt:ContactModel.received_count];;
        paramDict[@"sent_count"] = [NSNumber numberWithInt:ContactModel.sent_count];;
        paramDict[@"sent_from_account_count"] = [NSNumber numberWithInt:ContactModel.sent_from_account_count];;

        [[SQLiteDatabase sharedInstance].databaseQueue inDatabase:^(FMDatabase *db) {
            success = [db executeUpdate:@"INSERT OR REPLACE INTO contacts (name,email,thumbnail,count,received_count,sent_count,sent_from_account_count) VALUES (:name,:email,:thumbnail,:count,:received_count,:sent_count,:sent_from_account_count)" withParameterDictionary:paramDict];
        }];
        
    }
    return success;
}
-(NSArray *) searchContactsWithString:(NSString*)searchTerm{
    __block NSMutableArray *array = [[NSMutableArray alloc] init];
    
    [[SQLiteDatabase sharedInstance].databaseQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *resultSet ;

        
        NSString *query = [NSString stringWithFormat:@"SELECT email FROM contacts WHERE name LIKE  '%@%%'  OR  email  LIKE  '%@%%'  ORDER BY count DESC LIMIT 5;",searchTerm,searchTerm];
        resultSet = [db executeQuery:query];
//        resultSet = [db executeQuery:@"SELECT email FROM contacts WHERE name LIKE  '%' || ? || '%'  OR email LIKE '%' || ? || '%' ORDER BY count DESC LIMIT 5;",searchTerm,searchTerm];

        while ([resultSet next]) {
            NSString *email = [resultSet stringForColumn:@"email"];
            [array addObject:email];
        }
    }];
    
    return array;
}


@end
