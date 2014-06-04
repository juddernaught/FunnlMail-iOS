//
//  ServiceUtils.h
//  FunnlMail
//
//  Created by Michael Raber on 6/3/14.
//  Copyright (c) 2014 FunnlMail. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ServiceUtils : NSObject

+(NSString *) convertDateTOSQLiteString:(NSDate *)date;

@end
