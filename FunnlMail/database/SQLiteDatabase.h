//
//  SQLiteDatabase.h
//  TestTheDatabase
//
//  Created by Michael Raber on 5/25/14.
//  Copyright (c) 2014 Innoruptor. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDatabaseQueue.h"

@interface SQLiteDatabase : NSObject{
  FMDatabaseQueue *databaseQueue;
}

@property (readonly) FMDatabaseQueue *databaseQueue;

+(SQLiteDatabase *) sharedInstance;

-(NSString *) schemaVersion;

@end
