//
//  MessageService.h
//  FunnlMail
//
//  Created by Michael Raber on 6/3/14.
//  Copyright (c) 2014 FunnlMail. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MessageModel.h"

@interface MessageService : NSObject

+(MessageService *)instance;

-(BOOL) insertEmailServer:(MessageModel *)messageModel;
-(NSArray *) messagesWithTop:(NSInteger)top;
-(NSArray *) messagesWithStart:(NSInteger)start count:(NSInteger)count;
-(BOOL) deleteMessage:(NSString *)messageID;

@end
