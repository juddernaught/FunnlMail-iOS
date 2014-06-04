//
//  MessageModel.h
//  FunnlMail
//
//  Created by Michael Raber on 6/3/14.
//  Copyright (c) 2014 FunnlMail. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MessageModel : NSObject

@property (copy) NSString *messageID;
@property (copy) NSString *messageJSON;
@property (assign) BOOL read;
@property (strong) NSDate *date;

@end
