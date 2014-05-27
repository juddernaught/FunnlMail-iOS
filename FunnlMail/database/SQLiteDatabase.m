//
//  SQLiteDatabase.m
//  TestTheDatabase
//
//  Created by Michael Raber on 5/25/14.
//  Copyright (c) 2014 Innoruptor. All rights reserved.
//

#import "SQLiteDatabase.h"
#import "FMResultSet.h"
#import "FMDatabase.h"

static SQLiteDatabase *sharedInstance;

@implementation SQLiteDatabase

+(void) initialize{
  static BOOL initialized = NO;
  if(!initialized){
    initialized = YES;
    
    sharedInstance = [[SQLiteDatabase alloc] init];
  }
}

+(SQLiteDatabase *) sharedInstance{
  return sharedInstance;
}

-(id) init {
  self = [super init];
  if (self) {
    //
    // setup internals
    //
    [self setupDatabase];
  }
  return self;
}

-(void) setupDatabase{
  NSError* error;
  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
  NSString *documentsDirectory = [paths objectAtIndex:0];
  
  NSString *dbPath = [NSString stringWithFormat:@"%@/funnlmail", documentsDirectory];
  
  if (![[NSFileManager defaultManager] fileExistsAtPath:dbPath]){
    [[NSFileManager defaultManager] createDirectoryAtPath:dbPath withIntermediateDirectories:YES attributes:nil error:&error];
  }
  
  NSString *dbPathName = [NSString stringWithFormat:@"%@/funnlmail.db", dbPath];
  
  NSLog(@"path to funnlmail.db: %@", dbPathName);
  
  databaseQueue = [FMDatabaseQueue databaseQueueWithPath:dbPathName];
  
  //
  // dump to the console the SQLite version for informational purposes only
  //
  [databaseQueue inDatabase:^(FMDatabase *db) {
    FMResultSet *s = [db executeQuery:@"select sqlite_version()"];
    while ([s next]) {
      NSLog(@"SQLite version:%@", [s stringForColumn:@"sqlite_version()"]);
    }
  }];
  
  //
  // check to see if the db schema exists, if not schemaExists will be NO
  //
  __block BOOL schemaExists = NO;
  [databaseQueue inDatabase:^(FMDatabase *db) {
    FMResultSet *resultSet = [db executeQuery:@"SELECT name FROM sqlite_master WHERE type='table' AND name='dbVersion'"];
    while ([resultSet next]) {
      schemaExists = YES;
      
      break;
    }
    
    [resultSet close];
  }];
  
  if(schemaExists){
    //
    // get schema version
    //
    NSLog(@"db version:%@", [self schemaVersion]);
    
    //[databaseQueue inDatabase:^(FMDatabase *db) {
    //  FMResultSet *resultSet = [db executeQuery:@"select version from dbVersion"];
    //  while ([resultSet next]) {
    //    NSLog(@"db version:%@", [resultSet stringForColumn:@"version"]);
    //  }
    //}];
  }
  
  //
  // if schema doesn't exist, load aql from dbschema.sql and execute
  //
  if(!schemaExists){
    [databaseQueue inDatabase:^(FMDatabase *db) {
      NSError *error;
      NSString *filePath = [[NSBundle mainBundle] pathForResource:@"dbschema" ofType:@"sql"];
      NSString *sql = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:&error];
      
      [db executeStatements:sql];
      
      NSLog(@"schema created!");
    }];
  }
}

-(NSString *) schemaVersion{
  __block NSString *version;
  
  [databaseQueue inDatabase:^(FMDatabase *db) {
    FMResultSet *resultSet = [db executeQuery:@"select version from dbVersion"];
    while ([resultSet next]) {
      version = [resultSet stringForColumn:@"version"];
    }
    
    [resultSet close];
  }];
  
  return version;
}

-(FMDatabaseQueue *) databaseQueue{
  return databaseQueue;
}

@end
