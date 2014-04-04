//
//  EmailService.h
//  FunnlMail
//
//  Created by Michael Raber on 3/30/14.
//  Copyright (c) 2014 FunnlMail. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EmailService : NSObject

+(EmailService *)instance;
+(NSArray *) currentFilters;
+(void) login;

@end
